//
//  FormTextField.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit

class FormTextField: FormField {
    
    static let identifier = "FormTextField"
    
    let textField = AppTextField()
    
    var enteredText: String {
        textField.text ?? ""
    }
    var onReturn: (() -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUpContentView() {
        
        super.setUpContentView()
        
        rightView.basicSetUp(for: textField)
        textField.delegate = self
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: PaddingSize.widthPadding),
            textField.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -PaddingSize.widthPadding),
            textField.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
        ])
        
    }
    
    func configure(title: String, text: String? = nil, placeholder: String,isRequired: Bool = false) {
        super.configure(title: title, isRequired: isRequired)
        if let textFieldText = text {
            textField.text = textFieldText
        }
        textField.placeholder = placeholder
    }
}

extension FormTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturn?()
        return true
    }
}

