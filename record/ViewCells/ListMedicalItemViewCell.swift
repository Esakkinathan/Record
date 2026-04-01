//
//  ListMedicalItemViewCell.swift
//  record
//
//  Created by Esakkinathan B on 17/02/26.
//
import UIKit


class ImageTextView: UIView {
    let imageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = AppFont.body
        label.textColor = .label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        
        return label
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        //label.setContentCompressionResistancePriority(.required, for: .horizontal)
        setUpContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpContents() {
        add(imageView)
        add(label)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: PaddingSize.content),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),

        ])
    }
    
    func configure(text: String ) {
        label.text = text
    }
    func configure(image: String, _ tint: UIColor) {
        imageView.image = UIImage(systemName: image)
        imageView.tintColor = tint
    }
}

class ToggleView: UIView {
    let toggle = UISwitch()
    let markLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = AppFont.caption
        return label
    }()
    var onToggleChanged: ((Bool) -> Void)?
    var text: String = "" {
        didSet {
            markLabel.text = text
        }
    }
    var isOn: Bool = false {
        didSet {
            toggle.setOn(isOn, animated: false )
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpContents() {
        layer.cornerRadius = PaddingSize.cornerRadius
        add(toggle)
        add(markLabel)
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
        backgroundColor = .secondarySystemBackground
        NSLayoutConstraint.activate([
            
            markLabel.topAnchor.constraint(equalTo: topAnchor, constant: PaddingSize.content),
            markLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PaddingSize.content),
            markLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -PaddingSize.content),
            toggle.topAnchor.constraint(equalTo: markLabel.bottomAnchor, constant: PaddingSize.content),
            toggle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -PaddingSize.content),
            toggle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PaddingSize.content),
            toggle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -PaddingSize.content)
        ])

    }
    
    @objc func toggleChanged() {
        onToggleChanged?(toggle.isOn)
    }


}


class ListMedicalItemViewCell: UITableViewCell {
    let label1: ImageTextView = {
        let label = ImageTextView()
        label.label.font = AppFont.heading3
        label.label.textColor = .label
        label.configure(image: IconName.medicalName, AppColor.primaryColor)
        return label
    }()
    let label2: ImageTextView = {
        let label = ImageTextView()
        label.label.font = AppFont.body
        label.label.textColor = .secondaryLabel
        label.configure(image: IconName.instruction, AppColor.primaryColor)
        return label
    }()
    let label3: ImageTextView = {
        let label = ImageTextView()
        label.label.font = AppFont.small
        label.label.textColor = .secondaryLabel
        label.configure(image: IconName.dosage, AppColor.primaryColor)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let stack = UIStackView()
    func setUpContentView() {

        stack.addArrangedSubview(label1)
        stack.addArrangedSubview(label2)
        stack.addArrangedSubview(label3)
        stack.axis = .vertical
        stack.spacing = PaddingSize.content
        stack.layer.cornerRadius = PaddingSize.cornerRadius
        stack.backgroundColor = .secondarySystemBackground
        stack.layoutMargins = UIEdgeInsets(top: PaddingSize.content, left: PaddingSize.content, bottom: PaddingSize.content, right: PaddingSize.content)
        stack.isLayoutMarginsRelativeArrangement = true
        
        selectionStyle = .none
        contentView.add(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.content),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.content),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width * 2),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width)
        ])
    }
    
    
    func configure(text1: String, text2: String, text3: String) {
        label1.configure(text: text1)
        label2.configure(text: text2)
        label3.configure(text: text3)
    }
}

class AllListMedicalItemViewCell: ListMedicalItemViewCell {
    
    let scheduleGridView = ScheduleGridView()
    static let identifier = "AllListMedicalItemViewCell"

    var onStateChanged: ((LogStatus) -> Void)?
    
    private let gridContainerWidth: CGFloat = 110
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setUpContentView() {
        super.setUpContentView()

        // Remove old layout
        stack.removeFromSuperview()
        stack.constraints.forEach { $0.isActive = false }
        selectionStyle = .none
        let stackView = UIStackView(arrangedSubviews: [stack, scheduleGridView])
        stackView.axis = .horizontal
        stackView.spacing = PaddingSize.content
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Background & corner radius
        stackView.backgroundColor = .secondarySystemBackground
        stackView.layer.cornerRadius = PaddingSize.cornerRadius
        stackView.layer.masksToBounds = true
        
//        stackView.layoutMargins = UIEdgeInsets(
//            top: PaddingSize.content,
//            left: PaddingSize.content,
//            bottom: PaddingSize.content,
//            right: PaddingSize.content
//        )
        stackView.isLayoutMarginsRelativeArrangement = true
        
        scheduleGridView.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .clear
        scheduleGridView.backgroundColor = .clear

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scheduleGridView.widthAnchor.constraint(equalToConstant: gridContainerWidth),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.height),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width * 2),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width * 2)
        ])
    }

    func configure(text1: String, text2: String, text3: String,
                   schedules: [MedicalSchedule],
                   taken: Set<MedicalSchedule>, enabled: Set<MedicalSchedule>) {
        
        super.configure(text1: text1, text2: text2, text3: text3)
        
        scheduleGridView.configure(
            schedules: schedules,
            takenSchedules: taken,
            enabledSchedules: enabled
        )

        scheduleGridView.onStateChanged = { [weak self] logStatus in
            self?.stateChanged(logStatus: logStatus)
        }
    }

    func stateChanged(logStatus: LogStatus) {
        print("allcell")
        onStateChanged?(logStatus)
    }
}

class ScheduleListMedicalItemViewCell: ListMedicalItemViewCell {
    static let identifier = "ScheduleListMedicalItemViewCell"
    let toggleContainer: ToggleView = {
       let view = ToggleView()
        return view
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setUpContentView() {
        super.setUpContentView()
        contentView.add(toggleContainer)
        stack.constraints.forEach { c in
            if c.firstAttribute == .trailing { c.isActive = false }
        }

        NSLayoutConstraint.activate([
            toggleContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width * 2),
            toggleContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleContainer.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
            stack.trailingAnchor.constraint(equalTo: toggleContainer.leadingAnchor, constant: -PaddingSize.width),

        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //toggleContainer.isHidden = true
    }
    
    func configure(text1: String, text2: String, text3: String, canShow: Bool, state: Bool, onToggle: ((Bool) -> Void)?) {
        super.configure(text1: text1, text2: text2, text3: text3)
        toggleContainer.toggle.isEnabled = canShow
        toggleContainer.text = state ? "Taken" : "Mark as taken"
        toggleContainer.isOn = state
        toggleContainer.onToggleChanged = onToggle
    }
    
}

class ScheduleGridView: UIView {
    
    private var slotViews: [ScheduleSlotView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let label: UILabel = {
       let label = UILabel()
        label.text = "Schedules"
        label.font = AppFont.body
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    var onStateChanged: ((LogStatus) -> Void)?
    
    private func setupView() {
        layer.cornerRadius = PaddingSize.cornerRadius
        backgroundColor = .secondarySystemBackground
        
        // Create 4 slot views for each schedule
        
        for schedule in MedicalSchedule.allCases {
            let slot = ScheduleSlotView()
            slot.configure(schedule: schedule)
            slot.isHidden = true // hidden by default
            slot.stateChanged = { [weak self] logStatus in
                self?.stateChanged(logStatus: logStatus)
            }
            slotViews.append(slot)
            add(slot)
        }
        
        let row1 = UIStackView(arrangedSubviews: [slotViews[0], slotViews[1]])
        row1.spacing = PaddingSize.content
        row1.distribution = .fillEqually
        
        let row2 = UIStackView(arrangedSubviews: [slotViews[2], slotViews[3]])
        row2.spacing = PaddingSize.content
        row2.distribution = .fillEqually
        
        let grid = UIStackView(arrangedSubviews: [label ,row1, row2])
        grid.axis = .vertical
        grid.spacing = PaddingSize.content
        
        add(grid)
        let space: CGFloat = PaddingSize.content
        NSLayoutConstraint.activate([
            grid.topAnchor.constraint(equalTo: topAnchor, constant: space),
            grid.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -space),
            grid.leadingAnchor.constraint(equalTo: leadingAnchor, constant: space),
            grid.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -space),
        ])
    }
    
    func stateChanged(logStatus: LogStatus) {
        print("grid")
        onStateChanged?(logStatus)
    }
    
    func configure(schedules: [MedicalSchedule], takenSchedules: Set<MedicalSchedule>, enabledSchedules: Set<MedicalSchedule>) {
        let allCases = Array(MedicalSchedule.allCases)
        
        for (index, slot) in slotViews.enumerated() {
            let schedule = allCases[index]
            let isIncluded = schedules.contains(schedule)
            slot.isHidden = !isIncluded
            if isIncluded {
                slot.setTaken(takenSchedules.contains(schedule))
                slot.setEnabled(enabledSchedules.contains(schedule))
            }
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
}

class ScheduleSlotDetailView: UIButton {

    var isTaken: Bool = false
    var schedule: MedicalSchedule = .morning

    var stateChanged: ((LogStatus) -> Void)?

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = PaddingSize.cornerRadius + 5

        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        stack.isUserInteractionEnabled = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
        ])
        isUserInteractionEnabled = true
        isExclusiveTouch = true
        iconView.isUserInteractionEnabled = false
        label.isUserInteractionEnabled = false
        addTarget(self, action: #selector(toggleState), for: .touchUpInside)
    }
    

    required init?(coder: NSCoder) { fatalError() }

    func configure(schedule: MedicalSchedule) {
        self.schedule = schedule
        iconView.image = UIImage(systemName: schedule.image)
        label.text = schedule.rawValue
    }

    func setTaken(_ taken: Bool) {
        isTaken = taken

        if taken {
            backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            iconView.tintColor = .systemGreen
        } else {
            backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            iconView.tintColor = .systemRed
        }
    }
    func setEnabled(_ enabled: Bool) {
        isUserInteractionEnabled = enabled
        alpha = enabled ? 1.0 : 0.3
    }

    @objc private func toggleState() {
        print("button")
        setTaken(!isTaken)
        stateChanged?(.init(schedule: schedule, taken: isTaken))
    }
}
class ScheduleSlotView: UIButton {
    var isTaken: Bool = false
    var schedule: MedicalSchedule = .morning
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    func setEnabled(_ enabled: Bool) {
        isUserInteractionEnabled = enabled
        alpha = enabled ? 1.0 : 0.3
    }
    var stateChanged: ((LogStatus) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = PaddingSize.cornerRadius
        add(iconView)
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            iconView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
        ])
        addTarget(self, action: #selector(toggleState), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(schedule: MedicalSchedule) {
        self.schedule = schedule
        iconView.image = UIImage(systemName: schedule.image)
    }
    
    func setTaken(_ taken: Bool) {
        isTaken = taken
        
        if taken {
            backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            iconView.tintColor = .systemGreen
        } else {
            backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            iconView.tintColor = .systemRed
        }
    }

    @objc private func toggleState() {
        print("button")
        
        setTaken(!isTaken)
        stateChanged?(.init(schedule: schedule, taken: isTaken))

    }

}
class ScheduleTableViewCell: UITableViewCell {

    static let identifier = "ScheduleTableViewCell"

    private var slotViews: [ScheduleSlotDetailView] = []

    var onStateChanged: ((LogStatus) -> Void)?


    private let stackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupView()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupView() {

        stackView.axis = .horizontal
        stackView.spacing = PaddingSize.content
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        selectionStyle = .none
        contentView.addSubview(stackView)
        //stackView.isUserInteractionEnabled = false
        for schedule in MedicalSchedule.allCases {
            let slot = ScheduleSlotDetailView()
            slot.configure(schedule: schedule)

            slotViews.append(slot)
            stackView.addArrangedSubview(slot)
        }

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.height),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width),
        ])
    }
    func canEdit(schedule: MedicalSchedule, for date: Date) -> Bool {
        let calendar = Calendar.current
        
        let selectedDay = calendar.startOfDay(for: date)
        let today       = calendar.startOfDay(for: Date())
        
        if selectedDay != today {
            return true
        }
        
        let currentHour = calendar.component(.hour, from: Date())
        let currentMin = calendar.component(.minute, from: Date())

        return currentHour >= SettingsManager.shared.scheduleTime(for: schedule).hour && currentMin >= SettingsManager.shared.scheduleTime(for: schedule).minute
    }

    func configure(logStatus:[LogStatus], date: Date) {

        for slot in slotViews {

            let schedule = slot.schedule
            let logstate = logStatus.first {
                $0.schedule == schedule
            }
            slot.isHidden = logstate == nil
            slot.setTaken(logstate?.taken ?? false)
            slot.setEnabled(canEdit(schedule: schedule,for: date))
            slot.stateChanged = { [weak self] logStatus in
                print("cell")
                self?.onStateChanged?(logStatus)
            }

        }
    }
}
