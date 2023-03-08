import CXoneChatSDK
import UIKit


class FormView: UIView {
    
    // MARK: - Views
    
    let titleLabel = UILabel()
    private let contentStackView = UIStackView()
    private let buttonStackView = UIStackView()
    
    let confirmButton = PrimaryButton()
    let cancelButton = SecondaryButton()
    
    
    // MARK: - Properties

    var customFields = [String: String]()
    var pickerOptions = [(key: String, options: [String])]()
    
    
    // MARK: - Init
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(frame: .zero)
        
        addAllSubviews()
        setupSubviews()
        setupConstraints()
    }
    
    func setupView(with viewObject: FormVO) {
        self.pickerOptions = viewObject.entities.compactMap { entity -> (key: String, options: [String])? in
            guard case .list(let options) = entity.type else {
                return nil
            }
            
            return (entity.customField.key, options)
        }
        
        viewObject.entities.forEach { entity in
            customFields[entity.customField.key] = entity.customField.value
            
            let textField = getTextField(with: entity)
            textField.placeholder = entity.placeholder
            
            contentStackView.addArrangedSubview(textField)
        }
    }
}


// MARK: - Actions

private extension FormView {
        
    @objc
    func didChoosePickerOption() {
        endEditing(true)
    }
}


// MARK: - UITextFieldDelegate

extension FormView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        
        
        guard let entity = customFields.first(where: { $0.key == textField.layer.name }) else {
            Log.error(CommonError.unableToParse("index"))
            return
        }
        
        customFields.updateValue(textField.text ?? "", forKey: entity.key)
    }
}


// MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension FormView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let options = pickerOptions.first(where: { $0.key == pickerView.layer.name })?.options else {
            return 0
        }
        
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let options = pickerOptions.first(where: { $0.key == pickerView.layer.name })?.options else {
            return nil
        }
        
        return options[safe: row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let entity = pickerOptions.first(where: { $0.key == pickerView.layer.name }) else {
            Log.error(CommonError.unableToParse("entity", from: pickerOptions))
            return
        }
        
        let option = entity.options[row]
        customFields[entity.key] = option
        (contentStackView.arrangedSubviews.first { $0.layer.name == entity.key } as? CustomTextfield)?.text = option
    }
}


// MARK: - Private methods

private extension FormView {
    
    func getTextField(with entity: FormTextFieldEntity) -> CustomTextfield {
        let textField = CustomTextfield(type: entity.type)
        textField.layer.name = entity.customField.key
        textField.delegate = self
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        switch entity.type {
        case .text:
            textField.text = entity.customField.value.isEmpty ? nil : entity.customField.value
        case .list(let options):
            textField.text = options.first
            
            let picker = UIPickerView()
            picker.layer.name = entity.customField.key
            picker.delegate = self
            picker.dataSource = self
            textField.inputView = picker
            textField.inputAccessoryView = getToolbar(ident: entity.customField.key)
        }
        
        textField.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        return textField
    }
    
    func getToolbar(ident: String) -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: frame.size.height / 6, width: frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: frame.size.width / 2, y: frame.size.height - 20.0)
        toolBar.tintColor = .label
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didChoosePickerOption))
        doneButton.customView?.layer.name = ident
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        
        return toolBar
    }
    
    func addAllSubviews() {
        addSubviews(titleLabel, contentStackView, buttonStackView)
        buttonStackView.addArrangedSubviews(cancelButton, confirmButton)
    }
    
    func setupSubviews() {
        backgroundColor = .systemBackground
        
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .title3)
        titleLabel.textColor = .lightGray
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.distribution = .equalSpacing
        
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually
        
        cancelButton.setTitle("Cancel", for: .normal)
        confirmButton.setTitle("Confirm", for: .normal)
    }
    
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).inset(20)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        buttonStackView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(contentStackView.snp.bottom).offset(40)
            make.leading.trailing.equalTo(contentStackView)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(20)
        }
    }
}
