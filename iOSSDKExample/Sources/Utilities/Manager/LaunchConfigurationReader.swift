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

import CXoneChatSDK
import Foundation

/// Reads a predefined channel configuration from the process launch environment, letting the app be
/// launched straight into a known brand/channel without any manual input on `ConfigurationView`.
///
/// Appium's XCUITest driver sets these variables when it launches the app:
///
/// ```java
/// iosOptions.setProcessArguments(new ProcessArguments(List.of(), Map.of(
///         "CXONE_BRAND_ID", brandId,
///         "CXONE_CHANNEL_ID", channelId,
///         "CXONE_CHAT_URL", chatUrl,
///         "CXONE_SOCKET_URL", socketUrl,
///         "CXONE_LOGGER_URL", loggerUrl,
///         "CXONE_TOKEN_URL", tokenUrl)));
/// ```
///
/// The full contract is documented in `sample/docs/cs-predefined-configuration.md`.
///
/// - Note: Validation is all-or-nothing. Any malformed or missing variable rejects the whole set and the
///     app lands on its configuration screen, so the mistake is visible where it was made. A partially
///     applied configuration would fail later, further from its cause, which is strictly worse for
///     automation.
///
/// - Note: Values are read once, at launch, from `SDKDemoApp.init()`. Changing them requires relaunching
///     the app — which is exactly how a test session starts one.
enum LaunchConfigurationReader {

    // MARK: - Nested Types

    /// The outcome of reading the launch environment.
    ///
    /// ``rejected`` has to stay distinguishable from ``absent``. A plain launch must leave routing exactly
    /// as `AppRouter.init` settled it, whereas a supplied-but-malformed set has to force
    /// `ConfigurationView`: any configuration persisted by an earlier run is still there, so collapsing
    /// the two cases would run the misconfigured launch against the *previous* channel with nothing but a
    /// log line to say so.
    enum Outcome: Equatable {

        // MARK: - Cases

        /// No `CXONE_*` variable was supplied — an ordinary launch, and nothing worth warning about.
        case absent

        /// Something was supplied, but the set is incomplete or malformed. The reason has been logged.
        case rejected

        /// A complete, valid set.
        case supplied(PredefinedConfiguration)
    }

    // MARK: - Methods

    /// Reads and validates the full parameter set.
    ///
    /// - Parameter environment: Defaults to the real process environment; injectable so tests do not have
    ///     to mutate it.
    static func read(environment: [String: String] = ProcessInfo.processInfo.environment) -> Outcome {
        // Absent entirely is the normal case — a plain launch with no predefined configuration — and must
        // stay silent. Only a partial or malformed set is worth warning about.
        //
        // `requiredParameters` rather than `allCases`: an optional parameter on its own describes no
        // channel, so it must not arm the mechanism and force `ConfigurationView` — see the note there.
        let isAnyParameterSupplied = ConfigurationParameter.requiredParameters.contains { parameter in
            environment.value(for: parameter) != nil
        }

        guard isAnyParameterSupplied else {
            return .absent
        }

        guard let predefined = parse(environment) else {
            return .rejected
        }

        return .supplied(predefined)
    }
}

// MARK: - Private methods - Parsing

private extension LaunchConfigurationReader {

    /// - Returns: `nil` after logging when any part of the supplied set is missing or malformed.
    static func parse(_ environment: [String: String]) -> PredefinedConfiguration? {
        // `brandId` is an `Int` in `Configuration`, so a non-numeric value cannot be represented. Zero is
        // rejected to match `ConfigurationViewModel.isConfigurationValid()`, which treats it as "not
        // filled in".
        guard let brandIdValue = environment.value(for: .brandId), let brandId = Int(brandIdValue), brandId != 0 else {
            logRejection(.brandId, reason: "is missing or not a non-zero integer")
            return nil
        }

        guard let channelId = environment.value(for: .channelId) else {
            logRejection(.channelId, reason: "is missing or empty")
            return nil
        }

        guard let configuration = parseEnvironment(from: environment, brandId: brandId, channelId: channelId) else {
            return nil
        }

        guard let guestIdentity = parseGuestIdentity(from: environment) else {
            return nil
        }

        return PredefinedConfiguration(configuration: configuration, guestIdentity: guestIdentity.value)
    }
}

// MARK: - Private methods - Environment

private extension LaunchConfigurationReader {

    /// Resolves the environment half of the configuration, which may be a built-in region or a full set of
    /// custom URLs — never both, never a partial set.
    static func parseEnvironment(from environment: [String: String], brandId: Int, channelId: String) -> Configuration? {
        let regionValue = environment.value(for: .environment)
        let suppliedUrls = ConfigurationParameter.customEnvironmentUrls.filter { parameter in
            environment.value(for: parameter) != nil
        }

        switch (regionValue, suppliedUrls.isEmpty) {
        case (let regionValue?, true):
            guard let region = CXoneChatSDK.Environment(rawValue: regionValue) else {
                let supported = CXoneChatSDK.Environment.allCases.map(\.rawValue).joined(separator: ", ")
                logRejection(.environment, reason: "is unknown; supported values are \(supported)")
                return nil
            }

            // The same initializer `ConfigurationViewModel.defaultConfiguration` uses, so a predefined
            // configuration is indistinguishable from one entered by hand.
            var configuration = Configuration(brandId: brandId, channelId: channelId, environment: region)

            // Honoured here too, not only in the custom form. The label is display-only, so this changes
            // nothing about which backend is reached — but the documented Appium example sends it
            // alongside the URLs, and a caller who switches that map over to a region would otherwise
            // lose it silently: the one supplied variable that was neither applied nor rejected.
            if let name = environment.value(for: .environmentName) {
                configuration.title = name
                configuration.environmentName = name
            }

            return configuration
        case (nil, false):
            return customConfiguration(from: environment, brandId: brandId, channelId: channelId, supplied: suppliedUrls)
        case (nil, true):
            let names = ConfigurationParameter.customEnvironmentUrls.map(\.environmentVariableName).joined(separator: ", ")
            Log.warning(
                .failed(
                    """
                    Launch configuration ignored: supply either '\(ConfigurationParameter.environment.environmentVariableName)' \
                    for a built-in region, or all of \(names) for a custom environment.
                    """
                )
            )
            return nil
        case (_?, false):
            Log.warning(
                .failed(
                    """
                    Launch configuration ignored: '\(ConfigurationParameter.environment.environmentVariableName)' and the \
                    custom environment URLs are mutually exclusive — supply one form or the other, not both.
                    """
                )
            )
            return nil
        }
    }

    /// Builds a custom-environment configuration, rejecting an incomplete or malformed URL set.
    static func customConfiguration(
        from environment: [String: String],
        brandId: Int,
        channelId: String,
        supplied: [ConfigurationParameter]
    ) -> Configuration? {
        let missing = ConfigurationParameter.customEnvironmentUrls.filter { parameter in
            !supplied.contains(parameter)
        }

        guard missing.isEmpty else {
            let names = missing.map(\.environmentVariableName).joined(separator: ", ")
            Log.warning(.failed("Launch configuration ignored: custom environment is incomplete — missing \(names)."))
            return nil
        }

        // `supplied` guarantees a value is present for each; validate that it is actually usable as a URL
        // so a typo fails here rather than as an opaque connection error later.
        guard let chatUrl = validUrl(for: .chatUrl, in: environment),
              let socketUrl = validUrl(for: .socketUrl, in: environment),
              let loggerUrl = validUrl(for: .loggerUrl, in: environment),
              let tokenUrl = validUrl(for: .tokenUrl, in: environment)
        else {
            return nil
        }

        // Display-only, and the `environment.json` entries carry it as `environment.name`. Defaulted so a
        // caller only has to supply the URLs that actually affect behaviour.
        let name = environment.value(for: .environmentName) ?? "Custom"

        let configuration = Configuration(
            title: name,
            brandId: brandId,
            channelId: channelId,
            environmentName: name,
            chatUrl: chatUrl,
            socketUrl: socketUrl,
            loggerUrl: loggerUrl,
            tokenUrl: tokenUrl
        )

        // `Configuration.environment` is derived from `chatUrl` alone, and
        // `LoginViewModel.prepareConnection()` takes the region overload whenever that derivation succeeds
        // — substituting the region's socket, logger and token gateways for the three supplied here. A
        // custom set that collides on `chatUrl` therefore cannot be honoured as given, and accepting it
        // would silently connect a test run to production.
        if let region = configuration.environment {
            logRejection(
                .chatUrl,
                reason: """
                    matches the built-in '\(region.rawValue)' region, whose gateways would replace the other \
                    supplied URLs; use '\(ConfigurationParameter.environment.environmentVariableName)' \
                    alone to target that region
                    """
            )
            return nil
        } else {
            return configuration
        }
    }

    /// - Returns: The raw value, or `nil` after logging when it is absent or not a usable endpoint.
    ///
    /// A scheme alone is too weak a check: `file:///…`, `mailto:…` and `https:path` all carry one, none is
    /// reachable, and each would surface much later as an opaque connection error. Which schemes are
    /// acceptable is the parameter's own knowledge — see ``ConfigurationParameter/allowedUrlSchemes``.
    static func validUrl(for parameter: ConfigurationParameter, in environment: [String: String]) -> String? {
        guard let allowedSchemes = parameter.allowedUrlSchemes else {
            // Unreachable for the four URL parameters this is called with. A non-URL caller is a
            // programming error, and failing here is better than validating against an irrelevant list.
            Log.error("Launch configuration: '\(parameter.environmentVariableName)' carries no URL to validate")
            return nil
        }

        guard let value = environment.value(for: parameter),
              let url = URL(string: value),
              let scheme = url.scheme?.lowercased(),
              allowedSchemes.contains(scheme),
              let host = url.host,
              !host.isEmpty
        else {
            logRejection(parameter, reason: "is not an absolute \(allowedSchemes.joined(separator: ":// or ")):// URL with a host")
            return nil
        }

        return value
    }
}

// MARK: - Private methods - Guest identity

private extension LaunchConfigurationReader {

    /// Distinguishes "no names supplied" (valid) from "an incomplete pair" (invalid), which a bare
    /// `GuestIdentity?` return could not express.
    enum GuestIdentityResult {

        // MARK: - Cases

        case absent
        case supplied(GuestIdentity)

        // MARK: - Properties

        var value: GuestIdentity? {
            switch self {
            case .absent:
                return nil
            case .supplied(let identity):
                return identity
            }
        }
    }

    /// Resolves the optional guest identity, which must be supplied as a complete pair or not at all.
    ///
    /// - Returns: `nil` when exactly one of the two names is present, which invalidates the whole set.
    static func parseGuestIdentity(from environment: [String: String]) -> GuestIdentityResult? {
        let firstName = environment.value(for: .firstName)
        let lastName = environment.value(for: .lastName)

        switch (firstName, lastName) {
        case (nil, nil):
            return .absent
        case (let firstName?, let lastName?):
            return .supplied(GuestIdentity(firstName: firstName, lastName: lastName))
        case (nil, _?), (_?, nil):
            Log.warning(
                .failed(
                    """
                    Launch configuration ignored: '\(ConfigurationParameter.firstName.environmentVariableName)' and \
                    '\(ConfigurationParameter.lastName.environmentVariableName)' must both be supplied and non-empty.
                    """
                )
            )
            return nil
        }
    }
}

// MARK: - Logging

private extension LaunchConfigurationReader {

    static func logRejection(_ parameter: ConfigurationParameter, reason: String) {
        Log.warning(.failed("Launch configuration ignored: '\(parameter.environmentVariableName)' \(reason)."))
    }
}

// MARK: - Helpers

private extension [String: String] {

    /// The trimmed value for `parameter`, or `nil` when it is absent or blank.
    ///
    /// Blank counts as absent. An empty entry is what a leftover scheme row, or an Appium `Map.of` value
    /// that resolved to nothing because no region applies, actually produces — and reading it as
    /// "supplied" turns a stray entry into a rejection with a misleading reason: an empty
    /// `CXONE_ENVIRONMENT` alongside a complete, correct URL set would be reported as the two forms being
    /// mutually exclusive.
    ///
    /// Trimming is here for the same reason. `CXONE_CHANNEL_ID="chat_abc\n"` — what reading an ID from a
    /// config file or a shell substitution tends to yield — passes every check in this file and then fails
    /// far away, as an opaque channel-configuration error. A trailing newline also survives
    /// `URL(string:)` with a non-nil scheme, so it would slip past the URL validation too.
    func value(for parameter: ConfigurationParameter) -> String? {
        guard let value = self[parameter.environmentVariableName]?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }

        return value.isEmpty ? nil : value
    }
}
