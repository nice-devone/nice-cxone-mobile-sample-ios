// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Colors {
    internal enum ChatDefaultTheme {
      internal enum Background {
        internal static let defaultDark = ColorAsset(name: "background/defaultDark")
        internal static let defaultLight = ColorAsset(name: "background/defaultLight")
        internal static let inverseDark = ColorAsset(name: "background/inverseDark")
        internal static let inverseLight = ColorAsset(name: "background/inverseLight")
        internal enum Surface {
          internal static let containerDark = ColorAsset(name: "background/surface/containerDark")
          internal static let containerLight = ColorAsset(name: "background/surface/containerLight")
          internal static let defaultDark = ColorAsset(name: "background/surface/defaultDark")
          internal static let defaultLight = ColorAsset(name: "background/surface/defaultLight")
          internal static let emphasisDark = ColorAsset(name: "background/surface/emphasisDark")
          internal static let emphasisLight = ColorAsset(name: "background/surface/emphasisLight")
          internal static let subtleDark = ColorAsset(name: "background/surface/subtleDark")
          internal static let subtleLight = ColorAsset(name: "background/surface/subtleLight")
          internal static let variantDark = ColorAsset(name: "background/surface/variantDark")
          internal static let variantLight = ColorAsset(name: "background/surface/variantLight")
        }
      }
      internal enum Border {
        internal static let defaultDark = ColorAsset(name: "border/defaultDark")
        internal static let defaultLight = ColorAsset(name: "border/defaultLight")
        internal static let subtleDark = ColorAsset(name: "border/subtleDark")
        internal static let subtleLight = ColorAsset(name: "border/subtleLight")
      }
      internal enum Brand {
        internal static let onPrimaryContainerDark = ColorAsset(name: "brand/onPrimaryContainerDark")
        internal static let onPrimaryContainerLight = ColorAsset(name: "brand/onPrimaryContainerLight")
        internal static let onPrimaryDark = ColorAsset(name: "brand/onPrimaryDark")
        internal static let onPrimaryLight = ColorAsset(name: "brand/onPrimaryLight")
        internal static let onSecondaryContainerDark = ColorAsset(name: "brand/onSecondaryContainerDark")
        internal static let onSecondaryContainerLight = ColorAsset(name: "brand/onSecondaryContainerLight")
        internal static let onSecondaryDark = ColorAsset(name: "brand/onSecondaryDark")
        internal static let onSecondaryLight = ColorAsset(name: "brand/onSecondaryLight")
        internal static let primaryContainerDark = ColorAsset(name: "brand/primaryContainerDark")
        internal static let primaryContainerLight = ColorAsset(name: "brand/primaryContainerLight")
        internal static let primaryDark = ColorAsset(name: "brand/primaryDark")
        internal static let primaryLight = ColorAsset(name: "brand/primaryLight")
        internal static let secondaryContainerDark = ColorAsset(name: "brand/secondaryContainerDark")
        internal static let secondaryContainerLight = ColorAsset(name: "brand/secondaryContainerLight")
        internal static let secondaryDark = ColorAsset(name: "brand/secondaryDark")
        internal static let secondaryLight = ColorAsset(name: "brand/secondaryLight")
      }
      internal enum Content {
        internal static let inverseDark = ColorAsset(name: "content/inverseDark")
        internal static let inverseLight = ColorAsset(name: "content/inverseLight")
        internal static let primaryDark = ColorAsset(name: "content/primaryDark")
        internal static let primaryLight = ColorAsset(name: "content/primaryLight")
        internal static let secondaryDark = ColorAsset(name: "content/secondaryDark")
        internal static let secondaryLight = ColorAsset(name: "content/secondaryLight")
        internal static let tertiaryDark = ColorAsset(name: "content/tertiaryDark")
        internal static let tertiaryLight = ColorAsset(name: "content/tertiaryLight")
      }
      internal enum Status {
        internal static let errorContainerDark = ColorAsset(name: "status/errorContainerDark")
        internal static let errorContainerLight = ColorAsset(name: "status/errorContainerLight")
        internal static let errorDark = ColorAsset(name: "status/errorDark")
        internal static let errorLight = ColorAsset(name: "status/errorLight")
        internal static let onErrorContainerDark = ColorAsset(name: "status/onErrorContainerDark")
        internal static let onErrorContainerLight = ColorAsset(name: "status/onErrorContainerLight")
        internal static let onErrorDark = ColorAsset(name: "status/onErrorDark")
        internal static let onErrorLight = ColorAsset(name: "status/onErrorLight")
        internal static let onSuccessContainerDark = ColorAsset(name: "status/onSuccessContainerDark")
        internal static let onSuccessContainerLight = ColorAsset(name: "status/onSuccessContainerLight")
        internal static let onSuccessDark = ColorAsset(name: "status/onSuccessDark")
        internal static let onSuccessLight = ColorAsset(name: "status/onSuccessLight")
        internal static let onWarningContainerDark = ColorAsset(name: "status/onWarningContainerDark")
        internal static let onWarningContainerLight = ColorAsset(name: "status/onWarningContainerLight")
        internal static let onWarningDark = ColorAsset(name: "status/onWarningDark")
        internal static let onWarningLight = ColorAsset(name: "status/onWarningLight")
        internal static let successContainerDark = ColorAsset(name: "status/successContainerDark")
        internal static let successContainerLight = ColorAsset(name: "status/successContainerLight")
        internal static let successDark = ColorAsset(name: "status/successDark")
        internal static let successLight = ColorAsset(name: "status/successLight")
        internal static let warningContainerDark = ColorAsset(name: "status/warningContainerDark")
        internal static let warningContainerLight = ColorAsset(name: "status/warningContainerLight")
        internal static let warningDark = ColorAsset(name: "status/warningDark")
        internal static let warningLight = ColorAsset(name: "status/warningLight")
      }
    }
  }
  internal enum Images {
    internal static let accentColor = ColorAsset(name: "AccentColor")
    internal static let launchScreenLogo = ImageAsset(name: "launchScreenLogo")
    internal static let logoGoogleG = ImageAsset(name: "logoGoogleG")
    internal static let masterCard = ImageAsset(name: "masterCard")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
