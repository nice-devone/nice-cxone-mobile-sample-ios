import CXoneChatSDK
import MessageKit
import UIKit


extension Message: MessageType {

    public var sender: SenderType { senderInfo }
    
    /// The unique identifier for the message.
    public var messageId: String { id.uuidString }

    /// The date the message was sent.
    public var sentDate: Date { createdAt }

    /// The kind of message and its underlying kind.
    public var kind: MessageKind {
        if !attachments.isEmpty {
            let messageMedia = MessageMediaItem(messageAttachment: attachments[0])
            
            if attachments.first?.mimeType == "video/mp4" {
                return .video(messageMedia)
            }
            
            return .photo(messageMedia)
        } else if messageContent.type == .plugin {
            return .custom(UICollectionViewCell())
        }
        
        return .text(messageContent.payload.text)
    }
}
