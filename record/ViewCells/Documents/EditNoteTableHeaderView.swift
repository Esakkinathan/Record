//
//  SectionHeaderCollectionView.swift
//  record
//
//  Created by Esakkinathan B on 02/02/26.
//
import UIKit

class EditNoteTableHeaderView: UITableViewHeaderFooterView {

    static let identifier = "EditNoteTableHeaderView"


    private let titleLabel: UILabel = {
        let label = UILabel()
        label.labelSetUp()
        label.font = AppFont.heading3
        label.textColor = .secondaryLabel
        return label
    }()
        
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.numberOfLines = 1
        button.setImage(UIImage(systemName: IconName.edit), for: .normal)
        button.setImage(UIImage(systemName: IconName.checkmark), for: .selected)
        button.configuration = AppConstantData.buttonConfiguration
        return button
    }()



    var onEditButtonClicked: ((Bool) -> Void)?


    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupContentView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContentView()
    }


    func setupContentView() {
        //contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        contentView.add(titleLabel)
        contentView.add(editButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: PaddingSize.height),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -PaddingSize.height ),
            editButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            editButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
            //editButton.widthAnchor.constraint(equalToConstant: 100)
        ])

        editButton.addTarget(self, action: #selector(editButtonClicked), for: .touchUpInside)
    }


    func configure(title: String, isEditing: Bool) {
        titleLabel.text = title
        editButton.isSelected = isEditing
    }


    @objc private func editButtonClicked() {
        editButton.isSelected.toggle()
        onEditButtonClicked?(editButton.isSelected)
    }


    override func prepareForReuse() {
        super.prepareForReuse()
        onEditButtonClicked = nil
        editButton.isSelected = false
    }
}
class AddRemainderHeaderView: UITableViewHeaderFooterView {

    static let identifier = "AddRemainderHeaderView"


    private let titleLabel: UILabel = {
        let label = UILabel()
        label.labelSetUp()
        label.font = AppFont.heading3
        label.textColor = .secondaryLabel
        return label
    }()

    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.numberOfLines = 1
        button.setImage(UIImage(systemName: IconName.add), for: .normal)
        button.configuration = AppConstantData.buttonConfiguration
        button.showsMenuAsPrimaryAction = true
        return button
    }()


    var handleOffsetSelection: ((ReminderOffset,Date) -> Void)?

    //var onAddButtonClicked: (() -> Void)?


    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupContentView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContentView()
    }


    func setupContentView() {
        //contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        contentView.add(titleLabel)
        contentView.add(addButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: PaddingSize.height),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -PaddingSize.height ),
            addButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
            //addButton.widthAnchor.constraint(equalToConstant: 100)
        ])

       // addButton.addTarget(self, action: #selector(addButtonClicked), for: .touchUpInside)
    }

    func configure(count: Int,title: String, expiryDate: Date?) {
        if count == 3 {
            return
        }
        titleLabel.text = title
        guard let date = expiryDate else {return}
        let offsets = validOffsets(for: date)
        
        let actions = offsets.map { offset in
            UIAction(title: offset.title) { [weak self] _ in
                self?.handleOffsetSelection?(offset,date)
            }
        }
        
        let menu = UIMenu(title: "Select Reminder", children: actions)

        addButton.menu = menu
    }

    private func reminderDate(
        for offset: ReminderOffset,
        expiryDate: Date
    ) -> Date? {
        
        let calendar = Calendar.current
        
        switch offset {
        case .oneMonth:
            return calendar.date(byAdding: .month, value: -1, to: expiryDate)
        case .threeWeeks:
            return calendar.date(byAdding: .day, value: -21, to: expiryDate)
        case .twoWeeks:
            return calendar.date(byAdding: .day, value: -14, to: expiryDate)
        case .oneWeek:
            return calendar.date(byAdding: .day, value: -7, to: expiryDate)
        case .fiveDays:
            return calendar.date(byAdding: .day, value: -5, to: expiryDate)
        case .twoDays:
            return calendar.date(byAdding: .day, value: -2, to: expiryDate)
        case .oneDay:
            return calendar.date(byAdding: .day, value: -1, to: expiryDate)
        case .custom:
            return nil
        }
    }
    private func validOffsets(for expiryDate: Date) -> [ReminderOffset] {
        let all: [ReminderOffset] = ReminderOffset.allCases
        
        let now = Date()
        
        return all.filter { offset in
            
            if offset == .custom { return true }
            
            guard let date = reminderDate(for: offset, expiryDate: expiryDate) else {
                return false
            }
            
            return date > now
        }
    }
    
    @objc private func addButtonClicked() {
     //   onAddButtonClicked?()
    }

}
