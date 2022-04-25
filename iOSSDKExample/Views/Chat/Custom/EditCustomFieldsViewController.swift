//
//  EditCustomFieldsController.swift
//  iOSSDKExample
//
//  Created by Customer Dynamics Development on 11/19/21.
//

import Foundation
import CXOneChatSDK
import UIKit	

class EditCustomFieldsViewController: UIViewController {
	
	var sdkClient = CXOneChat.shared
	var thread: String
	
	init(thread: String) {
		self.thread = thread
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	lazy var backgroundColor: UIImageView = {
		var image = UIImageView()
		image.backgroundColor = UIColor.white
		return image
	}()
	
	lazy var verticalStackView: UIStackView = {
		var stackView = UIStackView()
		stackView.axis = .vertical
		return stackView
	}()
	
	lazy var saveButton: UIButton = {
		var button = UIButton()
		button.setTitle("Save", for: .normal)
		button.setTitleColor(UIColor.black, for: .normal)
		button.setTitleColor(UIColor.blue, for: .focused)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.blue.cgColor
        button.addTarget(self, action: #selector(saveValues), for: .touchUpInside)
		return button
	}()
	
	var customValues = [CustomField(ident: "firstname", value: ""),CustomField(ident: "email", value: ""),CustomField(ident: "lastname ", value: "")]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		saveButton.height(constant: 70)
		
		for value in customValues {
			addCustomField(field: value)
		}
		
		self.verticalStackView.addArrangedSubview(saveButton)
		
		self.view.addSubview(backgroundColor)
		self.view.addSubview(verticalStackView)
		
		backgroundColor.translatesAutoresizingMaskIntoConstraints = false
		backgroundColor.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		backgroundColor.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		backgroundColor.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		backgroundColor.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		
		verticalStackView.translatesAutoresizingMaskIntoConstraints = false
		verticalStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 30).isActive = true
		verticalStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
		verticalStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
		verticalStackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        verticalStackView.distribution = .fillProportionally
		
	}
	
	func addCustomField(field: CustomField) {
		verticalStackView.addArrangedSubview(CustomFieldView(field: field))
	}
	
	@objc func saveValues() {
        //self.customValues.first?.value = verticalStackView.subviews.
        
        for i in 0..<customValues.count {
            customValues[i].value =  (verticalStackView.subviews[i] as! CustomFieldView).textField.text ?? ""
        }
        let contact = customValues.removeLast()
        do {
           try self.sdkClient.setCustomerCustomFields(customFields: self.customValues)
        }catch {
            print(error.localizedDescription)
        }
        do {
            try self.sdkClient.setContactCustomFields(customFields: [contact])//setCustomContactFields(customFields: [contact])
        }catch {
            print(error.localizedDescription)
        }
        
        dismiss(animated: true)
	}
}

class CustomFieldView: UIView {
	var field: CustomField
	
	var titleField: UILabel = {
		var label = UILabel()
		return label
	}()
	
	var textField: UITextField = {
		var textField = UITextField()
		textField.backgroundColor = UIColor.white
		return textField
	}()
		
	init(field: CustomField) {
		self.field = field
		titleField.text = field.ident
		textField.text = field.value
		super.init(frame: CGRect())
		
		setupViews()
	}
	
	func setupViews() {
		self.addSubview(titleField)
		self.addSubview(textField)
		//self.backgroundColor = UIColor.blue
		
		titleField.translatesAutoresizingMaskIntoConstraints = false
		titleField.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		titleField.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		titleField.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		titleField.bottomAnchor.constraint(equalTo: textField.topAnchor).isActive = true
		
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
		textField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true
		textField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 8
        textField.clipsToBounds = true
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}


extension UIView {
  func height(constant: CGFloat) {
	setConstraint(value: constant, attribute: .height)
  }
  
  func width(constant: CGFloat) {
	setConstraint(value: constant, attribute: .width)
  }
  
	private func removeConstraint(attribute: NSLayoutConstraint.Attribute) {
	constraints.forEach {
	  if $0.firstAttribute == attribute {
		removeConstraint($0)
	  }
	}
  }
  
	private func setConstraint(value: CGFloat, attribute: NSLayoutConstraint.Attribute) {
	removeConstraint(attribute: attribute)
	let constraint =
	  NSLayoutConstraint(item: self,
						 attribute: attribute,
						 relatedBy: NSLayoutConstraint.Relation.equal,
						 toItem: nil,
						 attribute: NSLayoutConstraint.Attribute.notAnAttribute,
						 multiplier: 1,
						 constant: value)
	self.addConstraint(constraint)
  }
}
