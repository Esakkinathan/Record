//
//  SortHeaderView.swift
//  record
//
//  Created by Esakkinathan B on 13/02/26.
//

import UIKit

class SortHeaderView: UIView {
    let button: UIButton = {
        let button = UIButton(type: .custom)
        var config = UIButton.Configuration.plain()
        config.title = "Sort"
        config.image = UIImage(systemName: IconName.arrowUp)
        config.baseForegroundColor = AppColor.primaryColor
        config.imagePlacement = .trailing
        config.imagePadding = 4
        button.configuration = config
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.labelSetUp()
        label.textColor = .secondaryLabel
        label.font = AppFont.heading3
        return label
    }()
    
    let timerLabel: CopyTextLabel = {
        let label = CopyTextLabel()
        label.copyButton.isHidden = true
        label.textLabel.font = AppFont.body
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpContent() {
        timerLabel.isHidden = true
        add(button)
        add(textLabel)
        add(timerLabel)
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PaddingSize.width),
            timerLabel.topAnchor.constraint(equalTo: topAnchor),
            timerLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            timerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor ),
            button.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    func setTimer(text: NSMutableAttributedString) {
        timerLabel.textLabel.attributedText = text
    }
    func configure(text: String, iconName: String) {
        textLabel.text = text
        button.configuration?.image = UIImage(systemName: iconName)
    }
}
