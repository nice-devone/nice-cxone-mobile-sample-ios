import CXoneChatSDK
import SwiftUI


struct ConnectionConfiguration: Codable {
    
    // MARK: - Properties
    
    var environment: CXoneChatSDK.Environment?
    var chatUrl = ""
    var socketUrl = ""
    var brandId: Int
    var channelId: String
    var isCustomEnvironment: Bool { self.environment == nil }

    @CodableIgnored
    var connectionConfigurationType: ConnectionConfigurationType?
    @CodableIgnored
    var connectionEnvironmentType: ConnectionEnvironmentType?
    
    
    // MARK: - Init
    
    init(connectionConfigurationType: ConnectionConfigurationType) {
        self.connectionConfigurationType = connectionConfigurationType
        
        switch connectionConfigurationType {
        case .CD, .Sales:
            environment = .NA1
            brandId = 1386
            channelId = "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
        case .MJ:
            chatUrl = "https://channels-eu1-qa.brandembassy.com/chat"
            socketUrl = "wss://chat-gateway-eu1-qa.brandembassy.com"
            brandId = 6427
            channelId = "chat_e1c49ed7-f301-4241-90a2-09502b241a4a"
        case .LS:
            chatUrl = "https://channels-eu1-qa.brandembassy.com/chat"
            socketUrl = "wss://chat-gateway-eu1-qa.brandembassy.com"
            brandId = 6435
            channelId = "chat_ea02df1d-2f67-44b4-bd44-eb7808df1fdc"
        }
    }
    
    init(connectionEnvironmentType: ConnectionEnvironmentType) {
        self.connectionEnvironmentType = connectionEnvironmentType
        
        switch connectionEnvironmentType {
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
