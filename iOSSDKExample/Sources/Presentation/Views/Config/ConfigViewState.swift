import Foundation


enum ConfigViewState: HasInitial {
    case loading(String?)
    case loaded(ConfigVO)
    case error(title: String, message: String)
    
    static var initial: ConfigViewState = .loading("Fetching configurations...")
}


// MARK: - Queries

extension ConfigViewState {
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}


// MARK: - Commands

extension ConfigViewState {
    
    mutating func toLoading(title: String? = nil) {
        self = .loading(title)
    }
    
    mutating func toLoaded(documentState: ConfigPresenter.DocumentState) {
        self = .loaded(
            ConfigVO(
                isCustomConfigurationHidden: documentState.isCustomConfigurationHidden,
                configurations: documentState.configurations,
                currentConfiguration: documentState.currentConfiguration
            )
        )
    }
    
    mutating func toError(title: String, message: String? = nil) {
        self = .error(title: title, message: message ?? "")
    }
}
