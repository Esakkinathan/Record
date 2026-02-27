//
//  ListPasswordCell.swift
//  record
//
//  Created by Esakkinathan B on 04/02/26.
//

import UIKit

class ListPasswordCell: UITableViewCell {
    
    static let identifier = "ListPasswordCell"
    let button: UIButton = {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(
                pointSize: 22,
                weight: .regular
            )
        if #available(iOS 15.0, *) {
            var buttonConfig = UIButton.Configuration.clearGlass()
            buttonConfig.baseForegroundColor = AppColor.primaryColor
            buttonConfig.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            button.configuration = buttonConfig

            button.setImage(
                UIImage(systemName: IconName.star, withConfiguration: config),
                for: .normal
            )
            button.setImage(
                UIImage(systemName: IconName.starFill, withConfiguration: config),
                for: .selected
            )
        } else {
            button.setImage(
                UIImage(systemName: IconName.star, withConfiguration: config),
                for: .normal
            )
            button.setImage(
                UIImage(systemName: IconName.starFill, withConfiguration: config),
                for: .selected
            )
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
        return button
    }()
    var onFavoriteButtonClicked: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    func setUpContentView() {
        selectionStyle = .none
        contentView.add(button)
        backgroundColor = .secondarySystemBackground
        textLabel?.labelSetUp()
        detailTextLabel?.labelSetUp()

        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width*3),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    
    @objc func favouriteClicked() {
        button.isSelected.toggle()
        onFavoriteButtonClicked?()
    }
    func configure(_ text1: String, _ text2: String, isFavourite: Bool) {
        textLabel?.text = text1
        detailTextLabel?.text = text2
        button.isSelected = isFavourite
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
