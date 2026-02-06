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
        label.font = AppFont.body
        return label
    }()

    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(AppConstantData.edit, for: .normal)
        button.setTitle(AppConstantData.save, for: .selected)
        button.configuration = AppConstantData.buttonConfiguration
        return button
    }()

    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, editButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
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


    private func setupContentView() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        contentView.add(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.height),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width)
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
