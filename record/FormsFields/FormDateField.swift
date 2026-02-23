//
//  FormDateField.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//
import UIKit
/*
class FormDateField: FormFieldCell {
    
//    func register(tableView: UITableView) {
//        tableView.register(FormDateField.self, forCellReuseIdentifier: identifier)
//    }
//    
//    func dequeue(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
//        return cell
//    }
    
    
    static let identifier = "FormDateField"
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()
    
    var onValueChange: ((Date) -> String?)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
        setTitleLabelCenter()
    }
    
    required init?(coder: NSCoder) {
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
        
        rightView.add(datePicker)
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.height),
            datePicker.bottomAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: -FormSpacing.height),
            datePicker.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            datePicker.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width),
        ])
        
    }
    
    @objc func dateChanged() {
        let errorMessage =  onValueChange?(datePicker.date)
        setErrorLabelText(for: errorMessage)
    }

    

}
*/
final class FormDateField: FormFieldCell {

    static let identifier = "FormDateField"

    private var selectedDate: Date?

    private let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        return dp
    }()

    private let clearButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: IconName.x), for: .normal)
        btn.tintColor = .secondaryLabel
        btn.isHidden = true
        return btn
    }()

    var onValueChange: ((Date?) -> String?)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
        setTitleLabelCenter()
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(field: DocumentFormField,isRequired: Bool = false) {
        super.configure(title: field.label, isRequired: isRequired)

        if let date = field.value as? Date {
            selectedDate = date
            datePicker.date = date
            datePicker.alpha = 1.0
        } else {
            selectedDate = nil
            datePicker.date = Date()
            datePicker.alpha = 0.4
        }
    }
    
    func configure(title: String, date: Date?,isRequired: Bool = false) {
        super.configure(title: title, isRequired: isRequired)

        if let newDate = date {
            selectedDate = newDate
            datePicker.date = newDate
            datePicker.alpha = 1.0
        } else {
            selectedDate = nil
            //datePicker.date = Date()
            datePicker.alpha = 0.4
        }
    }


    override func setUpContentView() {
        super.setUpContentView()

        rightView.add(datePicker)
        rightView.add(clearButton)

        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        clearButton.addTarget(self, action: #selector(clearDate), for: .touchUpInside)

        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.height),
            datePicker.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            datePicker.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -8),

            clearButton.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width),
            clearButton.widthAnchor.constraint(equalToConstant: 20),
            clearButton.heightAnchor.constraint(equalToConstant: 20),

            errorLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            errorLabel.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width),
            errorLabel.bottomAnchor.constraint(equalTo: rightView.bottomAnchor, constant: -FormSpacing.height)
        ])
    }

    @objc private func dateChanged() {
        selectedDate = datePicker.date
        clearButton.isHidden = false
        datePicker.alpha = 1.0

        let error = onValueChange?(selectedDate)
        setErrorLabelText(error)
    }

    @objc private func clearDate() {
        selectedDate = nil
        clearButton.isHidden = true
        datePicker.alpha = 0.4

        let error = onValueChange?(nil)
        setErrorLabelText(error)
    }
}
