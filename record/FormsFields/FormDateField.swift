//
//  FormDateField.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//
import UIKit

class FormDateField: FormField {
    
    static let identifier = "FormDateField"
    let datePicker = UIDatePicker()
    var onDateChange: ((Date) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
        setTitleLabelCenter()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, date: Date? = nil, isRequired: Bool = false) {
        super.configure(title: title,isRequired: isRequired)
        if let dateProvided = date {
            datePicker.date = dateProvided
        }
    }
    override func setUpContentView() {
        
        super.setUpContentView()
        
        rightView.basicSetUp(for: datePicker)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: PaddingSize.widthPadding),
            datePicker.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -PaddingSize.widthPadding),
            datePicker.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
        ])
        
    }
    
    @objc func dateChanged() {
        onDateChange?(datePicker.date)
    }

    

}
