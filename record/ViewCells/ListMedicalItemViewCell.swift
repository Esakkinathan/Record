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
        label.configure(image: IconName.medicalName, .systemBlue)
        return label
    }()
    let label2: ImageTextView = {
        let label = ImageTextView()
        label.label.font = AppFont.body
        label.label.textColor = .secondaryLabel
        label.configure(image: IconName.instruction, .systemOrange)
        return label
    }()
    let label3: ImageTextView = {
        let label = ImageTextView()
        label.label.font = AppFont.small
        label.label.textColor = .secondaryLabel
        label.configure(image: IconName.dosage, .systemGreen)
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    private let gridContainerWidth: CGFloat = 110
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setUpContentView() {
        super.setUpContentView()
        
        contentView.add(scheduleGridView)
        stack.constraints.forEach { c in
            if c.firstAttribute == .trailing { c.isActive = false }
        }

        NSLayoutConstraint.activate([
            scheduleGridView.widthAnchor.constraint(equalToConstant: 110),
            scheduleGridView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width * 2),
            scheduleGridView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            scheduleGridView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: PaddingSize.content),
            scheduleGridView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -PaddingSize.content),
            
            stack.trailingAnchor.constraint(equalTo: scheduleGridView.leadingAnchor, constant: -PaddingSize.width),
        ])
    }
    func configure(text1: String, text2: String, text3: String, schedules: [MedicalSchedule], taken: Set<MedicalSchedule>) {
        super.configure(text1: text1, text2: text2, text3: text3)
        scheduleGridView.configure(schedules: schedules, takenSchedules: taken)

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
        toggleContainer.isHidden = true
    }
    
    func configure(text1: String, text2: String, text3: String, canShow: Bool, state: Bool, onToggle: ((Bool) -> Void)?) {
        super.configure(text1: text1, text2: text2, text3: text3)
        toggleContainer.isHidden = !canShow
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
    private func setupView() {
        layer.cornerRadius = PaddingSize.cornerRadius
        backgroundColor = .secondarySystemBackground
        
        // Create 4 slot views for each schedule
        let images = MedicalSchedule.getImage()
        
        for image in images {
            let slot = ScheduleSlotView()
            slot.configure(
                imageName: image
            )
            slot.isHidden = true // hidden by default
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
    
    func configure(schedules: [MedicalSchedule], takenSchedules: Set<MedicalSchedule>) {
        let allCases = Array(MedicalSchedule.allCases)
        
        for (index, slot) in slotViews.enumerated() {
            let schedule = allCases[index]
            let isIncluded = schedules.contains(schedule)
            slot.isHidden = !isIncluded
            if isIncluded {
                slot.setTaken(takenSchedules.contains(schedule))
            }
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
}


class ScheduleSlotView: UIView {
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    
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
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(imageName: String) {
        iconView.image = UIImage(systemName: imageName)
    }
    
    func setTaken(_ taken: Bool) {
        if taken {
            backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            iconView.tintColor = .systemGreen
        } else {
            backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            iconView.tintColor = .systemRed
        }
    }
}
