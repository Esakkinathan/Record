//
//  MedicalToggleCell.swift
//  record
//
//  Created by Esakkinathan B on 02/03/26.
//

import UIKit
/*
class FormToggleLabel: FormFieldCell {
        
    static let identifier = "FormToggleLabel"
    let contentLabel = UILabel()
    let toggleContainer: ToggleView = {
       let toggle = ToggleView()
        toggle.backgroundColor = .tertiarySystemBackground
        return toggle
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
        setTitleLabelCenter()
    }
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String,isRequired: Bool = false,status: Bool,onToggle: ((Bool) -> Void)?) {
        super.configure(title: title, isRequired: isRequired)
        contentLabel.text = status ? "Active" : "Completed"
        toggleContainer.text = status ? "Mark as Completed" : "Mark as OnGoing"
        toggleContainer.isOn = !status
        toggleContainer.onToggleChanged = onToggle
    }
    override func setUpContentView() {
        
        super.setUpContentView()
        rightView.backgroundColor = .secondarySystemBackground
        rightView.add(contentLabel)
        rightView.add(toggleContainer)
        contentLabel.font = AppFont.body
        contentLabel.labelSetUp()
        NSLayoutConstraint.activate([
            contentLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            contentLabel.trailingAnchor.constraint(equalTo: toggleContainer.trailingAnchor, constant: -FormSpacing.width),
            contentLabel.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
            toggleContainer.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.height),
            toggleContainer.bottomAnchor.constraint(equalTo: rightView.bottomAnchor, constant: -FormSpacing.height),
            toggleContainer.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.height),
        ])
        
    }
}
*/

import UIKit

class FormToggleLabel: UITableViewCell {

    static let identifier = "FormToggleLabel"

    private let cardButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private var onToggle: ((Bool) -> Void)?
    private var currentStatus: Bool = true

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        contentView.addSubview(cardButton)
        //cardButton.addSubview(titleLabel)
        cardButton.addSubview(statusLabel)
        contentView.backgroundColor = .secondarySystemBackground
        cardButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            // Card fills cell with padding
            cardButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),

            // Title on the left
//            titleLabel.leadingAnchor.constraint(equalTo: cardButton.leadingAnchor, constant: 16),
//            titleLabel.centerYAnchor.constraint(equalTo: cardButton.centerYAnchor),
//            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusLabel.leadingAnchor, constant: -8),

            // Status label on the right
            statusLabel.centerXAnchor.constraint(equalTo: cardButton.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: cardButton.centerYAnchor),
            statusLabel.widthAnchor.constraint(equalTo: cardButton.widthAnchor, multiplier: 0.75),
        ])
    }

    // MARK: - Configure

    func configure(title: String, isRequired: Bool = false, status: Bool, onToggle: ((Bool) -> Void)?) {
        self.currentStatus = status
        self.onToggle = onToggle

        //titleLabel.text = isRequired ? "\(title) *" : title
        applyStatus(status)
    }

    private func applyStatus(_ status: Bool) {
        if status {
            // Active → show "Mark as Completed" in green
            statusLabel.text = "Mark as Completed"
            statusLabel.textColor = .systemGreen
            cardButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.08)
            cardButton.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.3).cgColor
            cardButton.layer.borderWidth = 1
        } else {
            // Completed → show "Mark as Ongoing" in red
            statusLabel.text = "Mark as Ongoing"
            statusLabel.textColor = .systemRed
            cardButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.08)
            cardButton.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.3).cgColor
            cardButton.layer.borderWidth = 1
        }
    }

    // MARK: - Action

    @objc private func buttonTapped() {
        currentStatus.toggle()
        applyStatus(currentStatus)

        UIView.animate(withDuration: 0.1, animations: {
            self.cardButton.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.cardButton.transform = .identity
            }
        }

        onToggle?(!currentStatus)
    }
}
