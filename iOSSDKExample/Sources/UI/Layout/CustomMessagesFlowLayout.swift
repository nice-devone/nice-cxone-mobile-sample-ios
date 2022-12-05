import MessageKit
import UIKit


open class CustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    
    // MARK: - Properties
    
    open lazy var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)
    
    
    // MARK: - Methods
    
    open override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        guard !isSectionReservedForTypingIndicator(indexPath.section) else {
            return typingIndicatorSizeCalculator
        }
        guard case .custom = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView).kind else {
            return super.cellSizeCalculatorForItem(at: indexPath)
        }
        
        return customMessageSizeCalculator
    }
    
    open override func messageSizeCalculators() -> [MessageSizeCalculator] {
        var superCalculators = super.messageSizeCalculators()
        superCalculators.append(customMessageSizeCalculator)
        
        return superCalculators
    }
}
