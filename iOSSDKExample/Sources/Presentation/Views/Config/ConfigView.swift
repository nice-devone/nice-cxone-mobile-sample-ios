import SnapKit
import UIKit


class ConfigView: UIView {
    
    // MARK: - Views
    
    private let configurationSetupStack = UIStackView()
    
    private let defaultConfigurationView = UIView()
    private let configSelectLabel = UILabel()
    let configSelectButton = UIButton()
    
    private let customConfigurationView = UIView()
    private let environmentSelectLabel = UILabel()
    let environmentSelectButton = UIButton()
    let brandIdTextField = CustomTextfield(type: .text)
    let channelIdTextField = CustomTextfield(type: .text)
    
    let configurationToggleButton = UIButton(configuration: .plain())
    
    let continueButton = PrimaryButton()

    var isCustomConfigurationHidden = true
    

    // MARK: - Initialization

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(frame: .zero)

        addAllSubviews()
        setupSubviews()
        setupConstraints()
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
        
        configSelectButton.setTitle(entity.selectedConfiguration.connectionConfigurationType?.rawValue, for: .normal)
        environmentSelectButton.setTitle(entity.selectedConfiguration.connectionEnvironmentType?.rawValue, for: .normal)
        
        if entity.selectedConfiguration.brandId != 0 {
            brandIdTextField.text = entity.selectedConfiguration.brandId.description
        } else {
            brandIdTextField.text = nil
        }
        
        if !entity.selectedConfiguration.channelId.isEmpty {
            channelIdTextField.text = entity.selectedConfiguration.channelId
        } else {
            channelIdTextField.text = nil
        }
    }
}


// MARK: - Private methods

private extension ConfigView {
    
    func addAllSubviews() {
        addSubviews([
            configurationSetupStack,
            configurationToggleButton,
            continueButton
        ])
        
        configurationSetupStack.addArrangedSubviews([defaultConfigurationView, customConfigurationView])
        
        defaultConfigurationView.addSubviews([
            configSelectLabel,
            configSelectButton
        ])
        customConfigurationView.addSubviews([
            environmentSelectLabel,
            environmentSelectButton,
            brandIdTextField,
            channelIdTextField
        ])
    }

    func setupSubviews() {
        backgroundColor = .systemBackground
        
        configurationSetupStack.axis = .vertical
        configurationSetupStack.spacing = 32
        configurationSetupStack.distribution = .fillProportionally
        configurationSetupStack.alignment = .fill
        
        defaultConfigurationView.isHidden = false
        
        configSelectLabel.text = "Configuration"
        configSelectLabel.font = .systemFont(ofSize: 17)
        
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
        configurationToggleButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
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
            make.size.equalTo(50)
        }
        environmentSelectLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        environmentSelectButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(environmentSelectLabel)
            make.size.equalTo(50)
        }
        brandIdTextField.snp.makeConstraints { make in
            make.top.equalTo(environmentSelectLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        channelIdTextField.snp.makeConstraints { make in
            make.top.equalTo(brandIdTextField.snp.bottom).offset(24)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(44)
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
