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
        let message: String
        
        switch contentType {
        case .text(let text):
            message = text.mapNonEmpty { $0 } ?? ""
        case .plugin(let plugin):
            message = plugin.text?.mapNonEmpty { $0 } ?? ""
        case .unknown:
            message = ""
        }
        
        if let attachment = attachments.first {
            let messageMedia = MessageMediaItem(messageAttachment: attachment)
            
            switch attachment.mimeType {
            case _ where attachment.mimeType.contains("image"):
                return .photo(messageMedia)
            case _ where attachment.mimeType.contains("video"):
                return .video(messageMedia)
            case _ where attachment.mimeType.contains("application/pdf") || attachment.mimeType.contains("text"):
                guard let item = MessageLinkItem(attachment: attachment) else {
                    return .text(message)
                }
                
                return .linkPreview(item)
            default:
                return .photo(messageMedia)
            }
        } else if case .plugin(let entity) = contentType {
            return .custom(entity)
        }
        
        return .text(message)
    }
}
