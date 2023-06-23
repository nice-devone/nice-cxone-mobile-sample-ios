import CXoneChatSDK
import UIKit


class CustomFieldView: UIView {
    
    // MARK: - Views
    
    var titleField: UILabel = {
        var label = UILabel()
        return label
    }()
    
    var textField: UITextField = {
        var textField = UITextField()
        textField.backgroundColor = UIColor.white
        return textField
    }()
    
    
    // MARK: - Properties
    
    var valueDescription: String
    var value: String?
    
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(description: String, value: String) {
        self.valueDescription = description
        self.value = value
        super.init(frame: CGRect())
        
        titleField.text = description
        textField.text = value
        setupViews()
    }
}


// MARK: - Private methods

private extension CustomFieldView {
    
    func setupViews() {
        addSubviews(titleField, textField)
        
        titleField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 8
        textField.clipsToBounds = true
        
        titleField.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(textField.snp.top)
        }
        textField.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(15)
            make.height.equalTo(40)
        }
    }
}
