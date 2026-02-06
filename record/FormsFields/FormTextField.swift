//
//  FormTextField.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit

class FormTextField: FormFieldCell {
    
    static let identifier = "FormTextField"
    
    let textField = AppTextField()
    
    var enteredText: String {
        return textField.text ?? ""
    }
    
    var onReturn: ((String) -> String?)?
    var onValueChange: ((String) -> String?)?
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
        
        rightView.add(textField)
        textField.delegate = self
        textField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.height),
            textField.bottomAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: -FormSpacing.height),
            textField.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            textField.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width),
        ])
        
    }
    
    
    func configure(field: DocumentFormField,isRequired: Bool = false) {
        super.configure(title: field.label, isRequired: isRequired)
        
        if let text = field.value as? String {
            textField.text = text
        }
        textField.placeholder = field.placeholder ?? ""
    }
    
    func configure(title: String, text: String?,placeholder: String?,isRequired: Bool = false) {
        super.configure(title: title, isRequired: isRequired)
        textField.text = text
        textField.placeholder = placeholder ?? ""
    }
    
    
    @objc func valueChanged() {
        let error = onValueChange?(enteredText)
        if let text = error {
            setErrorLabelText(text)
        }
    }

}

extension FormTextField: UITextFieldDelegate {
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

