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

enum DeeplinkOption: Hashable {

    /// `com.incontact.mobileSDK.sample://threads?threadIdOnExternalPlatform={threadIdOnExternalPlatform}`
    ///     or `com.nice.cxonechat.sample://{channelId}/threads?idOnExternalPlatform={threadIdOnExternalPlatform}`
    case thread(String)
}

class ThreadsDeeplinkHandler {
    
    static func canOpenUrl(_ url: URL) -> Bool {
        switch true {
        case canOpenThreadDetail(from: url):
            return true
        default:
            return false
        }
    }
    
    /// Parses a deeplink URL. Only URLs accepted by ``canOpenUrl(_:)`` are parsed, so every entry
    /// point — `onOpenURL`, notification taps and the router — recognises the same set of URLs.
    static func handleUrl(_ url: URL) -> DeeplinkOption? {
        guard canOpenUrl(url) else {
            return nil
        }

        if let option = handleThreadDetail(from: url) {
            return option
        } else {
            return nil
        }
    }
}

private extension ThreadsDeeplinkHandler {
    
    /// `threads` must be the host (`scheme://threads?…`) or a whole path component (`scheme://{channelId}/threads?…`),
    /// and `idOnExternalPlatform` must be an exact query item name, so `threads` in a query value or another parameter name doesn't match.
    static func canOpenThreadDetail(from url: URL) -> Bool {
        let hasThreadsSegment = url.host() == "threads" || url.pathComponents.contains("threads")

        return hasThreadsSegment && url.getQueryValue(for: "idOnExternalPlatform") != nil
    }
    
    static func handleThreadDetail(from url: URL) -> DeeplinkOption? {
        if let threadId = url.getQueryValue(for: "idOnExternalPlatform") {
            return .thread(threadId)
        } else {
            return nil
        }
    }
}

private extension URL {
    
    func getQueryValue(for param: String) -> String? {
        let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems
        
        return queryItems?
            .first { queryItem in
                queryItem.name == param
            }?
            .value
    }
}
