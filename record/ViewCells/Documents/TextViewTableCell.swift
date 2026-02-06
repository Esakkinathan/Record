//
//  TextViewCollectionCell.swift
//  record
//
//  Created by Esakkinathan B on 02/02/26.
//
import UIKit

class TextViewTableViewCell: UITableViewCell {
    
    static let identifier = "TextViewTableViewCell"
    
    var textView: UITextView = {
        let textView = UITextView()
        //textView.backgroundColor = AppColor.background
        textView.textColor = .label
        textView.isScrollEnabled = true
        textView.isSelectable = true
        textView.isEditable = false
        textView.clipsToBounds = true
        textView.contentInset = UIEdgeInsets(top: PaddingSize.content, left: PaddingSize.content, bottom: PaddingSize.content, right: PaddingSize.content)
        return textView
    }()
    
    var onValueChange: ((String?) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String?, value: Bool) {
        textView.text = text
        textView.isEditable = value
        textView.backgroundColor = value ? .systemGray4 : AppColor.gray
    }
    
    var enteredText: String? {
        return textView.text
    }
    
    
    @objc func valueChanged() {
        
    }
    func setUpContentView() {
        contentView.add(textView)
        textView.delegate = self
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

        ])
    }
    
}

extension TextViewTableViewCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        onValueChange?(textView.text)
    }
}
