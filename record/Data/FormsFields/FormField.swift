//
//  FormField.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//
import UIKit

class FormField: UITableViewCell {
    let leftView = UIView()
    let rightView = UIView()
    let titleLabel = UILabel()
    
    static let required = "*"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func setUpContentView() {
        contentView.basicSetUp(for: leftView)
        contentView.basicSetUp(for: rightView)
        
        leftView.backgroundColor = AppColor.primaryColor
        leftView.basicSetUp(for: titleLabel)
        
        titleLabel.font = AppFont.caption
        titleLabel.textAlignment = .right
        titleLabel.applyWrapping()
        
        NSLayoutConstraint.activate([
            leftView.topAnchor.constraint(equalTo: contentView.topAnchor),
            leftView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            leftView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            leftView.trailingAnchor.constraint(equalTo: rightView.leadingAnchor),
            
            rightView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rightView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            rightView.leadingAnchor.constraint(equalTo: leftView.leadingAnchor),
            rightView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: leftView.trailingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: leftView.trailingAnchor),

        ])
                
    }
    
    func setTitleLabelCenter() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: leftView.centerYAnchor)
        ])
    }
    func setTitleLabelTop() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: leftView.topAnchor, constant: PaddingSize.heightPadding)
        ])
    }

    
    func configure(title: String, isRequired: Bool = false) {
        if isRequired {
            let fullText = FormField.required + " " + title

            let attributedText = NSMutableAttributedString(
            string: fullText,
            attributes: [.font: AppFont.caption]
            )
            attributedText.addAttributes([.foregroundColor: UIColor.systemRed],
            range: NSRange(location: 0, length: FormField.required.count))

            titleLabel.attributedText = attributedText
            
        }
        titleLabel.text =  title
        
    }
    
}
