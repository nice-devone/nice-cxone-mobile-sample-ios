//
//  ConfigChooser.swift
//  iOSSDKExample
//
//  Created by kjoe on 2/2/22.
//

import UIKit
import CXOneChatSDK
protocol CreateNewThreadDelegate: AnyObject {
    func createNewThread()
}

class ConfigChoosePopupViewController: UIViewController {
    let locationPicker = UIPickerView()
    let departmentPicker = UIPickerView()
    
    
    var nameTextField: UITextField!
//    var lastnameTextField: UITextField!
    var lastNameTextField: UITextField!
    var doneButton: UIButton!
    weak var delegate: CreateNewThreadDelegate!
    var env: Environment!
    var customer: Customer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        view.layer.opacity = 0.65
        let popup = UIView(frame: .zero)
        popup.backgroundColor = .systemBackground
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.layer.borderColor = UIColor.black.cgColor
        popup.layer.borderWidth = 1
        popup.layer.cornerRadius = 8
        popup.clipsToBounds = true
        view.addSubview(popup)
        popup.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        popup.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive =  true
        popup.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 25).isActive = true
        popup.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -25).isActive = true
        let title = UILabel(frame: .zero)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Enter your details"
        popup.addSubview(title)
        title.topAnchor.constraint(equalTo: popup.topAnchor, constant: 25).isActive = true
        title.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: 10).isActive = true
        title.trailingAnchor.constraint(equalTo: popup.trailingAnchor,constant: -10).isActive = true
        //title.bottomAnchor.constraint(equalTo: location.topAnchor, constant: 15).isActive = true
        //title.heightAnchor.constraint(equalToConstant: 20).isActive = true
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        title.textAlignment = .center
        title.font = UIFont.preferredFont(forTextStyle: .title2, compatibleWith: nil)

        nameTextField = UITextField(frame: .zero)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        popup.addSubview(nameTextField)
        nameTextField.textContentType = .givenName
        nameTextField.leadingAnchor.constraint(equalTo: title.leadingAnchor).isActive = true
        nameTextField.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 15).isActive = true
        nameTextField.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -15).isActive = true
        nameTextField.height(constant: 40)
        nameTextField.placeholder = "First name"
        nameTextField.borderStyle = .line
        nameTextField.autocorrectionType = .no
        nameTextField.keyboardType = .default
        nameTextField.autocapitalizationType = .none
        
        lastNameTextField = UITextField(frame: .zero)
        lastNameTextField.translatesAutoresizingMaskIntoConstraints = false
        lastNameTextField.textContentType = .familyName
        popup.addSubview(lastNameTextField)
        lastNameTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 15).isActive = true
        lastNameTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor).isActive = true
        lastNameTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor).isActive = true
        
        lastNameTextField.placeholder = "Last name"
        lastNameTextField.borderStyle = .line
        lastNameTextField.autocorrectionType = .no
        lastNameTextField.keyboardType = .default
        lastNameTextField.autocapitalizationType = .none
        lastNameTextField.height(constant: 40)
        
//        enviromentTextField = UITextField(frame: .zero)
//        enviromentTextField.translatesAutoresizingMaskIntoConstraints = false
//        popup.addSubview(enviromentTextField)
//        enviromentTextField.inputView = departmentPicker
//        let doneDepButton =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.enviromentDone))
//        let departmentTB  = createToolBar()
//        departmentTB.items?.append(doneDepButton)
//
//        enviromentTextField.inputAccessoryView = departmentTB
//        enviromentTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 15).isActive = true
//        enviromentTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor).isActive = true
//        enviromentTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor).isActive = true
//        enviromentTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        enviromentTextField.borderStyle = .line
//        enviromentTextField.placeholder = "Choose an enviroment"
        doneButton = UIButton(frame: .zero)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        popup.addSubview(doneButton)
        doneButton.layer.borderWidth = 1.0
        doneButton.layer.borderColor = UIColor.label.cgColor
        doneButton.layer.cornerRadius = 8.0
        doneButton.clipsToBounds = true
        doneButton.setTitle("Accept", for: .normal)
        doneButton.setTitleColor(.label, for: .normal)
        doneButton.addTarget(self, action: #selector(self.doneAction), for: .touchUpInside)
        doneButton.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 15).isActive = true
        doneButton.leadingAnchor.constraint(equalTo: lastNameTextField.leadingAnchor).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: lastNameTextField.trailingAnchor).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: popup.bottomAnchor, constant: -15).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        locationPicker.dataSource = self
        locationPicker.delegate = self
        departmentPicker.dataSource = self
        departmentPicker.delegate = self
        guard let user = customer else {
            return
        }
       // let personComponents = PersonNameComponents()
        
        let person = PersonNameComponentsFormatter()
        let names = person.personNameComponents(from: user.displayName)
        guard let names = names else {
            return
        }
        nameTextField.text = names.givenName
        lastNameTextField.text = names.familyName
    }
    
    func createToolBar() -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = .default
        toolBar.tintColor = .label
        toolBar.backgroundColor = .clear
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        label.font = UIFont(name: "Helvetica", size: 13)
        label.backgroundColor = UIColor.clear
        label.textColor = .label
        label.text = "Pick a choice:"
        label.textAlignment = .center
        let textBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([textBtn, flexSpace], animated: true)
        return  toolBar
    }
    
    
    @objc func enviromentDone() {
        self.view.endEditing(true)
        let ind = departmentPicker.selectedRow(inComponent: 0)
        env = Environment.allCases[ind]
       // lastnameTextField.text = EnvConfig.allCases[ind].location
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Environment.allCases.count
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Environment.allCases[row].location
    }
    
    @objc func doneAction() {
        var person = PersonNameComponents()
        person.givenName = nameTextField.text ?? ""
        person.familyName = lastNameTextField.text ?? ""
        
        CXOneChat.shared.setCustomerName(firstName: person.givenName!, lastName: person.familyName!)

        dismiss(animated: true)
        delegate.createNewThread()
        
    }
}

extension ConfigChoosePopupViewController: UIPickerViewDataSource, UIPickerViewDelegate { }


extension ConfigChoosePopupViewController: UITextFieldDelegate {
}


