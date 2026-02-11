//
//  FormTextFieldPickerField.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
import UIKit


class FormTextFieldPickerField: FormFieldCell {
    
    static let identifier = "FormTextFieldPickerField"
    
    let textField = AppTextField()
    
    var enteredText: String {
        return textField.text ?? ""
    }
    let pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.selectRow(0, inComponent: 0, animated: true)
        return picker
    }()
    
    var onPickerValueChange: ((String) -> Void)?
    
    var onReturn: ((String) -> String?)?
    var onTextValueChange: ((String) -> String?)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
        setTitleLabelCenter()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUpContentView() {
        
        super.setUpContentView()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        rightView.add(pickerView)
        rightView.add(textField)
        textField.delegate = self
        textField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
        
        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: rightView.centerYAnchor, constant: FormSpacing.height),
            textField.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            textField.widthAnchor.constraint(equalTo: rightView.widthAnchor, multiplier: 0.3),
            textField.heightAnchor.constraint(equalToConstant: 40),

            pickerView.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.height),
            pickerView.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: FormSpacing.width),
            pickerView.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width),
            pickerView.heightAnchor.constraint(equalToConstant: 90),
            
            pickerView.bottomAnchor.constraint(equalTo: rightView.bottomAnchor, constant: -FormSpacing.height)
        ])
        
    }

    func configure(field: DocumentFormField,isRequired: Bool = false) {
        super.configure(title: field.label, isRequired: isRequired)
        
        if let text = field.value as? String {
            textField.text = text
        }
        textField.placeholder = field.placeholder ?? ""
    }
    
    func configure(title: String, text: String?,placeholder: String?,selectedPicker: String,isRequired: Bool = false) {
        super.configure(title: title, isRequired: isRequired)
        textField.text = text
        let value = DurationType.allCases.firstIndex(of: DurationType(rawValue: selectedPicker) ?? .day) ?? 0
        pickerView.selectRow(value, inComponent: 0, animated: true)
        textField.placeholder = placeholder ?? ""
    }
    
    
    @objc func valueChanged() {
        let error = onTextValueChange?(enteredText)
        if let text = error {
            setErrorLabelText(text)
        }
    }

}

extension FormTextFieldPickerField: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        DurationType.allCases.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        onPickerValueChange?(DurationType.allCases[row].rawValue)
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        DurationType.allCases[row].rawValue
    }
    
    
}

extension FormTextFieldPickerField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let error = onReturn?(enteredText)
        if let text = error {
            setErrorLabelText(text)
            return false
        } else {
            return true
        }
    }
}
