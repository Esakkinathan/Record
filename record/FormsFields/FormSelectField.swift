//
//  FormSelectField.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit

class FormSelectField: FormFieldCell {
    
    
    static let identifier = "FormSelectField"
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.body
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let arrowImageView: UIImageView = {
       let imgView = UIImageView()
        imgView.image = UIImage(systemName: IconName.arrowRight)
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = AppColor.primaryColor
        return imgView
    }()
    var onSelectClicked: (() -> Void)?
    let stack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = PaddingSize.content
        stack.distribution = .fill
        return stack
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
        setTitleLabelCenter()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(field: DocumentFormField,isRequired: Bool = false) {
        super.configure(title: field.label, isRequired: isRequired)
        if let text = field.value as? String {
            valueLabel.text = text
        } else {
            valueLabel.text = DefaultDocument.defaultValue.rawValue
        }
    }
    
    func configure(title: String, text: String?, isRequired: Bool = false) {
        super.configure(title: title, isRequired: isRequired)
        valueLabel.text = text ?? AppConstantData.none
    }
    /*
    override func setUpContentView() {
        
        super.setUpContentView()
        //rightView.add(stack)
                        
        rightView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapValue))
        rightView.addGestureRecognizer(tap)
        rightView.add(valueLabel)
        rightView.add(arrowImageView)
        NSLayoutConstraint.activate([
            
            
            valueLabel.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.height),
            valueLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            valueLabel.bottomAnchor.constraint(equalTo: errorLabel.topAnchor, constant: -2),
            valueLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -FormSpacing.width),
            
            arrowImageView.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
            
            arrowImageView.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width * 2),
            
        ])
    }*/
    override func setUpContentView() {
        super.setUpContentView()
        
        rightView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapValue))
        rightView.addGestureRecognizer(tap)
        
        rightView.add(stack)
        
        stack.addArrangedSubview(valueLabel)
        stack.addArrangedSubview(arrowImageView)
        
        arrowImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        arrowImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        arrowImageView.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            
            stack.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.height),
            stack.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            stack.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width-4),
            stack.bottomAnchor.constraint(equalTo: errorLabel.topAnchor, constant: -2)
            
        ])
    }

    @objc func didTapValue() {
        onSelectClicked?()
    }
    
}

class FormURlLabel: FormFieldCell {

    static let identifier = "FormURlLabel"

    let valueTextView: UITextView = {
        let tv = UITextView()
        tv.font = AppFont.body
        tv.textColor = .label
        tv.isEditable = false
        tv.isSelectable = true
        tv.isScrollEnabled = false
        tv.dataDetectorTypes = [.link]
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()

    let arrowImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(systemName: IconName.arrowRight)
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = AppColor.primaryColor
        imgView.isUserInteractionEnabled = true
        return imgView
    }()

    var onSelectClicked: (() -> Void)?

    let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = PaddingSize.content
        stack.distribution = .fill
        stack.alignment = .top
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
        setTitleLabelCenter()
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Configure

    func configure(title: String, url: String?, isRequired: Bool = false) {
        super.configure(title: title, isRequired: isRequired)

        guard let url else {
            valueTextView.text = AppConstantData.none
            return
        }

        valueTextView.text = url
    }

    // MARK: Layout

    override func setUpContentView() {
        super.setUpContentView()

        rightView.add(stack)

        stack.addArrangedSubview(valueTextView)
        stack.addArrangedSubview(arrowImageView)

        arrowImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        arrowImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        arrowImageView.setContentHuggingPriority(.required, for: .horizontal)

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapArrow))
        arrowImageView.addGestureRecognizer(tap)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.height),
            stack.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            stack.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width),
            stack.bottomAnchor.constraint(equalTo: errorLabel.topAnchor, constant: -2)
        ])
    }

    // MARK: Actions

    @objc private func didTapArrow() {
        onSelectClicked?()
    }
}
