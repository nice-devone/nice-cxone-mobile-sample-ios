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

import Foundation

/// A guest identity supplied alongside a predefined configuration.
///
/// Only ever constructed from a complete pair — a launch environment carrying just one of the two names
/// is rejected outright rather than half-applied.
struct GuestIdentity: Equatable {

    // MARK: - Properties

    let firstName: String
    let lastName: String
}

/// A channel configuration supplied from outside the app, so the configuration screen can be skipped.
struct PredefinedConfiguration: Equatable {

    // MARK: - Properties

    let configuration: Configuration

    /// Guest identity to apply before reaching the login screen, or `nil` when no names were supplied —
    /// in which case the login screen is presented as usual.
    let guestIdentity: GuestIdentity?
}

/// The launch-environment variables a predefined configuration is read from.
///
/// The environment is expressed **either** as ``environment`` — one of the SDK's built-in regions — or
/// as the four ``chatUrl``/``socketUrl``/``loggerUrl``/``tokenUrl`` values, which is the equivalent of
/// the "custom configuration" form in `ConfigurationView` and of an entry in `environment.json`. The two
/// forms are mutually exclusive.
///
/// - Note: The custom form is what non-production environments need — the six cases of
///     `CXoneChatSDK.Environment` are all production regions, so any QA, test or staging backend has to
///     be described by its URLs.
enum ConfigurationParameter: CaseIterable {

    // MARK: - Cases

    case brandId
    case channelId
    case environment
    case environmentName
    case chatUrl
    case socketUrl
    case loggerUrl
    case tokenUrl
    case firstName
    case lastName

    // MARK: - Properties

    /// The four parameters that together describe a custom environment.
    static let customEnvironmentUrls: [ConfigurationParameter] = [.chatUrl, .socketUrl, .loggerUrl, .tokenUrl]

    /// The parameters that refine a configuration without constituting one.
    ///
    /// Were one of these allowed to count as "a configuration was supplied", a single leftover entry — one
    /// scheme row kept after the brand and channel rows were dropped — would read as a *malformed* set and
    /// force `ConfigurationView`, discarding the perfectly good configuration an earlier run persisted.
    static let optionalParameters: [ConfigurationParameter] = [.environmentName, .firstName, .lastName]

    /// The parameters a configuration cannot be expressed without, and so the only ones that arm the
    /// mechanism. Each is required in one of the two forms — ``environment`` in the first, the four
    /// ``customEnvironmentUrls`` in the second.
    ///
    /// Derived from ``allCases`` rather than listed, so the two sets cannot drift: a case added later is
    /// required until it is explicitly declared optional, which fails closed.
    static let requiredParameters: [ConfigurationParameter] = allCases.filter { parameter in
        !optionalParameters.contains(parameter)
    }

    /// The URL schemes this parameter accepts, or `nil` when it carries no URL at all.
    ///
    /// Kept here beside ``environmentVariableName`` so per-parameter knowledge lives in one place, and
    /// optional so that a non-URL case cannot be validated against a scheme list that means nothing for it
    /// — the alternative, defaulting the non-URL cases to `http`/`https`, would quietly accept a call that
    /// makes no sense.
    var allowedUrlSchemes: [String]? {
        switch self {
        // The SDK opens a WebSocket on this one, so an `https://` value is a mistake worth naming at launch.
        case .socketUrl:
            return ["ws", "wss"]
        case .chatUrl, .loggerUrl, .tokenUrl:
            return ["http", "https"]
        case .brandId, .channelId, .environment, .environmentName, .firstName, .lastName:
            return nil
        }
    }

    /// The `CXONE_`-prefixed variable this parameter is read from.
    ///
    /// The prefix is deliberate: an unprefixed `environment` variable is far too generic to claim in a
    /// process environment shared with the OS, the test runner and CI.
    var environmentVariableName: String {
        switch self {
        case .brandId:
            return "CXONE_BRAND_ID"
        case .channelId:
            return "CXONE_CHANNEL_ID"
        case .environment:
            return "CXONE_ENVIRONMENT"
        case .environmentName:
            return "CXONE_ENVIRONMENT_NAME"
        case .chatUrl:
            return "CXONE_CHAT_URL"
        case .socketUrl:
            return "CXONE_SOCKET_URL"
        case .loggerUrl:
            return "CXONE_LOGGER_URL"
        case .tokenUrl:
            return "CXONE_TOKEN_URL"
        case .firstName:
            return "CXONE_FIRST_NAME"
        case .lastName:
            return "CXONE_LAST_NAME"
        }
    }
}
