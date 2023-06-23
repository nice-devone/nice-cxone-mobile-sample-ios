import SnapKit
import UIKit


class ConfigView: UIView {
    
    // MARK: - Views
    
    private let configurationSetupStack = UIStackView()
    
    private let customConfigurationView = UIView()
    private let configSelectLabel = UILabel()
    let configSelectButton = UIButton()
    
    private let defaultConfigurationView = UIView()
    private let environmentSelectLabel = UILabel()
    let environmentSelectButton = UIButton()
    let brandIdTextField = FormTextField(type: .text, isRequired: true)
    let channelIdTextField = FormTextField(type: .text, isRequired: true)
    
    let configurationToggleButton = UIButton()
    
    let continueButton = PrimaryButton()

    var isCustomConfigurationHidden = true
    

    // MARK: - Initialization

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)

        addAllSubviews()
        setupSubviews()
        setupConstraints()
    }
    
    
    // MARK: - Internal methods
    
    func isValid() -> Bool {
        guard isCustomConfigurationHidden else {
            return true
        }
        
        var isValid = true
        
        if !channelIdTextField.isValid() {
            Log.error(.failed("channelId is not valid."))
            isValid = false
        }
        if !brandIdTextField.isValid() {
            Log.error(.failed("brandId is not valid."))
            isValid = false
        }
        
        return isValid
    }
}


// MARK: - Actions

extension ConfigView {
    
    func setupView(entity: ConfigVO) {
        isCustomConfigurationHidden = entity.isCustomConfigurationHidden
        defaultConfigurationView.isHidden = !isCustomConfigurationHidden
        customConfigurationView.isHidden = isCustomConfigurationHidden
        
        if entity.isCustomConfigurationHidden {
            configurationToggleButton.setTitle("Use a custom configuration", for: .normal)
        } else {
            configurationToggleButton.setTitle("Use a default configuration", for: .normal)
        }
        
        configSelectButton.setTitle(entity.currentConfiguration.title, for: .normal)
        environmentSelectButton.setTitle(entity.currentConfiguration.environmentName, for: .normal)
        
        brandIdTextField.text = entity.currentConfiguration.brandId != 0 ? entity.currentConfiguration.brandId.description : nil
        channelIdTextField.text = !entity.currentConfiguration.channelId.isEmpty ? entity.currentConfiguration.channelId : nil
    }
}


// MARK: - Private methods

private extension ConfigView {
    
    func addAllSubviews() {
        addSubviews(configurationSetupStack, configurationToggleButton, continueButton)
        
        configurationSetupStack.addArrangedSubviews(defaultConfigurationView, customConfigurationView)
        
        customConfigurationView.addSubviews(configSelectLabel, configSelectButton)
        defaultConfigurationView.addSubviews(environmentSelectLabel, environmentSelectButton, brandIdTextField, channelIdTextField)
    }

    func setupSubviews() {
        backgroundColor = .systemBackground
        
        configurationSetupStack.axis = .vertical
        configurationSetupStack.spacing = 32
        configurationSetupStack.distribution = .fillProportionally
        configurationSetupStack.alignment = .fill
        
        defaultConfigurationView.isHidden = false
        
        configSelectLabel.text = "Configuration"
        configSelectLabel.font = .preferredFont(forTextStyle: .title3)
        
        configSelectButton.setTitleColor(.systemBlue, for: .normal)
        
        customConfigurationView.isHidden = true
        
        environmentSelectLabel.text = "Environment"
        
        environmentSelectButton.setTitleColor(.systemBlue, for: .normal)
        
        brandIdTextField.placeholder = "Brand ID"
        brandIdTextField.clearButtonMode = .whileEditing
        brandIdTextField.keyboardType = .numberPad
        
        channelIdTextField.placeholder = "Channel ID"
        channelIdTextField.clearButtonMode = .whileEditing
        
        configurationToggleButton.setTitle("Use a custom configuration", for: .normal)
        configurationToggleButton.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        configurationToggleButton.setTitleColor(.systemBlue, for: .normal)
        
        continueButton.setTitle("Continue", for: .normal)
    }
    
    func setupConstraints() {
        configurationSetupStack.snp.makeConstraints { make in
            make.bottom.equalTo(configurationToggleButton.snp.top).offset(-36)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        configSelectLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }
        configSelectButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(configSelectLabel)
            make.height.equalTo(44)
        }
        environmentSelectLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        environmentSelectButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(environmentSelectLabel)
            make.height.equalTo(44)
        }
        brandIdTextField.snp.makeConstraints { make in
            make.top.equalTo(environmentSelectLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
        }
        channelIdTextField.snp.makeConstraints { make in
            make.top.equalTo(brandIdTextField.snp.bottom).offset(24)
            make.leading.trailing.bottom.equalToSuperview()
        }
        configurationToggleButton.snp.makeConstraints { make in
            make.bottom.equalTo(continueButton.snp.top).offset(-36)
            make.leading.trailing.equalToSuperview().inset(48)
        }
        continueButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
}
