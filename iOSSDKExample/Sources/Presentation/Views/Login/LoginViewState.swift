import Foundation


enum LoginViewState: HasInitial {
    case loading
    case loaded(LoginPresenter.DocumentState)
    case error(title: String, message: String)
    
    static var initial: LoginViewState = .loading
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
    
    mutating func toLoaded(documentState: LoginPresenter.DocumentState) {
        self = .loaded(documentState)
    }
    
    mutating func toError(title: String, message: String? = nil) {
        self = .error(title: title, message: message ?? "")
    }
}
