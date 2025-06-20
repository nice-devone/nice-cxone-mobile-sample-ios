//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sample-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import CXoneChatSDK

class GetChannelConfigurationUseCase {
    
    func callAsFunction(configuration: Configuration) async throws -> ChannelConfiguration {
        guard CXoneChat.shared.state == .initial else {
            // Chat has been prepared, return the current configuration
            return CXoneChat.shared.connection.channelConfiguration
        }
        
        if let environment = configuration.environment {
            return try await CXoneChat.shared.connection.getChannelConfiguration(
                environment: environment,
                brandId: configuration.brandId,
                channelId: configuration.channelId
            )
        } else {
            return try await CXoneChat.shared.connection.getChannelConfiguration(
                chatURL: configuration.chatUrl,
                brandId: configuration.brandId,
                channelId: configuration.channelId
            )
        }
    }
}
