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
