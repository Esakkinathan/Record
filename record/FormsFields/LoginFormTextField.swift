//
//  LoginFormTextField.swift
//  record
//
//  Created by Esakkinathan B on 17/02/26.
//
import UIKit

class LoginFormTextField: UITableViewCell {
    static let identifier = "LoginFormTextField"
    let label: UILabel = {
        let label = UILabel()
        label.font = AppFont.heading3
        label.textColor = .label
        return label
    }()
    
    let textField = AppTextField()
    
    private let rightContainer = UIView()

    let errorLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.body
        label.labelSetUp()
        label.textColor = .systemRed
        label.isHidden = true
        return label
    }()
    let imView: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFit
        return image
    }()

    var enteredText: String {
        return textField.text ?? ""
    }

    var onReturn: ((String) -> String?)?
    var onValueChange: ((String) -> String?)?

    private var errorHeightConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func setUpContentView() {
        contentView.add(label)
        contentView.add(textField)
        contentView.add(errorLabel)
        selectionStyle = .none
        
        rightContainer.add(imView)
        textField.delegate = self
        textField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
        textField.rightView = rightContainer
        textField.rightViewMode = .always

        errorHeightConstraint = errorLabel.heightAnchor.constraint(equalToConstant: 0)
        errorHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            imView.centerYAnchor.constraint(equalTo: rightContainer.centerYAnchor),
            imView.leadingAnchor.constraint(equalTo: rightContainer.leadingAnchor, constant: 8),
            imView.trailingAnchor.constraint(equalTo: rightContainer.trailingAnchor, constant: -12),
            imView.widthAnchor.constraint(equalToConstant: 18),
            imView.heightAnchor.constraint(equalToConstant: 18),
            
            rightContainer.widthAnchor.constraint(equalToConstant: 38),
            rightContainer.heightAnchor.constraint(equalToConstant: 18)
        ])

        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.height),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width),
            
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: PaddingSize.height),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width),
            textField.heightAnchor.constraint(equalToConstant: 60),
            
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width),
            errorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
        ])
    }
    
    private func hideError() {
        guard let tableView = self.superview as? UITableView else { return }

        errorHeightConstraint.constant = 0
        
        UIView.animate(withDuration: 0.25) {
            tableView.beginUpdates()
            tableView.endUpdates()
            self.layoutIfNeeded()
        }
    }
    
    func setErrorLabelText(_ error: String?) {
        guard let tableView = self.superview as? UITableView else { return }

        if let text = error {
            errorLabel.text = text
            errorLabel.isHidden = false
            
            errorHeightConstraint.constant = 20
            
            UIView.animate(withDuration: 0.25) {
                tableView.beginUpdates()
                tableView.endUpdates()
                self.layoutIfNeeded()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                self?.hideError()
            }

        } else {
            hideError()
        }
    }

    func configure(title: String, placeholder: String?, image: String) {
        textField.placeholder = placeholder
        imView.image = UIImage(systemName: image)
        
        let fullText = "\(FormFieldCell.required) \(title)"
        let attributedText = NSMutableAttributedString(
            string: fullText,
            attributes: [.font: AppFont.small]
        )
        attributedText.addAttributes([.foregroundColor: UIColor.systemRed],
                                     range: NSRange(location: 0,
                                    length: FormFieldCell.required.count))
    
        label.attributedText = attributedText
    }
    
    @objc func valueChanged() {
        let error = onValueChange?(enteredText)
        if let text = error {
            setErrorLabelText(text)
        }
    }
    
}


extension LoginFormTextField: UITextFieldDelegate {
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

class LoginPasswordField: LoginFormTextField {
    
    static let myIdentifier = "LoginPasswordField"
    
    let eyeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: IconName.eyeSlash), for: .normal)
        button.setImage(UIImage(systemName: IconName.eye), for: .selected)
        button.tintColor = AppColor.primaryColor
        button.backgroundColor = .clear
        button.clipsToBounds = true
        return button
        
    }()
    let rightView = UIView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUpContentView() {
        super.setUpContentView()
        eyeButton.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        textField.isSecureTextEntry = true
        textField.rightView = rightView
        textField.rightViewMode = .always
        
        rightView.add(eyeButton)
        
        NSLayoutConstraint.activate([
            eyeButton.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
            eyeButton.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: 8),
            eyeButton.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -12),
            eyeButton.widthAnchor.constraint(equalToConstant: 25),
            eyeButton.heightAnchor.constraint(equalToConstant: 25),
            
            rightView.widthAnchor.constraint(equalToConstant: 45),
            rightView.heightAnchor.constraint(equalToConstant: 25)
        ])

    }
    
    @objc func togglePassword() {
        textField.isSecureTextEntry.toggle()
        eyeButton.isSelected.toggle()
    }
    
    func configure(title: String, placeholder: String?) {
        textField.placeholder = placeholder
        let fullText = "\(FormFieldCell.required) \(title)"
        let attributedText = NSMutableAttributedString(
            string: fullText,
            attributes: [.font: AppFont.small]
        )
        attributedText.addAttributes([.foregroundColor: UIColor.systemRed],
                                     range: NSRange(location: 0,
                                    length: FormFieldCell.required.count))
    
        label.attributedText = attributedText

    }
}

class Savebutton: UITableViewCell {
    static let identifier = "LoginButton"
    let button: AppButton = {
        let button = AppButton(type: .system)
        button.titleLabel?.font = AppFont.heading3
        return button
    }()
    var onButtonClicked: (() -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUpContentView() {
        contentView.add(button)
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: FormSpacing.height),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -FormSpacing.height),
            button.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            button.heightAnchor.constraint(equalToConstant: 60),

        ])
    }
    func configure(text: String) {
        button.setTitle(text, for: .normal)
    }
    
    @objc func buttonClicked() {
        onButtonClicked?()
    }

}

class NavigationButton: UITableViewCell {
    static let identifier = "NavigationButton"
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = AppFont.heading3
        return button
    }()
    var onButtonClicked: (() -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUpContentView() {
        contentView.add(button)
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: FormSpacing.height),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -FormSpacing.height),
            button.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            button.heightAnchor.constraint(equalToConstant: 60),

        ])
    }
    func configure(text: String) {
        button.setTitle(text, for: .normal)
    }
    
    @objc func buttonClicked() {
        onButtonClicked?()
    }

}
