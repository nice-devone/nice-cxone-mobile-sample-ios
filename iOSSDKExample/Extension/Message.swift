import Foundation
import CXOneChatSDK
import MessageKit
import UIKit

extension Message: MessageType {

    public var sender: SenderType {
        return self.senderInfo
    }
    
    /// The unique identifier for the message.
    public var messageId: String {
        return self.idOnExternalPlatform.uuidString
    }

    /// The date the message was sent.
    public var sentDate: Date {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        return dateFormatter.date(from: self.createdAt) ?? Date()
    }

    /// The kind of message and its underlying kind.
    public var kind: MessageKind {
        if !self.attachments.isEmpty {
            let messageMedia = MessageMediaItem(messageAttachment: self.attachments[0])
            if self.attachments.first?.mimeType == "video/mp4" {
                return .video(messageMedia)
            }
            return .photo(messageMedia)
        } else if self.messageContent.type == .plugin {
            return .custom(MyCustomCell())
        }
        return .text(self.messageContent.payload.text)
    }
}

extension SenderInfo: SenderType {
    public var senderId: String {
        return self.id
    }

    public var displayName: String {
        return self.fullName
    }
}

open class MyCustomCell: UICollectionViewCell {
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        self.contentView.backgroundColor = UIColor.red
    }
}

//open class CustomMessageSizeCalculator: MessageSizeCalculator {
//    open override func messageContainerSize(for message: MessageType) -> CGSize {
//    // Customize this function implementation to size your content appropriately. This example simply returns a constant size
//    // Refer to the default MessageKit cell implementations, and the Example App to see how to size a custom cell dynamically
//        return CGSize(width: 300, height: 130)
//    }
//}
