import UIKit


extension UIColor {
    
    // MARK: - Properties
    
    static let primaryColor = UIColor.systemBlue
    
    
    // MARK: - Init
    
    convenience init(rgb red: CGFloat, _ green: CGFloat, _ blue: CGFloat, alpha: CGFloat = 1) {
            self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
        }
}
