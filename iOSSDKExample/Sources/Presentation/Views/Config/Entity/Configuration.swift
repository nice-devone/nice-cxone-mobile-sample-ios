import CXoneChatSDK


/// Entity with configuration defined in the sub repository with brand configurations.
struct Configurations: Decodable {
    let configurations: [Configuration]?
}

struct Configuration: Decodable {
    
    // MARK: - Properties
    
    var title: String
    var brandId: Int
    var channelId: String
    
    var environmentName: String
    var chatUrl: String
    var socketUrl: String
    
    
    // MARK: - Init
    
    init(brandId: Int, channelId: String, environment: CXoneChatSDK.Environment) {
        self.title = environment.rawValue
        self.brandId = brandId
        self.channelId = channelId
        self.environmentName = environment.rawValue
        self.chatUrl = environment.chatURL
        self.socketUrl = environment.socketURL
    }
    
    init(title: String, brandId: Int, channelId: String, environmentName: String, chatUrl: String, socketUrl: String) {
        self.title = title
        self.brandId = brandId
        self.channelId = channelId
        self.environmentName = environmentName
        self.chatUrl = chatUrl
        self.socketUrl = socketUrl
    }
    
    
    // MARK: - Coding
    
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
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let environmentContainer = try container.nestedContainer(keyedBy: EnvironmentKeys.self, forKey: .environment)
        
        self.brandId = try container.decode(Int.self, forKey: .brandId)
        self.channelId = try container.decode(String.self, forKey: .channelId)
        self.title = try container.decode(String.self, forKey: .name)
        self.environmentName = try environmentContainer.decode(String.self, forKey: .name)
        self.socketUrl = try environmentContainer.decode(String.self, forKey: .socketUrl)
        
        let chatUrl = try environmentContainer.decode(String.self, forKey: .chatUrl)
        self.chatUrl = chatUrl.last == "/" ? chatUrl.dropLast().description : chatUrl
    }
}

// MARK: - Helpers

extension Configuration {
    
    var environment: CXoneChatSDK.Environment? {
        switch self.chatUrl {
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
}
