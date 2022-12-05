import CXoneChatSDK
import Foundation


enum MessageMapper {
    
    static func updateOldMessage(_ oldMessage: Message, attachments: [Attachment]) -> Message {
        .init(
            id: UUID(),
            threadId: oldMessage.threadId,
            messageContent: oldMessage.messageContent,
            createdAt: oldMessage.createdAt,
            attachments: attachments,
            direction: oldMessage.direction,
            userStatistics: oldMessage.userStatistics,
            authorUser: oldMessage.authorUser,
            authorEndUserIdentity: oldMessage.authorEndUserIdentity
        )
    }
}
