//
//  CustomTextField.swift
//  iOSSDKExample
//
//  Created by kjoe on 6/24/22.
//

import UIKit
class CustomTextfield: UITextField {
    let separator: UIView
    
    init() {
        separator = UIView(frame: .zero)
        separator.translatesAutoresizingMaskIntoConstraints = false
        super.init(frame: .zero)
        addSubview(separator)
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separator.backgroundColor = UIColor.darkGray
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return  bounds.insetBy(dx: 20, dy: 13)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 20, dy: 13)
    }
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - 30, y: bounds.midY - 10, width: 20, height: 20)
        
    }

}
