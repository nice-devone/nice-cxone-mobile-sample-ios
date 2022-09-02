import Foundation
import UIKit
import UIKit

@IBDesignable
open class PressableButton: UIButton {
	
	public enum Defaults {
		public static var colors = ColorSet(
			button: UIColor(red: 52 / 255, green: 152 / 255, blue: 219 / 255, alpha: 1),
			shadow: UIColor(red: 41 / 255, green: 128 / 255, blue: 185 / 255, alpha: 1)
		)
		public static var disabledColors = ColorSet(
			button: UIColor(red: 41 / 255, green: 128 / 255, blue: 185 / 255, alpha: 1),
			shadow: UIColor(red: 127 / 255, green: 140 / 255, blue: 141 / 255, alpha: 1)
		)
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
	
	public var colors: ColorSet = Defaults.colors {
		didSet {
			updateBackgroundImages()
		}
	}
	
	public var disabledColors: ColorSet = Defaults.disabledColors {
		didSet {
			updateBackgroundImages()
		}
	}
	
	@IBInspectable
	public var shadowHeight: CGFloat = Defaults.shadowHeight {
		didSet {
			updateBackgroundImages()
			updateTitleInsets()
			updateImageInsets()
		}
	}
	
	@IBInspectable
	public var buttonDepth: Double = Defaults.depth {
		didSet {
			updateBackgroundImages()
			updateTitleInsets()
			updateImageInsets()
		}
	}
	
	@IBInspectable
	public var cornerRadius: CGFloat = Defaults.cornerRadius {
		didSet {
			updateBackgroundImages()
		}
	}
	
	open override var titleEdgeInsets: UIEdgeInsets {
		didSet {
			updateTitleInsets()
		}
	}
	
	open override var imageEdgeInsets: UIEdgeInsets {
		didSet {
			updateImageInsets()
		}
	}
	
	// MARK: - UIButton
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
		updateBackgroundImages()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		configure()
		updateBackgroundImages()
	}
	
	override open var isHighlighted: Bool {
		didSet {
			updateTitleInsets()
			updateImageInsets()
		}
	}
	
	// MARK: - Internal methods
	
	func configure() {
//		adjustsImageWhenDisabled = false
//		adjustsImageWhenHighlighted = false
	}
	
	func updateTitleInsets() {
//		let topPadding = isHighlighted ? shadowHeight * CGFloat(buttonDepth) : 0
//		let bottomPadding = isHighlighted ? shadowHeight * (1 - CGFloat(buttonDepth)) : shadowHeight
//		super.titleEdgeInsets = UIEdgeInsets(top: topPadding, left: titleEdgeInsets.left, bottom: bottomPadding, right: titleEdgeInsets.right)
	}
	
	func updateImageInsets() {
//		let topPadding = isHighlighted ? shadowHeight * CGFloat(buttonDepth) : 0
//		let bottomPadding = isHighlighted ? shadowHeight * (1 - CGFloat(buttonDepth)) : shadowHeight
//		super.imageEdgeInsets = UIEdgeInsets(top: topPadding, left: imageEdgeInsets.left, bottom: bottomPadding, right: imageEdgeInsets.right)
	}
	
	fileprivate func updateBackgroundImages() {
		
		let normalImage = Utils.buttonImage(color: colors.button, shadowHeight: shadowHeight, shadowColor: colors.shadow, cornerRadius: cornerRadius)
		let highlightedImage = Utils.highlightedButtonImage(color: colors.button, shadowHeight: shadowHeight, shadowColor: colors.shadow, cornerRadius: cornerRadius, buttonPressDepth: buttonDepth)
		let disabledImage = Utils.buttonImage(color: disabledColors.button, shadowHeight: shadowHeight, shadowColor: disabledColors.shadow, cornerRadius: cornerRadius)
		
		setBackgroundImage(normalImage, for: .normal)
		setBackgroundImage(highlightedImage, for: .highlighted)
		setBackgroundImage(disabledImage, for: .disabled)
	}
}


enum Utils {
	
	static func buttonImage(
		color: UIColor,
		shadowHeight: CGFloat,
		shadowColor: UIColor,
		cornerRadius: CGFloat) -> UIImage {
		
		return buttonImage(color: color, shadowHeight: shadowHeight, shadowColor: shadowColor, cornerRadius: cornerRadius, frontImageOffset: 0)
	}
	
	static func highlightedButtonImage(
		color: UIColor,
		shadowHeight: CGFloat,
		shadowColor: UIColor,
		cornerRadius: CGFloat,
		buttonPressDepth: Double) -> UIImage {
		
		return buttonImage(color: color, shadowHeight: shadowHeight, shadowColor: shadowColor, cornerRadius: cornerRadius, frontImageOffset: shadowHeight * CGFloat(buttonPressDepth))
	}
	
	static func buttonImage(
		color: UIColor,
		shadowHeight: CGFloat,
		shadowColor: UIColor,
		cornerRadius: CGFloat,
		frontImageOffset: CGFloat) -> UIImage {
		
		// Create foreground and background images
		let width = max(1, cornerRadius * 2 + shadowHeight)
		let height = max(1, cornerRadius * 2 + shadowHeight)
		let size = CGSize(width: width, height: height)
			
		let frontImage = image(color: color, size: size, cornerRadius: cornerRadius)
		var backImage: UIImage? = nil
		if shadowHeight != 0 {
			backImage = image(color: shadowColor, size: size, cornerRadius: cornerRadius)
		}
		
		let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height + shadowHeight)
		
		// Draw background image then foreground image
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
		backImage?.draw(at: CGPoint(x: 0, y: shadowHeight))
		frontImage.draw(at: CGPoint(x: 0, y: frontImageOffset))
		let nonResizableImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		// Create resizable image
		let capInsets = UIEdgeInsets(top: cornerRadius + frontImageOffset, left: cornerRadius, bottom: cornerRadius + shadowHeight - frontImageOffset, right: cornerRadius)
		let resizableImage = nonResizableImage?.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
			
		return resizableImage ?? UIImage()
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
		UIBezierPath(
			roundedRect: rect,
			cornerRadius: cornerRadius
		).addClip()
		nonRoundedImage?.draw(in: rect)
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image ?? UIImage()
	}
}
