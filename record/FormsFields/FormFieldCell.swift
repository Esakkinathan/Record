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
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.body
        label.textAlignment = .right
        label.labelSetUp()
        return label
    }()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.small
        label.labelSetUp()
        label.textColor = .systemRed
        label.isHidden = true
        return label
    }()
    
    static let required = "*"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func setUpContentView() {
        contentView.add(leftView)
        contentView.add(rightView)
        contentView.add(errorLabel)
        leftView.add(titleLabel)
        leftView.backgroundColor = AppColor.gray
        selectionStyle = .none
        
        NSLayoutConstraint.activate([
            leftView.topAnchor.constraint(equalTo: contentView.topAnchor),
            leftView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            leftView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            leftView.trailingAnchor.constraint(equalTo: rightView.leadingAnchor),
            leftView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            
            rightView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rightView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            rightView.leadingAnchor.constraint(equalTo: leftView.trailingAnchor),
            rightView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: leftView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: -FormSpacing.width),
            
            errorLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            errorLabel.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width),
            errorLabel.bottomAnchor.constraint(equalTo: rightView.bottomAnchor, constant: -FormSpacing.height),
            
        ])
                
    }
    
    func setTitleLabelCenter() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: leftView.centerYAnchor)
        ])
    }
    func setTitleLabelTop() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: leftView.topAnchor, constant: FormSpacing.height)
        ])
    }

    
    func configure(title: String, isRequired: Bool = false) {
        if isRequired {
            let fullText = "\(FormFieldCell.required) \(title)"
            
            let attributedText = NSMutableAttributedString(
                string: fullText,
                attributes: [.font: AppFont.caption]
            )
            attributedText.addAttributes([.foregroundColor: UIColor.systemRed],
                                         range: NSRange(location: 0,
                                        length: FormFieldCell.required.count))
            
            titleLabel.attributedText = attributedText
            
        } else {
            titleLabel.text =  title
        }
    }
    
    func setErrorLabelText(_ error: String?) {
        if let text = error {
            errorLabel.text = text
            errorLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                self?.errorLabel.isHidden = true
            }
        } else {
            errorLabel.isHidden = true
        }
        
    }
    
}
