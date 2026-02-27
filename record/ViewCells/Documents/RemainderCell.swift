//
//  RemainderCell.swift
//  record
//
//  Created by Esakkinathan B on 24/02/26.
//
import UIKit

class RemainderTableViewCell: UITableViewCell {
    
    static let identifier = "RemainderTableViewCell"
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.font = AppFont.small
        label.textColor = .label
        return label
    }()
    private let subtitleLabel: UILabel = {
         let label = UILabel()
         label.font = AppFont.verysmall
         label.textColor = .secondaryLabel
         return label
    }()
    private let badgeLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = AppFont.caption
        label.textColor = .white
        label.clipsToBounds = true
        label.textAlignment = .center
        label.layer.cornerRadius = PaddingSize.cornerRadius
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
                
        backgroundColor = .secondarySystemBackground
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = PaddingSize.content
        
        contentView.add(stack)
        contentView.add(badgeLabel)
        
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.height),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
            
            badgeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            badgeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            badgeLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    func configure(count: Int, remainder: Remainder) {
        
        titleLabel.text = "Scheduled At \(remainder.date.reminderFormatted())"
        subtitleLabel.text = "Remainder \(count)"
        badgeLabel.text = "  \(remainder.statusText)  "
        
        if remainder.isExpired {
            contentView.backgroundColor = UIColor.systemGray6
            badgeLabel.backgroundColor = .systemGray
        } else {
            contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            badgeLabel.backgroundColor = .systemGreen
        }
    }
}
class PaddingLabel: UILabel {
    
    var insets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }
}
