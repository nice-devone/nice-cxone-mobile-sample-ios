import Foundation


enum ThreadListViewState: HasInitial {
    case loading
    case loaded(ThreadListVO)
    case error(title: String, message: String)
    
    static var initial: ThreadListViewState = .loading
}


// MARK: - Queries

extension ThreadListViewState {
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}


// MARK: - Commands

extension ThreadListViewState {
    
    mutating func toLoading() {
        self = .loading
    }
    
    mutating func toLoaded(documentState: ThreadListPresenter.DocumentState) {
        self = .loaded(.init(threads: documentState.threads, isMultiThread: documentState.isMultiThread))
    }
    
    mutating func toError(title: String, message: String? = nil) {
        self = .error(title: title, message: message ?? "")
    }
}
