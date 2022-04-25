//
//  NewThreadCustomFieldsPopupViewController.swift
//  iOSSDKExample
//
//  Created by kjoe on 1/24/22.
//

import UIKit
import CXOneChatSDK

class NewThreadCustomFieldsPopupViewController: UIViewController {
    let locationPicker = UIPickerView()
    let departmentPicker = UIPickerView()
    var customValues = [CustomField(ident: "location", value: ""),CustomField(ident: "department", value: "")]
    let locations =  ["West Coast", "Northeast", "Southeast", "Midwest"]
    let locationsValues = ["WCI","NEI","SEI","MWI"]
    let departments = ["Sales", "Services"]
    
    var location: UITextField!
    var department: UITextField!
    var doneButton: UIButton!
    var closure: (([CustomField]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = .clear
        view.isOpaque = false
        view.layer.opacity = 0.65
        let popup = UIView(frame: .zero)
       // self.view.translatesAutoresizingMaskIntoConstraints = false
        popup.backgroundColor = .systemBackground
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.layer.borderColor = UIColor.black.cgColor
        popup.layer.borderWidth = 1
        popup.layer.cornerRadius = 8
        popup.clipsToBounds = true
        view.addSubview(popup)
        //popup.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 75).isActive = true
        popup.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        popup.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive =  true
        popup.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 25).isActive = true
        popup.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -25).isActive = true
        //popup.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100).isActive = true
        let title = UILabel(frame: .zero)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Create conversation"
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

        location = UITextField(frame: .zero)
        location.translatesAutoresizingMaskIntoConstraints = false
        location.inputView = locationPicker
        popup.addSubview(location)
        let tb = createToolBar()
        let doneLocButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.locationDone))
        tb.items?.append(doneLocButton)
        location.inputAccessoryView = tb
        location.leadingAnchor.constraint(equalTo: title.leadingAnchor).isActive = true
        location.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 15).isActive = true
        location.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -15).isActive = true
        location.height(constant: 40)
        location.placeholder = "Please select your location"
        location.borderStyle = .line
        location.autocorrectionType = .no
        location.keyboardType = .default
        location.autocapitalizationType = .none

        department = UITextField(frame: .zero)
        department.translatesAutoresizingMaskIntoConstraints = false
        popup.addSubview(department)
        department.inputView = departmentPicker
        let doneDepButton =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.departmentDone))
        let departmentTB  = createToolBar()
        departmentTB.items?.append(doneDepButton)
        department.inputAccessoryView = departmentTB
        department.topAnchor.constraint(equalTo: location.bottomAnchor, constant: 15).isActive = true
        department.leadingAnchor.constraint(equalTo: location.leadingAnchor).isActive = true
        department.trailingAnchor.constraint(equalTo: location.trailingAnchor).isActive = true
        department.heightAnchor.constraint(equalToConstant: 40).isActive = true
        department.borderStyle = .line
        department.placeholder = "Please select a department"
        doneButton = UIButton(frame: .zero)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        popup.addSubview(doneButton)
        doneButton.layer.borderWidth = 1.0
        doneButton.layer.borderColor = UIColor.label.cgColor
        doneButton.layer.cornerRadius = 8.0
        doneButton.clipsToBounds = true
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.label, for: .normal)
        doneButton.addTarget(self, action: #selector(self.doneAction), for: .touchUpInside)
        doneButton.topAnchor.constraint(equalTo: department.bottomAnchor, constant: 15).isActive = true
        doneButton.leadingAnchor.constraint(equalTo: department.leadingAnchor).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: department.trailingAnchor).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: popup.bottomAnchor, constant: -15).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        locationPicker.dataSource = self
        locationPicker.delegate = self
        departmentPicker.dataSource = self
        departmentPicker.delegate = self
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
    
    @objc func locationDone() {
        location.resignFirstResponder()
        let ind = locationPicker.selectedRow(inComponent: 0)
        customValues[0].value = locationsValues[ind]
        location.text = locations[ind]
    }
    @objc func departmentDone() {
        self.view.endEditing(true)
        let ind = departmentPicker.selectedRow(inComponent: 0)
        customValues[1].value = departments[ind]
        department.text = departments[ind]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == locationPicker ?  locations.count : departments.count
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == locationPicker ? locations[row] : departments[row]
    }
    
    @objc func doneAction() {
        do {
            try CXOneChat.shared.createThread()
        }catch {
            print(error.localizedDescription)
        }
        closure?(customValues)
        dismiss(animated: true)
    }

}

extension NewThreadCustomFieldsPopupViewController: UIPickerViewDataSource, UIPickerViewDelegate { }
