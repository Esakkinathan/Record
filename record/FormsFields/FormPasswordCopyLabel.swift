//
//  FormPasswordCopyLabel.swift
//  record
//
//  Created by Esakkinathan B on 25/02/26.
//
import UIKit

class FormPasswordCopyLabel: FormFieldCell {
    
    static let identifier = "FormPasswordCopyLabel"
    let copyLabel = PasswordCopyLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
        setTitleLabelCenter()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, text: String,date: Date?,isRequired: Bool = false, onCopy: (() -> Void)? ) {
        super.configure(title: title, isRequired: isRequired)
        copyLabel.password = text
        copyLabel.lastCopiedDate = date
        copyLabel.onCopy = onCopy
        
    }
    
    override func setUpContentView() {
        
        super.setUpContentView()
        //.textLabel.font = AppFont.body
        rightView.backgroundColor = .secondarySystemBackground
        rightView.add(copyLabel)
        NSLayoutConstraint.activate([
            copyLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            copyLabel.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width),
            copyLabel.topAnchor.constraint(equalTo: rightView.topAnchor, constant: PaddingSize.height),
            copyLabel.bottomAnchor.constraint(equalTo: rightView.bottomAnchor, constant: -PaddingSize.height),
        ])
        
    }
}
