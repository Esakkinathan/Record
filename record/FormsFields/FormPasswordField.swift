//
//  FormPasswordField.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//
import UIKit
class FormPasswordField: FormTextField {
    static let myidentifier = "FormPasswordField"
    let eyeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: IconName.eyeSlash), for: .normal)
        button.setImage(UIImage(systemName: IconName.eye), for: .selected)
        button.tintColor = AppColor.primaryColor
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        return button
        
    }()
    
    
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
        eyeButton.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        textField.isSecureTextEntry = true
        textField.rightView = eyeButton
        textField.rightViewMode = .always
    }
    
    @objc func togglePassword() {
        textField.isSecureTextEntry.toggle()
        eyeButton.isSelected.toggle()
    }
    
}
