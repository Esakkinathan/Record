//
//  FormSelectField.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit

class FormSelectField: FormField {
    
    static let identifier = "FormSelectField"
    let valueLabel = UILabel()
    let imgView = UIImageView()
    
    var onSelectTap: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
        setTitleLabelCenter()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, text: String? = nil,isRequired: Bool = false) {
        super.configure(title: title, isRequired: isRequired)
        valueLabel.text = text ?? AppConstantData.none
    }
    
    override func setUpContentView() {
        
        super.setUpContentView()
        
        rightView.basicSetUp(for: valueLabel)
        rightView.basicSetUp(for: imgView)
        
        valueLabel.font = AppFont.body
        valueLabel.text = AppConstantData.none
        valueLabel.textColor = AppColor.fileUploadColor
        
        imgView.image = UIImage(systemName: "chevron.down")
        imgView.tintColor = AppColor.fileUploadColor

        rightView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapValue))
        rightView.addGestureRecognizer(tap)
        
        NSLayoutConstraint.activate([
            imgView.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -PaddingSize.widthPadding),
            imgView.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
            imgView.widthAnchor.constraint(equalToConstant: 12),

            valueLabel.trailingAnchor.constraint(equalTo: imgView.leadingAnchor, constant: -PaddingSize.widthPadding),
            valueLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: PaddingSize.widthPadding),
            valueLabel.centerYAnchor.constraint(equalTo: rightView.centerYAnchor)
        ])
    }
    @objc func didTapValue() {
        onSelectTap?()
    }
    
}
