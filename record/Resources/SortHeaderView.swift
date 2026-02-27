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
        config.baseForegroundColor = .secondaryLabel
        config.baseBackgroundColor = .secondarySystemBackground
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
    
    let timerLabel: TimerView = {
        let label = TimerView()
        return label
    }()
    let buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = PaddingSize.cornerRadius
        return view
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
        //add(button)
        buttonView.add(button)
        let space: CGFloat = 3
        NSLayoutConstraint.activate([
            
            button.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: space),
            button.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: -space),
            button.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: space),
            button.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -space),
            
        ])
        let stack: UIStackView = {
           let view = UIStackView(arrangedSubviews: [textLabel, timerLabel, buttonView])
            view.axis = .horizontal
            view.distribution = .equalCentering
            return view
        }()
        add(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PaddingSize.width),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -PaddingSize.width)
        ])
    }
    func setTimer(text: NSMutableAttributedString) {
        timerLabel.textLabel.attributedText = text
    }
    func setTimerViewHidden(_ hidden: Bool) {
        UIView.transition(
            with: timerLabel,
            duration: 0.25,
            options: .transitionCrossDissolve,
            animations: {
                self.timerLabel.isHidden = hidden
            }
        )
    }
    func configure(text: String, iconName: String? = nil) {
        textLabel.text = text
        if let icon = iconName {
            button.configuration?.image = UIImage(systemName: icon)

        }
    }
}
