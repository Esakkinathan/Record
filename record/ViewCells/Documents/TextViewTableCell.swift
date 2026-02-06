//
//  TextViewCollectionCell.swift
//  record
//
//  Created by Esakkinathan B on 02/02/26.
//
import UIKit

class TextViewCollectionCell: UITableViewCell {
    
    static let identifier = "TextViewTableViewCell"
    
    var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = AppColor.background
        textView.textColor = .label
        textView.isScrollEnabled = true
        textView.isSelectable = true
        textView.isEditable = false
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String?) {
        textView.text = text
    }
    
    var enteredText: String? {
        return textView.text
    }
    func setUpContentView() {
        contentView.add(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.height),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width),

        ])
    }
    
    func modifyEditing(_ value: Bool) {
        textView.isEditable = value
        textView.backgroundColor = value ? .secondarySystemBackground : AppColor.background
    }
    
    
}
