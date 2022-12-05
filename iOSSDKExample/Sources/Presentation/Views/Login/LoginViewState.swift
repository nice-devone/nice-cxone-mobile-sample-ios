import Foundation


enum LoginViewState: HasInitial {
    case loading
    case loaded(isOAuthHidden: Bool)
    case error(title: String, message: String)
    
    static var initial: LoginViewState = .loaded(isOAuthHidden: true)
}


// MARK: - Queries

extension LoginViewState {
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}


// MARK: - Commands

extension LoginViewState {
    
    mutating func toLoading() {
        self = .loading
    }
    
    mutating func toLoaded(isOAuthHidden: Bool) {
        self = .loaded(isOAuthHidden: isOAuthHidden)
    }
    
    mutating func toError(title: String, message: String? = nil) {
        self = .error(title: title, message: message ?? "")
    }
}
