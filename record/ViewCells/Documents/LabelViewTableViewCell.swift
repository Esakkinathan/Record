//
//  TextFieldTableViewCell.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit

class LabelViewTableViewCell: UITableViewCell {
    let label = UILabel()
    
    static let identifier = "LabelViewTableViewCell"
    
    func configure(text: String) {
        label.text = text
        setUpContentView()
    }
    
    func setUpContentView() {
        contentView.add(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.height),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width),

        ])
        
    }
    
    
}
