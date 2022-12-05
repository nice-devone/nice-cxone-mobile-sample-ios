import CXoneChatSDK
import MessageKit
import UIKit


class MessageMediaItem: MediaItem {
    
    // MARK: - Properties
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    
    // MARK: - Init
    
    init(messageAttachment: Attachment) {
        self.url = URL(string: messageAttachment.url)
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
}
