import MessageKit
import UIKit


class CustomLayoutSizeCalculator: CellSizeCalculator {

    // MARK: - Constants
    
    enum Constants {
        static let cellTopLabelVerticalPadding: CGFloat = 32
        static let cellTopLabelHorizontalPadding: CGFloat = 32
        static let cellMessageContainerHorizontalPadding: CGFloat = 48
        static let cellMessageContainerExtraSpacing: CGFloat = 16
        static let cellMessageContentVerticalPadding: CGFloat = 16
        static let cellMessageContentHorizontalPadding: CGFloat = 16
        static let cellDateLabelHorizontalPadding: CGFloat = 24
        static let cellDateLabelBottomPadding: CGFloat = 8
        
    }
    
    
    // MARK: - Properties
    
    var messagesLayout: MessagesCollectionViewFlowLayout {
        guard let layout = layout as? MessagesCollectionViewFlowLayout else {
            return .init()
        }
        
        return layout
    }
    var messageContainerMaxWidth: CGFloat {
        messagesLayout.itemWidth - Constants.cellMessageContainerHorizontalPadding - Constants.cellMessageContainerExtraSpacing
    }
    var messagesDataSource: MessagesDataSource { messagesLayout.messagesDataSource }
    
    
    // MARK: - Init
    
    init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        
        self.layout = layout
    }
    
    
    // MARK: - Methods
    
    override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
        let itemHeight = cellContentHeight(for: message, at: indexPath)
        
        return CGSize(width: messagesLayout.itemWidth, height: itemHeight)
    }
    
    func cellContentHeight(for message: MessageType, at indexPath: IndexPath) -> CGFloat {
        let cellToplabelSize = cellTopLabelSize(for: message, at: indexPath)
        let cellMessageBottomLabelSize = cellMessageBottomLabelSize(for: message, at: indexPath)
        let messageContainerSize = messageContainerSize(for: message, at: indexPath)
        
        return cellToplabelSize.height + cellMessageBottomLabelSize.height + messageContainerSize.height
    }
    
    
    // MARK: - Top cell Label
    
    func cellTopLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        guard let attributedText = messagesDataSource.cellTopLabelAttributedText(for: message, at: indexPath) else {
            return .zero
        }
        
        let maxWidth = messagesLayout.itemWidth - Constants.cellTopLabelHorizontalPadding
        let height = attributedText.size().height + Constants.cellTopLabelVerticalPadding
        
        return CGSize(width: maxWidth, height: height)
    }
    
    func cellTopLabelFrame(for message: MessageType, at indexPath: IndexPath) -> CGRect {
        let size = cellTopLabelSize(for: message, at: indexPath)
        guard size != .zero else {
            return .zero
        }
        
        return CGRect(origin: CGPoint(x: Constants.cellTopLabelHorizontalPadding / 2, y: 0), size: size)
    }
    
    func cellMessageBottomLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        guard let attributedText = messagesDataSource.messageBottomLabelAttributedText(for: message, at: indexPath) else {
            return .zero
        }
        
        return attributedText.size()
    }
    
    func cellMessageBottomLabelFrame(for message: MessageType, at indexPath: IndexPath) -> CGRect {
        let messageContainerSize = messageContainerSize(for: message, at: indexPath)
        let labelSize = cellMessageBottomLabelSize(for: message, at: indexPath)
        let x = messageContainerSize.width - labelSize.width - (Constants.cellDateLabelHorizontalPadding / 2)
        let y = messageContainerSize.height - labelSize.height - Constants.cellDateLabelBottomPadding
        
        return CGRect(origin: CGPoint(x: x, y: y), size: labelSize)
    }
    
    
    // MARK: - MessageContainer
    
    func messageContainerSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        let labelSize = cellMessageBottomLabelSize(for: message, at: indexPath)
        let width = labelSize.width + Constants.cellMessageContentHorizontalPadding + Constants.cellDateLabelHorizontalPadding
        let height = labelSize.height + Constants.cellMessageContentVerticalPadding + Constants.cellDateLabelBottomPadding
        
        return CGSize(width: width, height: height)
    }
    
    func messageContainerFrame(for message: MessageType, at indexPath: IndexPath, fromCurrentSender: Bool) -> CGRect {
        let y = cellTopLabelSize(for: message, at: indexPath).height
        let size = messageContainerSize(for: message, at: indexPath)
        let origin: CGPoint
        
        if fromCurrentSender {
            let x = messagesLayout.itemWidth - size.width - (Constants.cellMessageContainerHorizontalPadding / 2)
            origin = CGPoint(x: x, y: y)
        } else {
            origin = CGPoint(x: Constants.cellMessageContainerHorizontalPadding / 2, y: y)
        }
        
        return CGRect(origin: origin, size: size)
    }
}
