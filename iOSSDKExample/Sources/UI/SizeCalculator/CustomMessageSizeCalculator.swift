import CXoneChatSDK
import MessageKit
import UIKit


class CustomMessageSizeCalculator: MessageSizeCalculator {
    
    // MARK: - Properties
    
    private static let buttonHeight: CGFloat = 50
    private static let titleHeight: CGFloat = 40
    private static let textHeight: CGFloat = 50
    
    
    // MARK: - Init
    
    public override init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        
        self.layout = layout
    }
    
    // MARK: - Methods
    
    override func messageContainerSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        guard let layout = layout else {
            return .zero
        }
        
        let maxWidth = messageContainerMaxWidth(for: message, at: indexPath)
        
        let contentInset = layout.collectionView?.contentInset ?? .zero
        
        let inset = layout.sectionInset.left + layout.sectionInset.right + contentInset.left + contentInset.right
        
        guard case .custom(let entity) = message.kind, let plugin = entity as? MessagePayload else {
            return CGSize(width: ((maxWidth) - inset), height: ((maxWidth / 2) - inset))
        }
        
        return CGSize(width: ((maxWidth) - inset), height: calculateHeight(from: plugin.element, maxWidth: maxWidth, inset: inset))
    }
}


// MARK: - Private methods

private extension CustomMessageSizeCalculator {

    func calculateHeight(from entity: PluginMessageType, maxWidth: CGFloat, inset: CGFloat) -> CGFloat {
        switch entity {
        case .quickReplies(let entity):
            return calculateSubElementsHeight(entity.elements) + inset
        case .textAndButtons(let entity):
            return calculateSubElementsHeight(entity.elements) + inset
        case .satisfactionSurvey(let entity):
            return calculateSubElementsHeight(entity.elements) + inset
        case .menu(let entity):
            return calculateSubElementsHeight(entity.elements) + inset
        case .subElements(let entities):
            return calculateSubElementsHeight(entities) + inset
        case .gallery(let entities):
            var elementsHeight: CGFloat = 0
            
            entities.forEach { entity in
                elementsHeight += calculateHeight(from: entity, maxWidth: maxWidth, inset: inset)
            }
            
            return elementsHeight / CGFloat(entities.count)
        case .custom(let entity):
            if let buttons = entity.variables["buttons"] as? [[String: Any]] {
                return CGFloat(buttons.count) * Self.buttonHeight + inset
            } else {
                return (maxWidth / 2) - inset
            }
        }
    }
    
    func calculateSubElementsHeight(_ elements: [PluginMessageSubElementType]) -> CGFloat {
        var elementsHeight: CGFloat = 0
        
        elements.forEach { element in
            switch element {
            case .text:
                elementsHeight += Self.textHeight
            case .file:
                elementsHeight += PluginMessageView.fileImageHeight
            case .title:
                elementsHeight += Self.titleHeight
            case .button:
                elementsHeight += Self.buttonHeight
            }
        }
        
        return elementsHeight
    }
}
