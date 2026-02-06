//
//  FormTextField.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//
import UIKit

class FormLabel: FormField {
    
    static let identifier = "FormLabel"
    let contentLabel = UILabel()
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
        contentLabel.text = text
    }
    override func setUpContentView() {
        
        super.setUpContentView()
        
        rightView.basicSetUp(for: contentLabel)
        contentLabel.font = AppFont.body
        contentLabel.applyWrapping()
        NSLayoutConstraint.activate([
            contentLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: PaddingSize.widthPadding),
            contentLabel.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -PaddingSize.widthPadding),
            contentLabel.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
        ])
        
    }
    

}
