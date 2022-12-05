import UIKit


enum Assets {
    static let btnLWA_Drkgry_46x48Pressed: UIImage = .image(named: "btnLWA_Drkgry_46x48_Pressed")
    static let btnLWA_Drkgry_46x48: UIImage = .image(named: "btnLWA_Drkgry_46x48")
    static let btnLWA_Drkgry_102x48Pressed: UIImage = .image(named: "btnLWA_Drkgry_102x48_Pressed")
    static let btnLWA_Drkgry_102x48: UIImage = .image(named: "btnLWA_Drkgry_102x48")
    static let btnLWA_drkgry_209x48pressed: UIImage = .image(named: "btnLWA_drkgry_209x48_pressed")
    static let btnLWA_drkgry_209x48: UIImage = .image(named: "btnLWA_drkgry_209x48")
    static let btnLWA_Gold_46x48Pressed: UIImage = .image(named: "btnLWA_Gold_46x48_Pressed")
    static let btnLWA_Gold_46x48: UIImage = .image(named: "btnLWA_Gold_46x48")
    static let btnLWA_Gold_102x48Pressed: UIImage = .image(named: "btnLWA_Gold_102x48_Pressed")
    static let btnLWA_Gold_102x48: UIImage = .image(named: "btnLWA_Gold_102x48")
    static let btnLWA_gold_209x48pressed: UIImage = .image(named: "btnLWA_gold_209x48_pressed")
    static let btnLWA_gold_209x48: UIImage = .image(named: "btnLWA_gold_209x48")
    static let btnLWA_Gry_46x48Pressed: UIImage = .image(named: "btnLWA_Gry_46x48_Pressed")
    static let btnLWA_Gry_46x48: UIImage = .image(named: "btnLWA_Gry_46x48")
    static let btnLWA_Gry_102x48Pressed: UIImage = .image(named: "btnLWA_Gry_102x48_Pressed")
    static let btnLWA_Gry_102x48: UIImage = .image(named: "btnLWA_Gry_102x48")
    static let btnLWA_gry_209x48Pressed: UIImage = .image(named: "btnLWA_gry_209x48_pressed")
    static let btnLWA_gry_209x48: UIImage = .image(named: "btnLWA_gry_209x48")
    static let check: UIImage = .image(named: "check")
    static let icAt: UIImage = .image(named: "ic_at")
    static let icBold: UIImage = .image(named: "ic_bold")
    static let icCamera: UIImage = .image(named: "ic_camera")
    static let icCode: UIImage = .image(named: "ic_code")
    static let icEye: UIImage = .image(named: "ic_eye")
    static let icHashtag: UIImage = .image(named: "ic_hashtag")
    static let icItalic: UIImage = .image(named: "ic_italic")
    static let icKeyboard: UIImage = .image(named: "ic_keyboard")
    static let icLibrary: UIImage = .image(named: "ic_library")
    static let icLink: UIImage = .image(named: "ic_link")
    static let icList: UIImage = .image(named: "ic_list")
    static let icPlus: UIImage = .image(named: "ic_plus")
    static let icSend: UIImage = .image(named: "ic_send")
    static let icUp: UIImage = .image(named: "ic_up")
    static let icUpload: UIImage = .image(named: "ic_upload")
    static let icUser: UIImage = .image(named: "ic_user")
    static let icons8Collapse: UIImage = .image(named: "icons8-collapse")
    static let icons8Expand: UIImage = .image(named: "icons8-expand")
    static let readed: UIImage = .image(named: "readed")
    
    static let pencil: UIImage = .systemImage(named: "pencil")
    static let squareAndPencil: UIImage = .systemImage(named: "square.and.pencil")
}


// MARK: - Helpers

private extension UIImage {
    
    class BundleClass: Bundle { }
    
    static func image(named: String) -> UIImage {
        guard let image = UIImage(named: named, in: BundleClass.main, with: nil) else {
            fatalError("\(#function) failed: could not init image with name - \(named)")
        }
        
        return image
    }
    
    static func systemImage(named: String) -> UIImage {
        guard let image = UIImage(systemName: named) else {
            fatalError("\(#function) failed: could not init image with name - \(named)")
        }
        
        return image
    }
}
