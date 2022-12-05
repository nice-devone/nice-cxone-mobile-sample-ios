import Foundation


extension Task where Success == Never, Failure == Never {
    
    static func sleep(seconds: Double) async {
        do {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        } catch {
            print("\(#function) failed: \(error.localizedDescription)")
        }
    }
}
