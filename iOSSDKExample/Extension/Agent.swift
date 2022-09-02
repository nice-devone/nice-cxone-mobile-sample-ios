import Foundation
import MessageKit
import CXOneChatSDK

extension Agent: SenderType {
    public var senderId: String {
        return String(self.id)
    }
    
    public var displayName: String {
        return self.fullName
    }
}
