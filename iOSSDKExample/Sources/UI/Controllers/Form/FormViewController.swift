import CXoneChatSDK
import UIKit


class FormViewController: BaseViewController {
    
    // MARK: - Views
    
    let myView = FormView()
    
    
    // MARK: - Properties

    private let viewObject: FormVO
    
    private let onFinished: ([String: String]) -> Void
    
    
    // MARK: - Init
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(entity: FormVO, onFinished: @escaping ([String: String]) -> Void) {
        self.viewObject = entity
        self.onFinished = onFinished
        super.init(nibName: nil, bundle: nil)
        
        myView.titleLabel.text = entity.title
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myView.setupView(with: viewObject)
    }
    
    override func loadView() {
        super.loadView()
        
        view = myView
        
        myView.confirmButton.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
        myView.cancelButton.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
    }
}


// MARK: - Actions

private extension FormViewController {
    
    @objc
    func onButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        guard isValid() else {
            Log.error(CommonError.failed("Form values are not valid."))
            return
        }
        
        dismiss(animated: true) {
            switch sender {
            case self.myView.cancelButton:
                break
            case self.myView.confirmButton:
                self.onFinished(self.myView.customFields)
            default:
                Log.error(CommonError.failed("Unknown sender did tap."))
            }
        }
    }
}


private extension FormViewController {
    
    func isValid() -> Bool {
        true
    }
}
