import Foundation
import InputBarAccessoryView
import UIKit


// MARK: - Protocol

protocol CameraInputBarAccessoryViewDelegate: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment])
}


// MARK: - Implementation

class CameraInputBarAccessoryView: InputBarAccessoryView {
    
    // MARK: - Properties
    
    private var imagePicker: UIImagePickerController?
    
    lazy var attachmentManager: AttachmentManager = { [unowned self] in
        let manager = AttachmentManager()
        manager.delegate = self
        return manager
    }()
    
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let camera = makeButton(named: "ic_camera")
        camera.tintColor = .darkGray
        camera.onTouchUpInside { _ in
            self.showImagePickerControllerActionSheet()
        }
        
        setLeftStackViewWidthConstant(to: 35, animated: true)
        setStackViewItems([camera], forStack: .left, animated: false)
        inputPlugins = [attachmentManager]
    }
    
    
    // MARK: - Methods
    
    override func didSelectSendButton() {
        if !attachmentManager.attachments.isEmpty {
            (delegate as? CameraInputBarAccessoryViewDelegate)?.inputBar(self, didPressSendButtonWith: attachmentManager.attachments)
        } else {
            delegate?.inputBar(self, didPressSendButtonWith: inputTextView.text)
        }
    }
}


// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension CameraInputBarAccessoryView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc
    func showImagePickerControllerActionSheet() {
        let photoLibraryAction = UIAlertAction(title: "Choose From Library", style: .default) { [weak self] _ in
            self?.showImagePickerController(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Take From Camera", style: .default) { [weak self] _ in
            self?.showImagePickerController(sourceType: .camera)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        UIAlertController.show(
            .actionSheet,
            title: "Choose Your Image",
            message: nil,
            actions: [photoLibraryAction, cameraAction, cancelAction]
        )
    }
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        self.imagePicker = controller
        controller.delegate = self
        controller.allowsEditing = true
        controller.sourceType = sourceType
        inputAccessoryView?.isHidden = true
        
        UIApplication.shared.rootViewController?.present(controller, animated: true, completion: nil)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            inputPlugins.forEach { _ = $0.handleInput(of: editedImage) }
        } else if let originImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            inputPlugins.forEach { _ = $0.handleInput(of: originImage) }
        }
        
        imagePicker?.dismiss(animated: true)
        inputAccessoryView?.isHidden = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker?.dismiss(animated: true)
        
        inputAccessoryView?.isHidden = false
    }
}


// MARK: - AttachmentManagerDelegate

extension CameraInputBarAccessoryView: AttachmentManagerDelegate {
    
    // MARK: - AttachmentManagerDelegate
    
    func attachmentManager(_ manager: AttachmentManager, shouldBecomeVisible: Bool) {
        let topStackView = self.topStackView
        
        if shouldBecomeVisible && !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !shouldBecomeVisible && topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.removeArrangedSubview(attachmentManager.attachmentView)
            topStackView.layoutIfNeeded()
        }
    }
    
    func attachmentManager(_ manager: AttachmentManager, didReloadTo attachments: [AttachmentManager.Attachment]) {
        sendButton.isEnabled = !manager.attachments.isEmpty
    }
    
    func attachmentManager(_ manager: AttachmentManager, didInsert attachment: AttachmentManager.Attachment, at index: Int) {
        sendButton.isEnabled = !manager.attachments.isEmpty
    }
    
    func attachmentManager(_ manager: AttachmentManager, didRemove attachment: AttachmentManager.Attachment, at index: Int) {
        sendButton.isEnabled = !manager.attachments.isEmpty
    }
    
    func attachmentManager(_ manager: AttachmentManager, didSelectAddAttachmentAt index: Int) {
        showImagePickerControllerActionSheet()
    }
}


// MARK: - Private methods

private extension CameraInputBarAccessoryView {
    
    func makeButton(named: String) -> InputBarButtonItem {
        InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(systemName: "camera.fill")?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
            }
            .onSelected {
                $0.tintColor = .systemBlue
            }
            .onDeselected {
                $0.tintColor = UIColor.lightGray
            }
            .onTouchUpInside { _ in
                // Handle tap
            }
    }
}
