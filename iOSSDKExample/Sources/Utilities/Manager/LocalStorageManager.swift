import Foundation


struct LocalStorageManager {
    
    // MARK: - Keys
    
    enum Keys: String {
        case configuration
    }
    
    
    // MARK: - Properties
    
    @Storage(key: .configuration)
    static var configuration: Configuration?
}


// MARK: - Helpers

@propertyWrapper
struct Storage<T: Codable> {
    
    // MARK: - Properties
    
    private let key: LocalStorageManager.Keys

    var wrappedValue: T? {
        get {
            guard let data = UserDefaults.standard.object(forKey: key.rawValue) as? Data else {
                return nil
            }

            return try? JSONDecoder().decode(T.self, from: data)
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            
            UserDefaults.standard.set(data, forKey: key.rawValue)
        }
    }
    
    
    // MARK: - Init
    
    init(key: LocalStorageManager.Keys) {
        self.key = key
    }
}
