import Foundation


// MARK: - CodableIgnored

@propertyWrapper
struct CodableIgnored<T>: Codable {
    var wrappedValue: T?

    init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        self.wrappedValue = nil
    }

    func encode(to encoder: Encoder) throws {
        // Do nothing
    }
}


// MARK: - KeyedDecodingContainer

extension KeyedDecodingContainer {
    
    func decode<T>(_ type: CodableIgnored<T>.Type, forKey key: Self.Key) throws -> CodableIgnored<T> {
        CodableIgnored(wrappedValue: nil)
    }
}


// MARK: - KeyedEncodingContainer

extension KeyedEncodingContainer {
    
    mutating func encode<T>(_ value: CodableIgnored<T>, forKey key: KeyedEncodingContainer<K>.Key) throws { }
}
