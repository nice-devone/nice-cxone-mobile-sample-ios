import Foundation
import MessageKit
import CXOneChatSDK
import SwiftUI

class MessageMediaItem: MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    init(messageAttachment: Attachment) {
        let imageUrl = URL(string: messageAttachment.url)
        url = imageUrl
        size = CGSize(width: 240, height: 240)
        placeholderImage = UIImage()
    }
}
