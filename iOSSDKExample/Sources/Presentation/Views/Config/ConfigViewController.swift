import CXoneChatSDK
import UIKit


class ConfigViewController: BaseViewController, ViewRenderable {
    
    // MARK: - Properties
    
    let presenter: ConfigPresenter
    private let myView = ConfigView()
    
    
    // MARK: - Properties
    
    private var configurations = [Configuration]()
    
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        if FeatureFlag.enableDebugButtonInConfig.isActive {
            guard navigationItem.rightBarButtonItem == nil else {
                return
            }
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: Assets.debug,
                style: .plain,
                target: presenter,
                action: #selector(presenter.onDebugTapped)
            )
        } else {
            navigationItem.rightBarButtonItem = nil
        }
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
            myView.setupView(entity: entity)
        case .error(let title, let message):
            showAlert(title: title, message: message)
        }
    }
}


// MARK: - UITextFieldDelegate

extension ConfigViewController: FormTextFieldDelegate {
    
    func formTextFieldShouldReturn(_ formTextField: FormTextField) -> Bool {
        formTextField.resignFirstResponder()
    }
    
    func formTextFieldDidEndEditing(_ formTextField: FormTextField) {
        formTextField.resignFirstResponder()
        
        switch formTextField {
        case myView.brandIdTextField:
            presenter.onBrandIdChanged(formTextField.text)
        case myView.channelIdTextField:
            presenter.onChannelIdChanged(formTextField.text)
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
            guard myView.isValid() else {
                return
            }
            
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
            UIAlertAction(title: configuration.title, style: .default) { _ in
                self.presenter.onConfigurationChanged(configuration)
            }
        }
        actions.append(UIAlertAction(title: "Cancel", style: .cancel))
        
        UIAlertController.show(.actionSheet, title: myView.isCustomConfigurationHidden ? "Configuration" : "Environment", message: nil, actions: actions)
    }
    
    @objc
    func onChangeEnvironmentTapped() {
        var actions = CXoneChatSDK.Environment.allCases.compactMap { environment -> UIAlertAction? in
            UIAlertAction(title: environment.rawValue, style: .default) { _ in
                self.presenter.onEnvironmentChanged(environment)
            }
        }
        actions.append(UIAlertAction(title: "Cancel", style: .cancel))
        
        UIAlertController.show(.actionSheet, title: "Environments", message: nil, actions: actions)
    }
}
