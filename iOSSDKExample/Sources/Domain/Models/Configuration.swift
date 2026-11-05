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

struct Configuration: Hashable {
    
    // MARK: - Properties
    
    var title: String
    var brandId: Int
    var channelId: String
    
    var environmentName: String
    var chatUrl: String
    var socketUrl: String
    var loggerUrl: String
    var tokenUrl: String
    
    /// The built-in region this configuration addresses, or `nil` for a custom environment.
    ///
    /// - Important: Matched on the trailing-slash-stripped `chatUrl` so the answer survives a storage
    ///     round-trip. `Environment.chatURL` never carries a trailing slash, whereas a hand-entered or
    ///     supplied URL may — and the decoder below strips it, so an un-normalised comparison would report
    ///     `nil` before the configuration was persisted and the region afterwards. `LoginViewModel`
    ///     chooses between the two `prepare` overloads on this value, so it must not change underfoot.
    var environment: CXoneChatSDK.Environment? {
        switch self.chatUrl.stripTrailingSlashes {
        case CXoneChatSDK.Environment.NA1.chatURL:
            return .NA1
        case CXoneChatSDK.Environment.EU1.chatURL:
            return .EU1
        case CXoneChatSDK.Environment.AU1.chatURL:
            return .AU1
        case CXoneChatSDK.Environment.CA1.chatURL:
            return .CA1
        case CXoneChatSDK.Environment.UK1.chatURL:
            return .UK1
        case CXoneChatSDK.Environment.JP1.chatURL:
            return .JP1
        default:
            return nil
        }
    }
    
    // MARK: - Init
    
    init(brandId: Int, channelId: String, environment: CXoneChatSDK.Environment) {
        self.title = environment.rawValue
        self.brandId = brandId
        self.channelId = channelId
        self.environmentName = environment.rawValue
        self.chatUrl = environment.chatURL
        self.socketUrl = environment.socketURL
        self.loggerUrl = environment.loggerURL
        self.tokenUrl = environment.tokenURL
    }
    
    init(
        title: String,
        brandId: Int,
        channelId: String,
        environmentName: String,
        chatUrl: String,
        socketUrl: String,
        loggerUrl: String,
        tokenUrl: String
    ) {
        self.title = title
        self.brandId = brandId
        self.channelId = channelId
        self.environmentName = environmentName
        self.chatUrl = chatUrl
        self.socketUrl = socketUrl
        self.loggerUrl = loggerUrl
        self.tokenUrl = tokenUrl
    }
}

// MARK: - Channel identity

extension Configuration {

    /// Whether both configurations address the same brand and channel on the same backend.
    ///
    /// - Important: Compares identifying fields instead of using `==`. A configuration re-hydrated from
    ///     `LocalStorageManager` has had trailing slashes stripped from `chatUrl`/`tokenUrl` by the
    ///     decoder below, so it is never strictly equal to the same configuration built from
    ///     `Environment` — an `==` check here would report every warm start as a channel switch and
    ///     needlessly tear the session down. Both sides are normalised for that reason.
    ///
    /// - Important: All four environment URLs are part of the identity, not `environmentName`. The name is
    ///     display-only and can legitimately repeat, whereas the same brand and channel IDs really can
    ///     exist on different backends — `environment.json` shows brand/channel pairs across QA, staging
    ///     and production. Comparing names alone would miss a backend switch and leave a stale session in
    ///     place; comparing names *additionally* would report a switch whenever only the label changed.
    ///
    /// - Important: `chatUrl` alone is not enough. A shared chat host can front different socket, logger
    ///     or auth gateways, so a set of URLs that agrees on `chatUrl` and differs elsewhere is still a
    ///     different backend — and the Keychain OAuth state, stored identity and theme belonging to the
    ///     previous one have to go.
    func identifiesSameChannel(as other: Configuration) -> Bool {
        brandId == other.brandId
            && channelId == other.channelId
            && chatUrl.stripTrailingSlashes == other.chatUrl.stripTrailingSlashes
            && socketUrl.stripTrailingSlashes == other.socketUrl.stripTrailingSlashes
            && loggerUrl.stripTrailingSlashes == other.loggerUrl.stripTrailingSlashes
            && tokenUrl.stripTrailingSlashes == other.tokenUrl.stripTrailingSlashes
    }
}

// MARK: - Codable

extension Configuration: Codable {
    
    enum CodingKeys: CodingKey {
        case brandId
        case channelId
        case environment
        case name
    }
    
    enum EnvironmentKeys: CodingKey {
        case chatUrl
        case name
        case socketUrl
        case loggerUrl
        case tokenUrl
    }
    
    static func decodeList(from data: Data) throws -> [Configuration] {
        try JSONDecoder().decode(ConfigurationList.self, from: data).configurations
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let environmentContainer = try container.nestedContainer(keyedBy: EnvironmentKeys.self, forKey: .environment)
        
        self.brandId = try container.decode(Int.self, forKey: .brandId)
        self.channelId = try container.decode(String.self, forKey: .channelId)
        self.title = try container.decode(String.self, forKey: .name)
        self.environmentName = try environmentContainer.decode(String.self, forKey: .name)
        self.socketUrl = try environmentContainer.decode(String.self, forKey: .socketUrl)
        self.loggerUrl = try environmentContainer.decode(String.self, forKey: .loggerUrl)

        self.chatUrl = try environmentContainer
            .decode(String.self, forKey: .chatUrl)
            .stripTrailingSlashes

        self.tokenUrl = try environmentContainer
            .decode(String.self, forKey: .tokenUrl)
            .stripTrailingSlashes
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var environmentContainer = container.nestedContainer(keyedBy: EnvironmentKeys.self, forKey: .environment)
        
        try container.encode(brandId, forKey: .brandId)
        try container.encode(channelId, forKey: .channelId)
        try container.encode(title, forKey: .name)
        try environmentContainer.encode(environmentName, forKey: .name)
        try environmentContainer.encode(socketUrl, forKey: .socketUrl)
        try environmentContainer.encode(chatUrl, forKey: .chatUrl)
        try environmentContainer.encode(loggerUrl, forKey: .loggerUrl)
        try environmentContainer.encode(tokenUrl, forKey: .tokenUrl)
    }
}

// MARK: - Private helpers

private extension String {
    
    /// The string with **every** trailing `/` removed, not just one.
    ///
    /// `…/chat//` is what naive concatenation produces, and stripping a single slash would leave two
    /// spellings of the same endpoint comparing unequal — reporting a channel switch on a warm start, and
    /// letting a custom URL set slip past the built-in-region collision check in `LaunchConfigurationReader`.
    var stripTrailingSlashes: String {
        var result = self

        while result.hasSuffix("/") {
            result.removeLast()
        }

        return result
    }
}

// MARK: - Helpers

private struct ConfigurationList: Decodable {
    
    let configurations: [Configuration]
}
