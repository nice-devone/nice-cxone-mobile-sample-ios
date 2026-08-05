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
import CXoneGuideUtility
import Foundation

/// Inert `ChatProvider` for SwiftUI previews in the sample app.
///
/// `CXoneChat()` constructs a real `KeychainService` and `UserDefaultsServiceImpl` — fine
/// for production but undesirable inside Xcode's preview canvas, which renders the view
/// many times per keystroke. Using this stub keeps previews fast and side-effect-free.
///
/// `prepare`/`connect` are no-ops; everything that returns a value returns a benign
/// default; everything that produces an event stream produces an empty stream. Code that
/// reaches a method the sample's view models never invoke in the happy path traps with
/// `fatalError` so the missing stub shows up immediately instead of silently no-oping.
@MainActor
final class MockChatProvider: ChatProvider {

    // MARK: - Static

    static var logWriter: LogWriter?

    // MARK: - Properties

    let state: ChatState = .prepared
    let mode: ChatMode = .multithread

    let connection: ConnectionProvider = MockConnectionProvider()
    let customer: CustomerProvider = MockCustomerProvider()
    let customerCustomFields: CustomerCustomFieldsProvider = MockCustomerCustomFieldsProvider()
    let threads: ChatThreadListProvider = MockChatThreadListProvider()
    let analytics: AnalyticsProvider = MockAnalyticsProvider()
    let proactiveAction: ProactiveActionProvider = MockProactiveActionProvider()

    // MARK: - Methods

    func events() -> AsyncStream<ChatEvent> {
        AsyncStream { _ in }
    }

    func signOut() {}
}

// MARK: - Connection

private final class MockConnectionProvider: ConnectionProvider, @unchecked Sendable {

    let channelConfiguration = ChannelConfiguration(
        hasMultipleThreadsPerEndUser: true,
        isProactiveChatEnabled: false,
        isAuthorizationEnabled: false,
        isSendTranscriptEnabled: false,
        fileRestrictions: FileRestrictions(allowedFileSize: 0, allowedFileTypes: [], isAttachmentsEnabled: false),
        features: [:],
        isOnline: true,
        isLiveChat: false,
        authenticationType: .anonymous
    )

    func getChannelConfiguration(environment: Environment, brandId: Int, channelId: String) async throws -> ChannelConfiguration {
        channelConfiguration
    }

    func getChannelConfiguration(chatURL: String, brandId: Int, channelId: String) async throws -> ChannelConfiguration {
        channelConfiguration
    }

    func prepare(environment: Environment, brandId: Int, channelId: String) async throws {}

    // swiftlint:disable:next function_parameter_count
    func prepare(chatURL: String, socketURL: String, loggerURL: String, brandId: Int, channelId: String, tokenURL: String?) async throws {}

    func connect() async throws {}

    func disconnect() {}

    func executeTrigger(_ triggerId: String) async throws {}
}

// MARK: - Customer

private final class MockCustomerProvider: CustomerProvider, @unchecked Sendable {

    func get() -> CustomerIdentity? { nil }

    func set(customer: CustomerIdentity?) throws {}

    func setDeviceToken(_ token: String) {}

    func setDeviceToken(_ tokenData: Data) {}

    func setConnectionToken(_ token: String, expiresAt: Date) {}

    func setTokenDelegateListener(_ listener: TokenDelegateListener?) {}

    func setAuthorizationCode(_ code: String) {}

    func setCodeVerifier(_ verifier: String) {}

    func setName(firstName: String, lastName: String) {}
}

// MARK: - Customer custom fields

private final class MockCustomerCustomFieldsProvider: CustomerCustomFieldsProvider, @unchecked Sendable {

    func get() -> [String: String] { [:] }

    func set(_ customFields: [String: String]) async throws {}
}

// MARK: - Threads

private final class MockChatThreadListProvider: ChatThreadListProvider, @unchecked Sendable {

    let preChatSurvey: PreChatSurvey? = nil

    let customFields: ContactCustomFieldsProvider = MockContactCustomFieldsProvider()

    func get() -> [ChatThread] { [] }

    func create() async throws -> ChatThreadProvider {
        fatalError("MockChatProvider.threads.create is not implemented — extend this stub if your preview reaches it.")
    }

    func create(with customFields: [String: String]) async throws -> ChatThreadProvider {
        fatalError("MockChatProvider.threads.create(with:) is not implemented — extend this stub if your preview reaches it.")
    }

    func load(with id: String?) async throws {}

    func provider(for threadId: String) throws -> any ChatThreadProvider {
        fatalError("MockChatProvider.threads.provider(for: threadId) is not implemented — extend this stub if your preview reaches it.")
    }

    func provider(for thread: ChatThread) throws -> any ChatThreadProvider {
        fatalError("MockChatProvider.threads.provider(for: thread) is not implemented — extend this stub if your preview reaches it.")
    }
}

private final class MockContactCustomFieldsProvider: ContactCustomFieldsProvider, @unchecked Sendable {

    func get(for threadId: String) -> [String: String] { [:] }

    func set(_ customFields: [String: String], for threadId: String) async throws {}
}

// MARK: - Analytics

private final class MockAnalyticsProvider: AnalyticsProvider, @unchecked Sendable {

    let visitorId: String? = nil

    func viewPage(title: String, url: String) async throws {}

    func viewPageEnded(title: String, url: String) async throws {}

    func chatWindowOpen() async throws {}

    func conversion(type: String, value: Double) async throws {}
}

// MARK: - Proactive action

private final class MockProactiveActionProvider: ProactiveActionProvider, @unchecked Sendable {

    func trigger(_ action: ProactiveActionTriggerType) async throws {}
}
