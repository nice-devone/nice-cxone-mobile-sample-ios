import CXoneChatSDK
import UIKit


class ConfigViewController: BaseViewController, ViewRenderable {
    
    // MARK: - Properties
    
    let presenter: ConfigPresenter
    private let myView = ConfigView()
    
    
    // MARK: - Properties
    
    let cxOneChat = CXoneChat.shared
    
    private var configurations = [ConnectionConfiguration]()
    private var environments = [ConnectionConfiguration]()
    
    
    // MARK: - Init
    
    internal required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(presenter: ConfigPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.subscribe(from: self)
    }
    
    override func loadView() {
        super.loadView()
        
        title = "Configuration"
        view = myView
        
        myView.brandIdTextField.delegate = self
        myView.channelIdTextField.delegate = self
        
        myView.configSelectButton.addTarget(self, action: #selector(onChangeConfigurationTapped), for: .touchUpInside)
        myView.environmentSelectButton.addTarget(self, action: #selector(onChangeEnvironmentTapped), for: .touchUpInside)
        
        myView.configurationToggleButton.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
        myView.continueButton.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
    }
    
    func render(state: ConfigViewState) {
        if !state.isLoading {
            hideLoading()
        }
        
        switch state {
        case .loading(let title):
            showLoading(title: title)
        case .loaded(let entity):
            self.configurations = entity.configurations
            self.environments = entity.environmnets
            myView.setupView(entity: entity)
        case .error(let title, let message):
            showAlert(title: title, message: message)
        }
    }
}


// MARK: - UITextFieldDelegate

extension ConfigViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        
        switch textField {
        case myView.brandIdTextField:
            presenter.onBrandIdChanged(textField.text)
        case myView.channelIdTextField:
            presenter.onChannelIdChanged(textField.text)
        default:
            Log.error(CommonError.failed("Unknown text field did end editing."))
        }
    }
}


// MARK: - Actions

private extension ConfigViewController {

    @objc
    func onButtonTapped(sender: UIButton) {
        myView.endEditing(true)
        
        switch sender {
        case myView.configurationToggleButton:
            presenter.onToggleCustomConfiguration(isHidden: !myView.isCustomConfigurationHidden)
        case myView.continueButton:
            Task { @MainActor in
                await presenter.onContinueButtonTapped()
            }
        default:
            Log.error(CommonError.failed("Unknown sender did tap."))
        }
    }
    
    @objc
    func onChangeConfigurationTapped() {
        var actions = configurations.compactMap { configuration -> UIAlertAction? in
            guard let type = configuration.connectionConfigurationType else {
                return nil
            }
            
            return UIAlertAction(title: type.rawValue, style: .default) { _ in
                self.presenter.onConfigurationChanged(configuration)
            }
        }
        actions.append(UIAlertAction(title: "Cancel", style: .cancel))
        
        UIAlertController.show(.actionSheet, title: "Environments", message: nil, actions: actions)
    }
    
    @objc
    func onChangeEnvironmentTapped() {
        var actions = environments.compactMap { configuration -> UIAlertAction? in
            guard let type = configuration.connectionEnvironmentType else {
                return nil
            }
            
            return UIAlertAction(title: type.rawValue, style: .default) { _ in
                self.presenter.onConfigurationChanged(configuration)
            }
        }
        actions.append(UIAlertAction(title: "Cancel", style: .cancel))
        
        UIAlertController.show(.actionSheet, title: "Environments", message: nil, actions: actions)
    }
}
