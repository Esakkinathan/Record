//
//  ButtonCell.swift
//  record
//
//  Created by Esakkinathan B on 04/02/26.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {
    
    
    static let identifier = "ButtonTableViewCell"
    let button = AppButton()
    
    var onButtonClicked: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String) {
        button.setTitle(title, for: .normal)
    }
    func setUpContentView() {
                
        contentView.add(button)
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        NSLayoutConstraint.activate([
            //button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: FormSpacing.width),
            //button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -FormSpacing.width),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5)
        ])
        
    }
    @objc func buttonClicked() {
        onButtonClicked?()
    }
    

}
