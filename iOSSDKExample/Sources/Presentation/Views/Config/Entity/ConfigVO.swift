import Foundation


struct ConfigVO {
    let isCustomConfigurationHidden: Bool
    let configurations: [ConnectionConfiguration]
    let environmnets: [ConnectionConfiguration]
    let selectedConfiguration: ConnectionConfiguration
}
