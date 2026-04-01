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
class DatePickerPopoverViewController: UIViewController {
    let datePicker = UIDatePicker()
    var onDone: ((Date) -> Void)?

    @objc private func handleTap() {
        datePicker.sendActions(for: .valueChanged)
    }

    @objc private func doneTapped() {
        onDone?(datePicker.date)
        dismiss(animated: true)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.translatesAutoresizingMaskIntoConstraints = false
//        datePicker.minimumDate = AppConstantData.minDate
//        datePicker.maximumDate = AppConstantData.maxDate
        view.addSubview(datePicker)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        datePicker.addGestureRecognizer(tapGesture)

        // Done / Cancel buttons
        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(.secondaryLabel, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        let doneBtn = AppButton()
        doneBtn.setTitle("Done", for: .normal)
        doneBtn.titleLabel?.font = AppFont.body
        doneBtn.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [cancelBtn, doneBtn])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = PaddingSize.content
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(divider)
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            divider.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 4),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5),

            buttonStack.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: PaddingSize.height),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PaddingSize.width),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PaddingSize.width),
            buttonStack.heightAnchor.constraint(equalToConstant: 44),
        ])

        preferredContentSize = CGSize(width: 360, height: 410)
    }
}
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
     
     

//    @objc private func clearDate() {
//        selectedDate = nil
//        clearButton.isHidden = true
//        datePicker.alpha = 0.4
//
//        let error = onValueChange?(nil)
//        setErrorLabelText(error)
//    }

final class FormDateField: FormFieldCell {

    static let identifier = "FormDateField"

    private var selectedDate: Date?

    let datePicker: UIDatePicker = {
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
            //datePicker.date = Date()
            datePicker.alpha = 0.3
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
        datePicker.alpha = 0.3

        let error = onValueChange?(nil)
        setErrorLabelText(error)
    }
}
 */

/*
final class FormDateField: FormFieldCell {

    static let identifier = "FormDateField"

    private var selectedDate: Date?
    private var isPickerVisible = false

    // MARK: Callbacks
    var onHeightChange: (() -> Void)?
    var onDateChange: ((Date?) -> Void)?

    // MARK: Views

    let buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = PaddingSize.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
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
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let clearButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = .secondaryLabel
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isHidden = true
        return btn
    }()

    private let pickerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .inline
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()

    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpContentView()
        setTitleLabelCenter()

        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: Configure

    func configure(title: String, date: Date?, isRequired: Bool = false) {

        super.configure(title: title, isRequired: isRequired)

        selectedDate = date

        if let date {
            dateButton.configuration?.title = date.formatted(date: .abbreviated, time: .omitted)
            datePicker.date = date
            clearButton.isHidden = false
        } else {
            dateButton.configuration?.title = "None"
            clearButton.isHidden = true
        }
    }

    // MARK: Layout

    override func setUpContentView() {

        super.setUpContentView()

        buttonView.addSubview(dateButton)

        rightView.addSubview(buttonView)
        rightView.addSubview(clearButton)
        rightView.addSubview(pickerContainer)

        pickerContainer.addSubview(datePicker)

        let space: CGFloat = 6

        NSLayoutConstraint.activate([

            // buttonView

            buttonView.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.height),
            buttonView.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),

            // date button

            dateButton.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: space),
            dateButton.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: -space),
            dateButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: space),
            dateButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -space),

            // clear button

            clearButton.leadingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: 8),
            clearButton.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 20),
            clearButton.heightAnchor.constraint(equalToConstant: 20),

            // picker container

            pickerContainer.topAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: 8),
            pickerContainer.leadingAnchor.constraint(equalTo: rightView.leadingAnchor),
            pickerContainer.trailingAnchor.constraint(equalTo: rightView.trailingAnchor),
            pickerContainer.bottomAnchor.constraint(equalTo: rightView.bottomAnchor),

            // date picker

            datePicker.topAnchor.constraint(equalTo: pickerContainer.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: pickerContainer.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: pickerContainer.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: pickerContainer.bottomAnchor)
        ])

        // MARK: Targets

        dateButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearDate), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }

    // MARK: Actions

    @objc private func buttonTapped() {

        isPickerVisible.toggle()
        pickerContainer.isHidden = !isPickerVisible

        onHeightChange?()
    }

    @objc private func clearDate() {

        selectedDate = nil
        dateButton.configuration?.title = "None"
        clearButton.isHidden = true

        onDateChange?(nil)
    }

    @objc private func dateChanged() {

        let date = datePicker.date
        selectedDate = date

        dateButton.configuration?.title = date.formatted(date: .abbreviated, time: .omitted)
        clearButton.isHidden = false

        // collapse picker
        isPickerVisible = false
        pickerContainer.isHidden = true

        onHeightChange?()
        onDateChange?(date)
    }
}
*/
     
/*
final class FormDateField: FormFieldCell {

    static let identifier = "FormDateField"

    private var selectedDate: Date?

    let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        dp.translatesAutoresizingMaskIntoConstraints = false
        dp.alpha = 0.02
        return dp
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.text = "DD/MM/YYYY"
        label.textColor = .secondaryLabel
        label.font = AppFont.body
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let clearButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: IconName.x), for: .normal)
        btn.tintColor = .secondaryLabel
        btn.translatesAutoresizingMaskIntoConstraints = false
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

    // MARK: Configure

    func configure(title: String, date: Date?, isRequired: Bool = false) {
        super.configure(title: title, isRequired: isRequired)

        if let date {
            setDate(date)
        } else {
            showPlaceholder()
        }
    }

    // MARK: Setup

    override func setUpContentView() {
        super.setUpContentView()

        rightView.add(datePicker)
        rightView.add(valueLabel)
        rightView.add(clearButton)

        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        clearButton.addTarget(self, action: #selector(clearDate), for: .touchUpInside)
//        valueLabel.isUserInteractionEnabled = true
//        let tap = UITapGestureRecognizer(target: self, action: #selector(openDatePicker))
//        valueLabel.addGestureRecognizer(tap)
        NSLayoutConstraint.activate([

            // LABEL
            valueLabel.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.height),
            valueLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            valueLabel.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -8),

            // DATE PICKER (same frame as label)
            datePicker.topAnchor.constraint(equalTo: valueLabel.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: valueLabel.bottomAnchor),

            // CLEAR BUTTON
            clearButton.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width),
            clearButton.widthAnchor.constraint(equalToConstant: 20),
            clearButton.heightAnchor.constraint(equalToConstant: 20),

            // ERROR LABEL
            errorLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            errorLabel.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width),
            errorLabel.bottomAnchor.constraint(equalTo: rightView.bottomAnchor, constant: -FormSpacing.height),
        ])        //rightView.bringSubviewToFront(datePicker)
    }
    
    @objc func openDatePicker() {
        print("i an running ")
        datePicker.sendActions(for: .touchUpInside)
    }

    // MARK: Date Logic

    @objc private func dateChanged() {
        selectedDate = datePicker.date
        updateLabel(datePicker.date)
        clearButton.isHidden = false

        let error = onValueChange?(selectedDate)
        setErrorLabelText(error)
    }

    @objc private func clearDate() {
        selectedDate = nil
        showPlaceholder()
        clearButton.isHidden = true

        let error = onValueChange?(nil)
        setErrorLabelText(error)
    }

    // MARK: UI Updates

    private func updateLabel(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"

        valueLabel.text = formatter.string(from: date)
        valueLabel.textColor = .label
    }

    private func showPlaceholder() {
        valueLabel.text = "DD/MM/YYYY"
        valueLabel.textColor = .secondaryLabel
    }

    private func setDate(_ date: Date) {
        selectedDate = date
        datePicker.date = date
        updateLabel(date)
        clearButton.isHidden = false
    }
}
*/
