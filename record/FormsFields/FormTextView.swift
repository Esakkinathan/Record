//
//  FormTextView.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

import UIKit

class FormTextView: FormFieldCell, FormCell {
    
    func register(tableView: UITableView) {
        tableView.register(FormTextView.self, forCellReuseIdentifier: identifier)
    }
    
    func dequeue(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        return cell
    }

    
    var identifier = "FormTextView"
    let textView = UITextView()
    var onValueChange: ((String) -> String?)?
    
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
        textView.text = text
        textView.delegate = self
    }
    
    override func setUpContentView() {
        
        super.setUpContentView()
        
        rightView.add(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.height),
            textView.bottomAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: -FormSpacing.height),
            textView.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            textView.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width),
        ])
        
    }
    
}
extension FormTextView: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let error = onValueChange?(textView.text)
        setErrorLabelText(error)
    }
}
