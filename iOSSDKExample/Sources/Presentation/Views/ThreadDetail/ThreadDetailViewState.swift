import Foundation


enum ThreadDetailViewState: HasInitial {
    case loading(title: String?)
    case loaded
    case error(title: String, message: String)
    
    static var initial: ThreadDetailViewState = .loading(title: nil)
}

// MARK: - Queries

extension ThreadDetailViewState {
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}


// MARK: - Commands

extension ThreadDetailViewState {
    
    mutating func toLoading(title: String? = nil) {
        self = .loading(title: title)
    }
    
    mutating func toLoaded() {
        self = .loaded
    }
    
    mutating func toError(title: String, message: String? = nil) {
        self = .error(title: title, message: message ?? "")
    }
}
