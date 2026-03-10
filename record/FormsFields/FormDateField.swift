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

    let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        return dp
    }()
    let buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = PaddingSize.cornerRadius
        return view
    }()

    private let dateButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "None"
        config.image = UIImage(systemName: "calendar")
        config.imagePadding = 6
        config.baseForegroundColor = .label
        
        let btn = UIButton(configuration: config)
        btn.contentHorizontalAlignment = .leading
        return btn
    }()
    private let clearButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: IconName.x), for: .normal)
        btn.tintColor = .secondaryLabel
        btn.isHidden = true
        return btn
    }()

    var onValueChange: ((Date?) -> String?)?
    var onButtonClicked: ((Date?) -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
        setTitleLabelCenter()
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func configure(title: String, date: Date?,isRequired: Bool = false) {
        super.configure(title: title, isRequired: isRequired)

        if let newDate = date {
            selectedDate = newDate
            dateButton.configuration?.title = newDate.toString()
            clearButton.isHidden = false
        } else {
            selectedDate = nil
            //datePicker.date = Date()
            //datePicker.alpha = 0.4
            dateButton.configuration?.title = AppConstantData.none
            clearButton.isHidden = true
        }
    }

/*
    override func setUpContentView() {
        super.setUpContentView()

        rightView.add(datePicker)
        rightView.add(clearButton)
        datePicker.addTarget(self, action: #selector(dateSelected), for: .editingDidEnd)

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
 
 */
    override func setUpContentView() {
        super.setUpContentView()
        buttonView.add(dateButton)
        let space: CGFloat = 3
        NSLayoutConstraint.activate([
            
            dateButton.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: space),
            dateButton.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: -space),
            dateButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: space),
            dateButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -space),
            
        ])

        rightView.add(buttonView)
        rightView.add(clearButton)

        dateButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearDate), for: .touchUpInside)

        NSLayoutConstraint.activate([
            buttonView.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.height),
            buttonView.bottomAnchor.constraint(equalTo: rightView.bottomAnchor, constant: -FormSpacing.height),
            buttonView.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            //dateButton.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -8),

            clearButton.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor),
            clearButton.leadingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: FormSpacing.width),
            clearButton.widthAnchor.constraint(equalToConstant: 20),
            clearButton.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    private func setDate(_ date: Date) {
        selectedDate = date
        clearButton.isHidden = false

        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        dateButton.configuration?.title = formatter.string(from: date)

        let error = onValueChange?(date)
        setErrorLabelText(error)
    }
    @objc private func clearDate() {
        selectedDate = nil
        clearButton.isHidden = true
        dateButton.configuration?.title = "None"

        let error = onValueChange?(nil)
        setErrorLabelText(error)
    }
    
    @objc func buttonClicked() {
        onButtonClicked?(selectedDate)
    }
    
    @objc private func dateSelected() {
        if selectedDate == nil {
            selectedDate = datePicker.date
            clearButton.isHidden = false
            datePicker.alpha = 1.0

            let error = onValueChange?(selectedDate)
            setErrorLabelText(error)
        }
    }
    @objc private func dateChanged() {
        let newDate = datePicker.date

        if selectedDate == nil || selectedDate != newDate {
            selectedDate = newDate
            clearButton.isHidden = false
            datePicker.alpha = 1.0
        }

        let error = onValueChange?(selectedDate)
        setErrorLabelText(error)
    }
//    @objc private func clearDate() {
//        selectedDate = nil
//        clearButton.isHidden = true
//        datePicker.alpha = 0.4
//
//        let error = onValueChange?(nil)
//        setErrorLabelText(error)
//    }
}
