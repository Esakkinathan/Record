//
//  FormTextField.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit

protocol FormTextFieldDelegate: AnyObject {
    func didValueChanged(text: String) -> String?
    func onReturn(text: String?) -> String?
    func showErrorOnLengthExceeds(_ msg: String)
}

class FormTextField: FormFieldCell {
    
    static let identifier = "FormTextField"
    
    let textField = AppTextField()
    
    var enteredText: String {
        return textField.text ?? ""
    }
    weak var delegate: FormTextFieldDelegate?
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.small
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    var maxCount = 30
    var onReturn: ((String) -> String?)?
    var onValueChange: ((String) -> String?)?
    var showErrorOnLengthExceeds: ((String) -> Void)?
    
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
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: countLabel.frame.width + 12, height: textField.frame.height))
        paddingView.add(countLabel)
        //countLabel.text = "\(textField.text?.count ?? 0)/\(maxCount)"
        textField.rightView = countLabel
        
        textField.rightViewMode = .whileEditing
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.height),
            textField.bottomAnchor.constraint(equalTo: errorLabel.topAnchor, constant: -2),
            textField.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            textField.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width),
        ])
        
    }
    
        
    func configure(title: String, text: String?,placeholder: String?,isRequired: Bool = false, maxCount: Int = 30) {
        super.configure(title: title, isRequired: isRequired)
        textField.text = text
        textField.placeholder = placeholder ?? ""
        self.maxCount = maxCount
    }
    
    
    @objc func valueChanged() {
        let text = textField.text ?? ""
        let textCount = text.count
        if textCount > maxCount {
            let endIndex = text.index(text.startIndex, offsetBy: maxCount, limitedBy: text.endIndex) ?? text.endIndex
            
            textField.text = String(text[..<endIndex])
            
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: maxCount) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                }
            showErrorOnLengthExceeds?("Enter maximum of \(maxCount) characters")
        }
        countLabel.text = "\(textField.text?.count ?? 0)/\(maxCount)"
        
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

