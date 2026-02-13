//
//  FormTextView.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

import UIKit

class FormTextView: FormFieldCell {
    

    
    static let identifier = "FormTextView"
    let textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = AppColor.background
        view.textColor = .label
        view.isEditable = true
        view.isScrollEnabled = true
        view.isSelectable = true
        view.autocorrectionType = .no
        return view
    }()
    var onValueChange: ((String) -> String?)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
        setTitleLabelCenter()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, text: String?,isRequired: Bool = false) {
        super.configure(title: title, isRequired: isRequired)
        textView.text = text
        
    }
    
    override func setUpContentView() {
        
        super.setUpContentView()
        
        textView.delegate = self
        rightView.add(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: rightView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: errorLabel.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: rightView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width),
            textView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
    }
    
}
extension FormTextView: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let error = onValueChange?(textView.text)
        setErrorLabelText(error)
    }
}
/*
 class FormTextFieldPickerField: FormFieldCell {
     
     static let identifier = "FormTextFieldPickerField"
     
     let textField = AppTextField()
     
     var enteredText: String {
         return textField.text ?? ""
     }
     
     let valueLabel: UILabel = {
         let label = UILabel()
         label.font = AppFont.body
         label.textColor = .label
         label.textAlignment = .right
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
     var onReturn: ((String) -> String?)?
     var onTextValueChange: ((String) -> String?)?
     
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
         
         rightView.add(textField)
         textField.delegate = self
         textField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
         
         let stack = UIStackView(arrangedSubviews: [valueLabel,arrowImageView])
         stack.axis = .horizontal
         stack.spacing = PaddingSize.content
         rightView.add(stack)
                         
         rightView.isUserInteractionEnabled = true
         let tap = UITapGestureRecognizer(target: self, action: #selector(didTapValue))
         stack.addGestureRecognizer(tap)

         NSLayoutConstraint.activate([
             textField.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.height),
             textField.bottomAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: -FormSpacing.height),
             textField.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
             textField.trailingAnchor.constraint(equalTo: stack.leadingAnchor, constant: -FormSpacing.width),
             textField.widthAnchor.constraint(equalTo: rightView.widthAnchor, multiplier: 0.5),

             stack.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.height),
             stack.bottomAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: -FormSpacing.height),
             stack.trailingAnchor.constraint(equalTo: rightView.trailingAnchor,constant: -FormSpacing.width * 2 ),
             stack.widthAnchor.constraint(equalTo: rightView.widthAnchor, multiplier: 0.4),
         ])
         
     }

     func configure(field: DocumentFormField,isRequired: Bool = false) {
         super.configure(title: field.label, isRequired: isRequired)
         
         if let text = field.value as? String {
             textField.text = text
         }
         textField.placeholder = field.placeholder ?? ""
     }
     
     func configure(title: String, text: String?,placeholder: String?,selectedValue: String,isRequired: Bool = false) {
         super.configure(title: title, isRequired: isRequired)
         textField.text = text
         textField.placeholder = placeholder ?? ""
     }
     
     
     @objc func valueChanged() {
         let error = onTextValueChange?(enteredText)
         if let text = error {
             setErrorLabelText(text)
         }
     }
     
     @objc func didTapValue() {
         onSelectClicked?()
     }


 }

 extension FormTextFieldPickerField: UITextFieldDelegate {
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         let error = onReturn?(enteredText)
         if let text = error {
             setErrorLabelText(text)
             return false
         } else {
             return true
         }
     }
 }

 
 */
 
