//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sample-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import AppAuth
import Foundation
import Security
import UIKit

/// `OAuthenticator` backed by AppAuth-iOS using Google as the OAuth 2.0 provider.
///
/// AppAuth generates the PKCE parameters internally. The two flows use different AppAuth entry
/// points:
/// - **implicit:** the full authorization + token exchange runs in-app (`OIDAuthState`), and the
///   resulting access token is handed to the SDK via `setConnectionToken(_:expiresAt:)`.
/// - **explicit:** only the authorization step runs in-app (`OIDAuthorizationService`); the raw
///   authorization code and code verifier are handed to the SDK, and the CXone backend finishes
///   the exchange.
///
/// `@unchecked Sendable` is required because `OAuthenticator` is `Sendable` but this type holds a
/// mutable `currentSession` and presents UIKit-bound AppAuth UI. Concurrent usage is safe because:
///
///   1. `currentSession` and `authState` are read and written exclusively on the main thread — they
///      are set inside a `@MainActor` task during presentation, cleared in the AppAuth callbacks
///      (which AppAuth invokes on the main thread) and in `signOut()`, and the silent-refresh path
///      (`refreshImplicitToken()`) also hops to `@MainActor` before touching `authState`.
///   2. `configuration`, `clientId`, and `redirectURL` are set in `init` and never mutated.
final class GoogleAuthenticator: OAuthenticator, @unchecked Sendable {

    // MARK: - Properties

    let authenticatorName = "Google"

    private let configuration: OIDServiceConfiguration
    private let clientId: String
    private let redirectURL: URL

    /// The in-flight authorization session, retained so `handleOpen(url:)` can resume it.
    private var currentSession: OIDExternalUserAgentSession?

    /// The authorization state from the last implicit sign-in, retained so the token can be refreshed
    /// silently (via its refresh token) without presenting UI again. Main-thread only.
    private var authState: OIDAuthState?

    // MARK: - Init

    /// Builds the authenticator from the OAuth client values in `GoogleService-Info.plist`.
    ///
    /// - Throws: `CommonError` if the plist or its required keys are missing.
    init() throws {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let values = NSDictionary(contentsOfFile: path),
              let clientId = values["CLIENT_ID"] as? String,
              let reversedClientId = values["REVERSED_CLIENT_ID"] as? String else {
            throw CommonError.failed("GoogleService-Info.plist is missing or has no CLIENT_ID / REVERSED_CLIENT_ID.")
        }
        guard let redirectURL = URL(string: "\(reversedClientId):/") else {
            throw CommonError.failed("Unable to build Google OAuth redirect URL from REVERSED_CLIENT_ID.")
        }

        self.clientId = clientId
        self.redirectURL = redirectURL
        self.configuration = OIDServiceConfiguration(
            authorizationEndpoint: Constants.authorizationEndpoint,
            tokenEndpoint: Constants.tokenEndpoint
        )
    }

    // MARK: - Methods

    func authorize(flow: OAuthFlow) async throws -> OAResult {
        switch flow {
        case .implicit:
            return try await presentForImplicit()
        case .explicit:
            return try await presentForExplicit()
        }
    }

    func refreshImplicitToken() async throws -> (token: String, expiresAt: Date) {
        // `performAction` refreshes the access token via the stored refresh token when needed and
        // returns a valid one — no UI. `authState` is touched on the main thread; only the `Sendable`
        // token + expiry cross the continuation boundary.
        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                guard let authState = self.authState else {
                    continuation.resume(throwing: OAError.missingValue("authState"))
                    return
                }

                authState.performAction { accessToken, _, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let accessToken else {
                        continuation.resume(throwing: OAError.missingValue("accessToken"))
                        return
                    }
                    guard let expiresAt = authState.lastTokenResponse?.accessTokenExpirationDate else {
                        continuation.resume(throwing: OAError.missingValue("accessTokenExpirationDate"))
                        return
                    }

                    // The refresh may have rotated the tokens — re-persist the updated state.
                    AuthStateStore.save(authState)

                    continuation.resume(returning: (token: accessToken, expiresAt: expiresAt))
                }
            }
        }
    }

    func restoreImplicitSession() async -> Bool {
        await MainActor.run {
            guard authState == nil else {
                return true
            }
            guard let restored = AuthStateStore.load() else {
                return false
            }

            Log.trace("Restored the persisted Google auth state for the implicit flow")

            authState = restored

            return true
        }
    }

    func signOut() async throws {
        await MainActor.run {
            currentSession?.cancel()
            currentSession = nil
            authState = nil

            AuthStateStore.clear()
        }
    }

    // Called only from the app's main-thread `onOpenURL` handler — see the `@unchecked Sendable`
    // note on the type for why touching `currentSession` here is safe.
    func handleOpen(url: URL, sourceApplication: String?) -> Bool {
        guard let session = currentSession else {
            return false
        }

        return session.resumeExternalUserAgentFlow(with: url)
    }
}

// MARK: - AuthStateStore

/// Persists the AppAuth `OIDAuthState` (which carries the refresh token) in the Keychain so a
/// returning user's implicit-flow session can be restored — and its token silently refreshed —
/// after an app relaunch. The Keychain is used instead of `UserDefaults` because the state
/// contains long-lived credentials.
private enum AuthStateStore {

    static let service = "com.nice.cxonechat.sample.oauth"
    static let account = "google.authState"

    private static var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    static func save(_ authState: OIDAuthState) {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: true) else {
            Log.error("Unable to archive the Google auth state for persistence")
            return
        }

        SecItemDelete(baseQuery as CFDictionary)

        var attributes = baseQuery
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status != errSecSuccess {
            Log.error("Unable to persist the Google auth state in the Keychain (status: \(status))")
        }
    }

    static func load() -> OIDAuthState? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data)
    }

    static func clear() {
        SecItemDelete(baseQuery as CFDictionary)
    }
}

// MARK: - Private methods

private extension GoogleAuthenticator {

    enum Constants {
        // swiftlint:disable force_unwrapping
        // These literals are fixed, well-formed Google OAuth 2.0 endpoints — they cannot fail to parse.
        static let authorizationEndpoint = URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        static let tokenEndpoint = URL(string: "https://oauth2.googleapis.com/token")!
        // swiftlint:enable force_unwrapping
        static let scopes = [OIDScopeOpenID, OIDScopeProfile, OIDScopeEmail]
    }

    func makeAuthorizationRequest() -> OIDAuthorizationRequest {
        OIDAuthorizationRequest(
            configuration: configuration,
            clientId: clientId,
            clientSecret: nil,
            scopes: Constants.scopes,
            redirectURL: redirectURL,
            responseType: OIDResponseTypeCode,
            additionalParameters: ["access_type": "offline"]
        )
    }

    /// Implicit flow — runs the full authorization + token exchange in-app.
    ///
    /// The `Sendable` access token is extracted inside the main-thread callback so that no
    /// non-`Sendable` AppAuth object crosses the continuation's isolation boundary.
    func presentForImplicit() async throws -> OAResult {
        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                guard let presenter = Self.topViewController() else {
                    continuation.resume(throwing: CommonError.failed("No presenting view controller available for Google sign-in."))
                    return
                }

                self.currentSession = OIDAuthState.authState(byPresenting: self.makeAuthorizationRequest(), presenting: presenter) { authState, error in
                    self.currentSession = nil

                    guard let authState else {
                        continuation.resume(throwing: Self.mapError(error))
                        return
                    }
                    guard let accessToken = authState.lastTokenResponse?.accessToken else {
                        continuation.resume(throwing: OAError.missingValue("accessToken"))
                        return
                    }
                    guard let expiresAt = authState.lastTokenResponse?.accessTokenExpirationDate else {
                        continuation.resume(throwing: OAError.missingValue("accessTokenExpirationDate"))
                        return
                    }

                    // Retain the auth state (on the main thread) so the SDK's token delegate can refresh
                    // silently later, and persist it so a returning user's session survives a relaunch.
                    self.authState = authState
                    AuthStateStore.save(authState)

                    continuation.resume(returning: .implicit(connectionToken: accessToken, expiresAt: expiresAt))
                }
            }
        }
    }

    /// Explicit flow — runs only the authorization step; the backend finishes the exchange.
    ///
    /// The `Sendable` code + verifier are extracted inside the main-thread callback so that no
    /// non-`Sendable` AppAuth object crosses the continuation's isolation boundary.
    func presentForExplicit() async throws -> OAResult {
        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                guard let presenter = Self.topViewController() else {
                    continuation.resume(throwing: CommonError.failed("No presenting view controller available for Google sign-in."))
                    return
                }

                self.currentSession = OIDAuthorizationService.present(self.makeAuthorizationRequest(), presenting: presenter) { response, error in
                    self.currentSession = nil

                    guard let response else {
                        continuation.resume(throwing: Self.mapError(error))
                        return
                    }
                    guard let authorizationCode = response.authorizationCode else {
                        continuation.resume(throwing: OAError.missingValue("authorizationCode"))
                        return
                    }
                    guard let codeVerifier = response.request.codeVerifier else {
                        continuation.resume(throwing: OAError.missingValue("codeVerifier"))
                        return
                    }

                    continuation.resume(returning: .explicit(authorizationCode: authorizationCode, codeVerifier: codeVerifier))
                }
            }
        }
    }

    /// Maps AppAuth's user-cancellation error to `OAError.cancelled`; passes other errors through.
    static func mapError(_ error: Error?) -> Error {
        guard let error else {
            return OAError.missingValue("authorization response")
        }

        let nsError = error as NSError
        if nsError.domain == OIDGeneralErrorDomain, nsError.code == OIDErrorCode.userCanceledAuthorizationFlow.rawValue {
            return OAError.cancelled
        }

        return error
    }

    /// Finds the top-most presented view controller to anchor the AppAuth browser session.
    @MainActor
    static func topViewController() -> UIViewController? {
        let activeScene = UIApplication.shared.connectedScenes
            .compactMap { scene in
                scene as? UIWindowScene
            }
            .first { scene in
                scene.activationState == .foregroundActive
            }

        let keyWindow = activeScene?.windows.first { window in
            window.isKeyWindow
        } ?? activeScene?.windows.first

        var top = keyWindow?.rootViewController

        while let presented = top?.presentedViewController {
            top = presented
        }

        return top
    }
}
