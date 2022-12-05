import UIKit


class CustomTextfield: UITextField {
    
    // MARK: - View
    
    let separator = UIView(frame: .zero)
    let type: TextFieldType
    
    
    // MARK: - Init
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(type: TextFieldType) {
        self.type = type
        super.init(frame: .zero)
        
        addSubview(separator)
        
        separator.backgroundColor = UIColor.darkGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }

    
    // MARK: - Internal methods
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 20, dy: 13)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 20, dy: 13)
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        CGRect(x: bounds.width - 30, y: bounds.midY - 10, width: 20, height: 20)
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        type == .text ? super.caretRect(for: position) : .zero
    }
}
