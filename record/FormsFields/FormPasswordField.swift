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
        button.backgroundColor = .clear
        button.clipsToBounds = true
        return button
        
    }()
    let rightContainer = UIView()
    
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
        rightContainer.add(eyeButton)
        
        eyeButton.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        textField.isSecureTextEntry = true
        textField.rightView = rightContainer
        textField.rightViewMode = .always
        
        NSLayoutConstraint.activate([
            eyeButton.centerYAnchor.constraint(equalTo: rightContainer.centerYAnchor),
            eyeButton.leadingAnchor.constraint(equalTo: rightContainer.leadingAnchor, constant: 8),
            eyeButton.trailingAnchor.constraint(equalTo: rightContainer.trailingAnchor, constant: -12),
            eyeButton.widthAnchor.constraint(equalToConstant: 25),
            eyeButton.heightAnchor.constraint(equalToConstant: 25),
            
            rightContainer.widthAnchor.constraint(equalToConstant: 45),
            rightContainer.heightAnchor.constraint(equalToConstant: 25)
        ])

    }
    
    @objc func togglePassword() {
        textField.isSecureTextEntry.toggle()
        eyeButton.isSelected.toggle()
    }
    
}
