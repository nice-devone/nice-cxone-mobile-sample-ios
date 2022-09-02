import Foundation
import CXOneChatSDK
import MessageKit

extension Customer: SenderType {
    public var senderId: String {
        return self.id
    }
    
    public var displayName: String {
        return self.fullName
    }
}
