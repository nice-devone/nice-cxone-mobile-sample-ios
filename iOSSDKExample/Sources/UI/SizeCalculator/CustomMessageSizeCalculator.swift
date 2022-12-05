import MessageKit
import UIKit


open class CustomMessageSizeCalculator: MessageSizeCalculator {
    
    // MARK: - Init
    
    public override init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        
        self.layout = layout
    }
    
    
    // MARK: - Methods
    
    open override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        guard let layout = layout else {
            return .zero
        }
        
        let collectionViewWidth = layout.collectionView?.bounds.width ?? 0
        let contentInset = layout.collectionView?.contentInset ?? .zero
        let inset = layout.sectionInset.left + layout.sectionInset.right + contentInset.left + contentInset.right
        
        return CGSize(width: collectionViewWidth - inset, height: 300)
    }
}
