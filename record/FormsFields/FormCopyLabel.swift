//
//  FormCopyLabel.swift
//  record
//
//  Created by Esakkinathan B on 04/02/26.
//

import UIKit

class FormCopyLabel: FormFieldCell {
    
    static let identifier = "FormCopyLabel"
    let copyLabel = CopyTextLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
        setTitleLabelCenter()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, text: String,isRequired: Bool = false) {
        super.configure(title: title, isRequired: isRequired)
        copyLabel.setText(text)
    }
    
    override func setUpContentView() {
        
        super.setUpContentView()
        copyLabel.textLabel.font = AppFont.body
        rightView.backgroundColor = .secondarySystemBackground
        copyLabel.contentView.backgroundColor = .tertiarySystemBackground
        rightView.add(copyLabel)
        NSLayoutConstraint.activate([
            copyLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            copyLabel.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width),
            copyLabel.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
        ])
        
    }
    

}
