import Foundation
import InputBarAccessoryView
import UIKit


// MARK: - Protocol

protocol AttachmentsInputBarAccessoryViewDelegate: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [ChatAttachmentManager.Attachment])
}


// MARK: - Implementation

class AttachmentsInputBarAccessoryView: InputBarAccessoryView {
    
    // MARK: - Properties
    
    lazy var attachmentManager: ChatAttachmentManager = { [unowned self] in
        let manager = ChatAttachmentManager()
        manager.delegate = self
        return manager
    }()
    
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let attachments = makeButton(named: "arrow.up.doc")
        attachments.tintColor = .darkGray
        attachments.onTouchUpInside { [weak self] _ in
            self?.showAttachmentsPicker()
        }
        
        setLeftStackViewWidthConstant(to: 35, animated: true)
        setStackViewItems([attachments], forStack: .left, animated: false)
        inputPlugins = [attachmentManager]
    }
    
    
    // MARK: - Methods
    
    override func didSelectSendButton() {
        if !attachmentManager.attachments.isEmpty, let delegate = delegate as? AttachmentsInputBarAccessoryViewDelegate {
            delegate.inputBar(self, didPressSendButtonWith: attachmentManager.attachments)
        } else {
            delegate?.inputBar(self, didPressSendButtonWith: inputTextView.text)
        }
        
        attachmentManager.invalidate()
    }
}


// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension AttachmentsInputBarAccessoryView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc
    func showAttachmentsPicker() {
        let fileAction = UIAlertAction(title: "Choose from File Manager", style: .default) { [weak self] _ in
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .video, .audio, .pdf])
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = true
            documentPicker.modalPresentationStyle = .overFullScreen
            
            UIApplication.shared.rootViewController?.present(documentPicker, animated: true)
        }
        let photoLibraryAction = UIAlertAction(title: "Image From Library", style: .default) { [weak self] _ in
            self?.showImagePickerController(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Take From Camera", style: .default) { [weak self] _ in
            self?.showImagePickerController(sourceType: .camera)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        UIAlertController.show(.actionSheet, title: "Choose Your Image", message: nil, actions: [fileAction, photoLibraryAction, cameraAction, cancelAction])
    }
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.allowsEditing = true
        controller.sourceType = sourceType
        inputAccessoryView?.isHidden = true
        
        UIApplication.shared.rootViewController?.present(controller, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            attachmentManager.insertAttachment(.image(editedImage), at: attachmentManager.attachments.count)
        } else if let originImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            attachmentManager.insertAttachment(.image(originImage), at: attachmentManager.attachments.count)
        }
        
        picker.dismiss(animated: true)
        inputAccessoryView?.isHidden = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        
        inputAccessoryView?.isHidden = false
    }
}


// MARK: - UIDocumentPickerDelegate

extension AttachmentsInputBarAccessoryView: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        urls.forEach { url in
            guard url.startAccessingSecurityScopedResource(), FileManager.default.fileExists(atPath: url.relativePath) else {
                Log.error(.failed("File does not exist."))
                return
            }
            guard let data = try? Data(contentsOf: url) else {
                Log.error(.failed("Could not get data for an attachment."))
                return
            }
            
            attachmentManager.insertAttachment(.data(data), at: attachmentManager.attachments.count)
            url.stopAccessingSecurityScopedResource()
        }
    }
}


// MARK: - ChatAttachmentManagerDelegate

extension AttachmentsInputBarAccessoryView: ChatAttachmentDelegate {
    
    func attachmentManager(_ manager: ChatAttachmentManager, shouldBecomeVisible: Bool) {
        let topStackView = self.topStackView
        
        if shouldBecomeVisible && !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
        } else if !shouldBecomeVisible && topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.removeArrangedSubview(attachmentManager.attachmentView)
        }
        
        topStackView.layoutIfNeeded()
    }
    
    func attachmentManager(_ manager: ChatAttachmentManager, didReloadTo attachments: [ChatAttachmentManager.Attachment]) {
        sendButton.isEnabled = !manager.attachments.isEmpty
    }
    
    func attachmentManager(_ manager: ChatAttachmentManager, didInsert attachment: ChatAttachmentManager.Attachment, at index: Int) {
        sendButton.isEnabled = !manager.attachments.isEmpty
    }
    
    func attachmentManager(_ manager: ChatAttachmentManager, didRemove attachment: ChatAttachmentManager.Attachment, at index: Int) {
        sendButton.isEnabled = !manager.attachments.isEmpty
    }
    
    func attachmentManager(_ manager: ChatAttachmentManager, didSelectAddAttachmentAt index: Int) {
        showAttachmentsPicker()
    }
}


// MARK: - Private methods

private extension AttachmentsInputBarAccessoryView {
    
    func makeButton(named: String) -> InputBarButtonItem {
        InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(systemName: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
            }
            .onSelected {
                $0.tintColor = .systemBlue
            }
            .onDeselected {
                $0.tintColor = UIColor.lightGray
            }
    }
}
