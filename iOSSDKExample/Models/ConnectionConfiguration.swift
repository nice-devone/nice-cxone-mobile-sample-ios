import Foundation
import SwiftUI
import CXOneChatSDK

struct ConnectionConfiguration: Codable {
    var environment: CXOneChatSDK.Environment?
    var chatUrl = ""
    var socketUrl = ""
    var brandId: Int
    var channelId: String
    var isCustomEnvironment: Bool {
        return self.environment == nil
    }

    init(connectionConfigurationType: ConnectionConfigurationType) {
        switch(connectionConfigurationType) {
        case .CD, .Sales: // TODO: Update this once there is a sales configuration
            environment = .NA1
            brandId = 1386
            channelId = "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
        case .MJ:
            chatUrl = "https://channels-eu1-qa.brandembassy.com/chat"
            socketUrl = "wss://chat-gateway-eu1-qa.brandembassy.com"
            brandId = 6427
            channelId = "chat_e1c49ed7-f301-4241-90a2-09502b241a4a"
        }
    }
    
    init(connectionEnvironmentType: ConnectionEnvironmentType) {
        switch(connectionEnvironmentType) {
        case .NA1:
            environment = .NA1
        case .QA:
            chatUrl = "https://channels-eu1-qa.brandembassy.com/chat"
            socketUrl = "wss://chat-gateway-eu1-qa.brandembassy.com"
        }
        brandId = 0
        channelId = ""
    }
    
}

enum ConnectionConfigurationType {
    case CD
    case MJ
    case Sales
}

enum ConnectionEnvironmentType {
    case QA
    case NA1
}
