//
//  FormField.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//
import UIKit


class FormFieldCell: UITableViewCell {
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
        
        leftView.basicSetUp(for: titleLabel)
        leftView.backgroundColor = .systemGray5
        titleLabel.textColor = .label
        titleLabel.font = AppFont.caption
        titleLabel.textAlignment = .right
        titleLabel.applyWrapping()
        
        NSLayoutConstraint.activate([
            leftView.topAnchor.constraint(equalTo: contentView.topAnchor),
            leftView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            leftView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            leftView.trailingAnchor.constraint(equalTo: rightView.leadingAnchor),
            leftView.widthAnchor.constraint(equalToConstant: contentView.frame.width * 0.4),
            
            rightView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rightView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            rightView.leadingAnchor.constraint(equalTo: leftView.trailingAnchor),
            rightView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: leftView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: -FormSpacing.widthSpace),

        ])
                
    }
    
    func setTitleLabelCenter() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: leftView.centerYAnchor)
        ])
    }
    func setTitleLabelTop() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: leftView.topAnchor, constant: FormSpacing.heightSpace)
        ])
    }

    
    func configure(title: String, isRequired: Bool = false) {
        if isRequired {
            let fullText = FormFieldCell.required + " " + title

            let attributedText = NSMutableAttributedString(
            string: fullText,
            attributes: [.font: AppFont.caption]
            )
            attributedText.addAttributes([.foregroundColor: UIColor.systemRed],
            range: NSRange(location: 0, length: FormFieldCell.required.count))

            titleLabel.attributedText = attributedText
            
        }
        titleLabel.text =  title
    }
    
}
