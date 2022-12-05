import Foundation


extension Optional where Wrapped == String {
    
    func mapNonEmpty(_ transform: (String) throws -> String) rethrows -> String? {
        try? self.map { value -> String in
            guard value != "" else {
                throw CommonError.unableToParse("value")
            }
            
            return value
        }
    }
}
