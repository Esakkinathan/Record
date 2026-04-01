//
//  RemainderCell.swift
//  record
//
//  Created by Esakkinathan B on 19/03/26.
//
import UIKit

final class TimePickerPopoverViewController: UIViewController {

    let datePicker = UIDatePicker()
    var onDone: ((Int, Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.datePickerMode        = .time
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)

        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(.secondaryLabel, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        let doneBtn = AppButton()
        doneBtn.setTitle("Done", for: .normal)
        doneBtn.titleLabel?.font = AppFont.body
        doneBtn.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [cancelBtn, doneBtn])
        buttonStack.axis         = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing      = PaddingSize.content
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
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PaddingSize.width * 3),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PaddingSize.width * 3),
            buttonStack.heightAnchor.constraint(equalToConstant: 44)
        ])

        preferredContentSize = CGSize(width: 320, height: 300)
    }

    // MARK: - Helpers

    /// Set initial time before presenting
    func setTime(hour: Int, minute: Int, schedule: MedicalSchedule) {
        var c = DateComponents()
        c.hour   = hour
        c.minute = minute
        if let date = Calendar.current.date(from: c) {
            datePicker.date = date
        }
        var minDateC = DateComponents()
        minDateC.hour = schedule.minTime
        datePicker.minimumDate = Calendar.current.date(from: minDateC)

        var maxDateC = DateComponents()
        maxDateC.hour = schedule.maxTime      
        datePicker.maximumDate = Calendar.current.date(from: maxDateC)

    }

    // MARK: - Actions

    @objc private func doneTapped() {
        let cal    = Calendar.current
        let hour   = cal.component(.hour,   from: datePicker.date)
        let minute = cal.component(.minute, from: datePicker.date)
        onDone?(hour, minute)
        dismiss(animated: true)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

final class ReminderRowCell: UITableViewCell {

    static let identifier = "ReminderRowCell"

    // Called when user taps the time button — passes the button as popover anchor
    var onTimeTapped: ((UIButton) -> Void)?

    // MARK: - UI

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor   = AppColor.primaryColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 16, weight: .medium)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Right-side button: calendar icon + time text
    private let timeButton: UIButton = {
        var config                        = UIButton.Configuration.plain()
        config.imagePadding               = 5
        config.baseForegroundColor        = AppColor.primaryColor
        config.image                      = UIImage(systemName: "clock")
        config.preferredSymbolConfigurationForImage =
            UIImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle  = .none
        backgroundColor = .secondarySystemBackground

        [iconView, titleLabel, timeButton].forEach { contentView.addSubview($0) }

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            timeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            timeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            timeButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])

        timeButton.addTarget(self, action: #selector(timeTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Configure

    func configure(with reminder: MedicalScheduleTime) {
        iconView.image  = UIImage(systemName: reminder.schedule.image)
        titleLabel.text = reminder.schedule.rawValue

        var config      = timeButton.configuration
        config?.title   = reminder.timeString
        timeButton.configuration = config
    }

    // MARK: - Action

    @objc private func timeTapped() {
        onTimeTapped?(timeButton)
    }
}
