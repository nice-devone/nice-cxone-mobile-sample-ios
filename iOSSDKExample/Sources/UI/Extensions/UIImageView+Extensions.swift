import UIKit


extension UIImageView {
    
    func load(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            
            guard let image = UIImage(data: data) else {
                Log.error("could not init UIImage from Data.")
                return
            }
            
            self.image = image
        } catch {
            error.logError()
        }
    }
}
