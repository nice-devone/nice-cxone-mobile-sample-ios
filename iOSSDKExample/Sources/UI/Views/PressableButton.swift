import UIKit


@IBDesignable
open class PressableButton: UIButton {

    // MARK: - Constaints
    
	public enum Defaults {
		public static var colors = ColorSet(button: UIColor(rgb: 52, 152, 219), shadow: UIColor(rgb: 41, 128, 185))
		public static var disabledColors = ColorSet(button: UIColor(rgb: 41, 128, 185), shadow: UIColor(rgb: 127, 140, 141))
		public static var shadowHeight: CGFloat = 3
		public static var depth: Double = 0.7
		public static var cornerRadius: CGFloat = 3
	}
	
	public struct ColorSet {
		let button: UIColor
		let shadow: UIColor
		
		public init(button: UIColor, shadow: UIColor) {
			self.button = button
			self.shadow = shadow
		}
	}
	
    
    // MARK: - Properties
    
	public var colors: ColorSet = Defaults.colors {
		didSet { updateBackgroundImages() }
	}
	public var disabledColors: ColorSet = Defaults.disabledColors {
		didSet { updateBackgroundImages() }
	}
	@IBInspectable
	public var shadowHeight: CGFloat = Defaults.shadowHeight {
		didSet { updateBackgroundImages() }
	}
	@IBInspectable
	public var buttonDepth: Double = Defaults.depth {
		didSet { updateBackgroundImages() }
	}
	@IBInspectable
	public var cornerRadius: CGFloat = Defaults.cornerRadius {
		didSet { updateBackgroundImages() }
	}
    
	
	// MARK: - UIButton
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
        
		updateBackgroundImages()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
        updateBackgroundImages()
	}
}


// MARK: - Private methods

private extension PressableButton {
    
	func updateBackgroundImages() {
        let normalImage: UIImage = .buttonImage(
            color: colors.button,
            shadowHeight: shadowHeight,
            shadow: colors.shadow,
            cornerRadius: cornerRadius)
        let highlightedImage: UIImage = .buttonImage(
            color: colors.button,
            shadowHeight: shadowHeight,
            shadow: colors.shadow,
            cornerRadius: cornerRadius,
            offset: shadowHeight * CGFloat(buttonDepth))
        let disabledImage: UIImage = .buttonImage(
            color: disabledColors.button,
            shadowHeight: shadowHeight,
            shadow: disabledColors.shadow,
            cornerRadius: cornerRadius
        )
		
		setBackgroundImage(normalImage, for: .normal)
		setBackgroundImage(highlightedImage, for: .highlighted)
		setBackgroundImage(disabledImage, for: .disabled)
	}
}


// MARK: - Helpers

private extension UIImage {

    static func buttonImage(color: UIColor, shadowHeight: CGFloat, shadow: UIColor, cornerRadius: CGFloat, offset: CGFloat = 0) -> UIImage {
		// Create foreground and background images
		let width = max(1, cornerRadius * 2 + shadowHeight)
		let height = max(1, cornerRadius * 2 + shadowHeight)
		let size = CGSize(width: width, height: height)
			
        let frontImage = image(color: color, size: size, cornerRadius: cornerRadius)
        let backImage = shadowHeight != 0 ? image(color: shadow, size: size, cornerRadius: cornerRadius) : nil
		let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height + shadowHeight)
		
		// Draw background image then foreground image
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
		backImage?.draw(at: CGPoint(x: 0, y: shadowHeight))
		frontImage.draw(at: CGPoint(x: 0, y: offset))
		let nonResizableImage = UIGraphicsGetImageFromCurrentImageContext()
        
		UIGraphicsEndImageContext()
		
		// Create resizable image
		let capInsets = UIEdgeInsets(
            top: cornerRadius + offset,
            left: cornerRadius,
            bottom: cornerRadius + shadowHeight - offset,
            right: cornerRadius
        )
        
        return nonResizableImage?.resizableImage(withCapInsets: capInsets, resizingMode: .stretch) ?? UIImage()
	}
	
	static func image(color: UIColor, size: CGSize, cornerRadius: CGFloat) -> UIImage {
		let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
		
		// Create a non-rounded image
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
		let context = UIGraphicsGetCurrentContext()
		context?.setFillColor(color.cgColor)
		context?.fill(rect)
		let nonRoundedImage = UIGraphicsGetImageFromCurrentImageContext()
        
		UIGraphicsEndImageContext()
		
		// Clip it with a bezier path
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
		nonRoundedImage?.draw(in: rect)
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
        
		UIGraphicsEndImageContext()
		
		return image ?? UIImage()
	}
}
