import UIKit
import CXOneChatSDK

class ConfigViewController: UIViewController {
    let cxOneChat = CXOneChat.shared
    var stack: UIStackView!
    var headerView = UIView(frame: .zero)
    var configurationToggleButton = UIButton(configuration: UIButton.Configuration.plain())
    var continueButton: UIButton!
    
    let spinner = UIActivityIndicatorView(style: .large)
    let spinnerLabel = UILabel(frame: .zero)

    // Default Configuration
    var configButton = UIButton(frame: .zero)
    
    // Custom Configuration
    var customConfigTextContainer = UIView(frame: .zero)
    var envButton: UIButton!
    var brandIdTextField: CustomTextfield!
    var channelIdTextField: CustomTextfield!
    
    var connectionConfiguration: ConnectionConfiguration {
        get {
            let encodedConfig = UserDefaults.standard.data(forKey: "connection-configuration")!
            return try! JSONDecoder().decode(ConnectionConfiguration.self, from: encodedConfig)
        }
        set(configuration) {
            let encodedConfig = try! JSONEncoder().encode(configuration)
            UserDefaults.standard.set(encodedConfig, forKey: "connection-configuration")
        }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        connectionConfiguration = ConnectionConfiguration(connectionConfigurationType: .CD)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Configuration"
        view.backgroundColor = .systemBackground
        customConfigTextContainer.isHidden = true
        
        // Continue button
        var continueButtonConfig = UIButton.Configuration.filled()
        continueButtonConfig.titlePadding = 10
        continueButtonConfig.imagePadding = 10
        continueButtonConfig.contentInsets = NSDirectionalEdgeInsets(top: 13, leading: 20, bottom: 13, trailing: 20)
        continueButtonConfig.cornerStyle = .fixed
        continueButtonConfig.baseBackgroundColor = UIColor.systemBlue
        continueButton = UIButton(configuration: continueButtonConfig)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(continueButton)
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 17),
            continueButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -17),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64)
        ])

        // Configuration toggle button
        configurationToggleButton.translatesAutoresizingMaskIntoConstraints = false
        configurationToggleButton.setTitle("Use a custom configuration", for: .normal)
        configurationToggleButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        configurationToggleButton.setTitleColor(.systemBlue, for: .normal)
        configurationToggleButton.addTarget(self, action: #selector(toggleConfigurationType), for: .primaryActionTriggered)
        view.addSubview(configurationToggleButton)
        NSLayoutConstraint.activate([
            configurationToggleButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            configurationToggleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            configurationToggleButton.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -50)
        ])
        
        // Configuration selection
        let label = UILabel(frame: .zero)
        label.text = "Configuration"
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints =  false
        headerView.addSubview(label)

        // Configuration button
        configButton.setTitle("CD", for: .normal)
        configButton.setTitleColor(.systemBlue, for: .normal)
        configButton.translatesAutoresizingMaskIntoConstraints = false
        let items = UIMenu(title: "Configurations", options: .displayInline, children: [
            UIAction(title: "Sales", handler: { _ in
                self.configButton.setTitle("Sales", for: .normal)
                self.connectionConfiguration = ConnectionConfiguration(connectionConfigurationType: .Sales)
            }),
            UIAction(title: "M&J", handler: { _ in
                self.configButton.setTitle("M&J", for: .normal)
                self.connectionConfiguration = ConnectionConfiguration(connectionConfigurationType: .MJ)
            }),
            UIAction(title: "CD", handler: { _ in
                self.configButton.setTitle("CD", for: .normal)
                self.connectionConfiguration = ConnectionConfiguration(connectionConfigurationType: .CD)
            })
        ])
        configButton.menu = UIMenu(title: "", children: [items])
        configButton.showsMenuAsPrimaryAction = true
        headerView.addSubview(configButton)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 17),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            configButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -17),
            configButton.topAnchor.constraint(equalTo: label.topAnchor),
            configButton.bottomAnchor.constraint(equalTo: label.bottomAnchor)
        ])
        headerView.translatesAutoresizingMaskIntoConstraints = false

        customConfigTextContainer.translatesAutoresizingMaskIntoConstraints = false
        let environmentLabel = UILabel(frame: .zero)
        environmentLabel.text = "Environment"
        environmentLabel.translatesAutoresizingMaskIntoConstraints = false
        customConfigTextContainer.addSubview(environmentLabel)
        
        // Environment button
        envButton = UIButton(frame: .zero)
        envButton.setTitle("NA1", for: .normal)
        envButton.setTitleColor(.systemBlue, for: .normal)
        var children: [UIMenuElement] = []
        
        children.append(UIAction(title:  "QA", handler: { _ in
            self.envButton.setTitle("QA", for: .normal)
            self.connectionConfiguration = ConnectionConfiguration(connectionEnvironmentType: .QA)
        }))
        children.append(UIAction(title:  "NA1", handler: { _ in
            self.envButton.setTitle("NA1", for: .normal)
            self.connectionConfiguration = ConnectionConfiguration(connectionEnvironmentType: .NA1)
        }))
        
        let menuItems = UIMenu(title: "Configurations", options: .displayInline, children: children)
        envButton.menu = UIMenu(title: "", children: [menuItems])
        envButton.showsMenuAsPrimaryAction = true
        envButton.translatesAutoresizingMaskIntoConstraints = false
        customConfigTextContainer.addSubview(envButton)
        
        // Brand ID text field
        brandIdTextField = CustomTextfield()
        brandIdTextField.placeholder = "Brand ID"
        brandIdTextField.clearButtonMode = .whileEditing
        brandIdTextField.keyboardType = .numberPad
        brandIdTextField.translatesAutoresizingMaskIntoConstraints = false
        customConfigTextContainer.addSubview(brandIdTextField)
        
        // Channel id text field
        channelIdTextField = CustomTextfield()
        channelIdTextField.placeholder = "Channel ID"
        channelIdTextField.clearButtonMode = .whileEditing
        channelIdTextField.translatesAutoresizingMaskIntoConstraints = false
        customConfigTextContainer.addSubview(channelIdTextField)
        NSLayoutConstraint.activate([
            environmentLabel.topAnchor.constraint(equalTo: customConfigTextContainer.topAnchor),
            environmentLabel.leadingAnchor.constraint(equalTo: customConfigTextContainer.leadingAnchor, constant: 16),
            envButton.topAnchor.constraint(equalTo: environmentLabel.topAnchor),
            envButton.trailingAnchor.constraint(equalTo: customConfigTextContainer.trailingAnchor, constant: -16),
            brandIdTextField.topAnchor.constraint(equalTo: environmentLabel.bottomAnchor, constant: 32),
            brandIdTextField.leadingAnchor.constraint(equalTo: customConfigTextContainer.leadingAnchor),
            brandIdTextField.trailingAnchor.constraint(equalTo: customConfigTextContainer.trailingAnchor),
            brandIdTextField.heightAnchor.constraint(equalToConstant: 44),
            channelIdTextField.leadingAnchor.constraint(equalTo: customConfigTextContainer.leadingAnchor),
            channelIdTextField.trailingAnchor.constraint(equalTo: customConfigTextContainer.trailingAnchor),
            channelIdTextField.topAnchor.constraint(equalTo: brandIdTextField.bottomAnchor, constant: 21),
            channelIdTextField.bottomAnchor.constraint(equalTo: customConfigTextContainer.bottomAnchor),
            channelIdTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
        //stack.addSubview(textContainer)
        
        stack = UIStackView(arrangedSubviews: [headerView, customConfigTextContainer])
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        stack.axis = .vertical
        stack.spacing = 32
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        NSLayoutConstraint.activate([
            stack.bottomAnchor.constraint(equalTo: configurationToggleButton.topAnchor, constant: -32),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        stack.setNeedsLayout()
        stack.layoutIfNeeded()
        
        // Spinner
        spinnerLabel.text = "Getting channel configuration..."
        spinnerLabel.textColor = .label
        spinnerLabel.font = .systemFont(ofSize: 17)
        view.addSubview(spinnerLabel)
        view.addSubview(spinner)
        spinner.isHidden = true
        spinnerLabel.isHidden = true
        spinnerLabel.textAlignment = .center
        spinner.color = .systemBlue
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinnerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            spinnerLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 17),
            spinnerLabel.centerXAnchor.constraint(equalTo: spinner.centerXAnchor)
        ])
        continueButton.addTarget(self, action: #selector(continueAction(_:)), for: .primaryActionTriggered)
    }
    
    @objc func toggleConfigurationType() {
        self.headerView.isHidden.toggle()
        self.customConfigTextContainer.isHidden.toggle()
        if customConfigTextContainer.isHidden {
            configurationToggleButton.setTitle("Use a custom configuration", for: .normal)
            connectionConfiguration = ConnectionConfiguration(connectionConfigurationType: .CD)
            configButton.setTitle("CD", for: .normal)
        } else {
            configurationToggleButton.setTitle("Use a default configuration", for: .normal)
            connectionConfiguration = ConnectionConfiguration(connectionEnvironmentType: .NA1)
            envButton.setTitle("NA1", for: .normal)
            
        }
    }
   
    @objc func continueAction(_ sender: UIButton) {
        view.endEditing(true)
        if validate() {
            if !customConfigTextContainer.isHidden {
                connectionConfiguration.brandId = Int(brandIdTextField.text!)!
                connectionConfiguration.channelId = channelIdTextField.text!
            }
            loadChannelConfig()
        } else {
            showAlert(title: "All Fields Required", message: "Please provide a value for all fields.")
        }
    }
    
    func validate() -> Bool {
        if customConfigTextContainer.isHidden {
            return true
        } else {
            return !(brandIdTextField.text?.isEmpty ?? false) && !(channelIdTextField.text?.isEmpty ?? false)
        }
    }
    
    func loadChannelConfig() {
        spinner.isHidden = false
        spinner.startAnimating()
        spinnerLabel.isHidden = false
        continueButton.isHidden.toggle()
        stack.isHidden.toggle()
        configurationToggleButton.isHidden.toggle()
        
        do {
            if connectionConfiguration.isCustomEnvironment {
                try cxOneChat.getChannelConfiguration(chatURL: connectionConfiguration.chatUrl, brandId: connectionConfiguration.brandId, channelId: connectionConfiguration.channelId, completion: { result in
                    self.handleChannelConfigResult(result: result)
                })
            } else {
                try cxOneChat.getChannelConfiguration(environment: connectionConfiguration.environment!, brandId: connectionConfiguration.brandId, channelId: connectionConfiguration.channelId, completion: { result in
                    self.handleChannelConfigResult(result: result)
                })
            }
        } catch {
            showChannelConfigError(error: error)
        }
    }
    
    private func handleChannelConfigResult(result: Result<ChannelConfiguration, Error>) {
        DispatchQueue.main.async {
            self.spinner.isHidden.toggle()
            self.spinnerLabel.isHidden.toggle()
            self.continueButton.isHidden.toggle()
            self.stack.isHidden.toggle()
            self.configurationToggleButton.isHidden.toggle()
            switch (result) {
            case .success(let channelConfig):
                self.navigate(channelConfig: channelConfig)
            case .failure(let error):
                self.showChannelConfigError(error: error)
            }
        }
    }
    
    func showChannelConfigError(error: Error) {
        print(error)
        self.showAlert(title: "Channel Configuration Error", message: "Something went wrong and we couldn't get the configuration for that channel. Please check your selection and try again.")

    }

    func navigate(channelConfig: ChannelConfiguration) {
        let loginViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() as! LoginViewController
        loginViewController.channelConfig = channelConfig
        view.window?.rootViewController = loginViewController
    }    
}

