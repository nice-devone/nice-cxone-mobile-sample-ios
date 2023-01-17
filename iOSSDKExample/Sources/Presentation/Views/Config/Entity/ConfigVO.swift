import Foundation


/// The ViewObject for the Config view.
struct ConfigVO {
    let isCustomConfigurationHidden: Bool
    let configurations: [Configuration]
    var currentConfiguration: Configuration
}
