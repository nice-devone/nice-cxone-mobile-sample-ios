import UIKit


public enum PopupPosition {
    /// Align center X, center Y with offset param
    case center(CGPoint?)
    
    /// Top left anchor point with offset param
    case topLeft(CGPoint?)
    
    /// Top right anchor point with offset param
    case topRight(CGPoint?)
    
    /// Bottom left anchor point with offset param
    case bottomLeft(CGPoint?)
    
    /// Bottom right anchor point with offset param
    case bottomRight(CGPoint?)
    
    /// Top anchor, align center X with top padding param
    case top(CGFloat)
    
    /// Left anchor, align center Y with left padding param
    case left(CGFloat)
    
    /// Bottom anchor, align center X with bottom padding param
    case bottom(CGFloat)
    
    /// Right anchor, align center Y with right padding param
    case right(CGFloat)
    
    /// Top left offset to a view
    case offsetFromView(CGPoint? = nil, UIView)
}
