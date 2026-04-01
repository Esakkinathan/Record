//  ListPasswordCell.swift

import UIKit

class ListPasswordCell: UITableViewCell {

    static let identifier = "ListPasswordCell"

    // MARK: - Custom Labels (replace deprecated textLabel/detailTextLabel)
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.body        // use your app font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.small     // use your app font
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Favourite Button
    let button: UIButton = {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)

        if #available(iOS 15.0, *) {
            var buttonConfig = UIButton.Configuration.plain()
            buttonConfig.baseForegroundColor = AppColor.primaryColor
            buttonConfig.contentInsets = NSDirectionalEdgeInsets(
                top: 8, leading: 8, bottom: 8, trailing: 8
            )
            button.configuration = buttonConfig
        } else {
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }

        button.setImage(
            UIImage(systemName: IconName.star),
            for: .normal
        )
        button.setImage(
            UIImage(systemName: IconName.starFill),
            for: .selected
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Selection highlight overlay
    let selectionOverlay: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = AppColor.primaryColor.cgColor
        view.layer.cornerRadius = 10
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var onFavoriteButtonClicked: (() -> Void)?

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)   // .default — we handle layout
        setupContentView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Layout
    private func setupContentView() {
        selectionStyle = .none
        backgroundColor = .secondarySystemBackground

        // Add overlay behind everything
        contentView.insertSubview(selectionOverlay, at: 0)

        // Add labels and button
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(button)

        button.addTarget(self, action: #selector(favouriteClicked), for: .touchUpInside)

        NSLayoutConstraint.activate([
            // Selection overlay fills cell with inset
            selectionOverlay.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            selectionOverlay.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            selectionOverlay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            selectionOverlay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            // Favourite button — right side
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width * 2),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44),

            // Title label — left side, top half
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

            // Subtitle label — below title
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    // MARK: - Configure
    func configure(_ title: String, _ subtitle: String, isFavourite: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        button.isSelected = isFavourite
    }

    func setSelectedState(_ isSelected: Bool, isSelectionMode: Bool) {
        selectionOverlay.isHidden = !isSelectionMode

        if isSelected {
            selectionOverlay.backgroundColor = AppColor.primaryColor.withAlphaComponent(0.1)
            selectionOverlay.layer.borderColor = AppColor.primaryColor.cgColor
        } else {
            selectionOverlay.backgroundColor = .clear
            selectionOverlay.layer.borderColor = UIColor.separator.cgColor
        }

        // Hide favourite button during selection mode
        button.isHidden = isSelectionMode
    }

    @objc private func favouriteClicked() {
        button.isSelected.toggle()
        onFavoriteButtonClicked?()
    }
}
