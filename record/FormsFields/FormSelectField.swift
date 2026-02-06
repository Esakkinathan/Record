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
        label.textAlignment = .right
        return label
    }()
    let arrowImageView: UIImageView = {
       let imgView = UIImageView()
        imgView.image = UIImage(systemName: IconName.greaterThan)
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = AppColor.primaryColor
        return imgView
    }()
    var onSelectClicked: (() -> Void)?
    
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
    
    override func setUpContentView() {
        
        super.setUpContentView()
        
        let stack = UIStackView(arrangedSubviews: [valueLabel,arrowImageView])
        stack.axis = .horizontal
        stack.spacing = PaddingSize.content
        rightView.add(stack)
                        
        rightView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapValue))
        rightView.addGestureRecognizer(tap)
        
        NSLayoutConstraint.activate([
            stack.bottomAnchor.constraint(equalTo: errorLabel.topAnchor ),
            stack.centerYAnchor.constraint(equalTo: rightView.centerYAnchor, ),
            stack.trailingAnchor.constraint(equalTo: rightView.trailingAnchor,constant: -FormSpacing.width ),
        ])
    }
    @objc func didTapValue() {
        onSelectClicked?()
    }
    
    //    func register(tableView: UITableView) {
    //        tableView.register(FormSelectField.self, forCellReuseIdentifier: identifier)
    //    }
    //
    //    func dequeue(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
    //        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    //        return cell
    //    }


    
}
