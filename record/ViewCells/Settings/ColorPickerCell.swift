//
//  ColorPickerCell.swift
//  record
//
//  Created by Esakkinathan B on 19/02/26.
//
import UIKit

final class ColorPickerCell: UITableViewCell {
    
    static let identifier = "ColorPickerCell"
    
    private let titleLabel = UILabel()
    private let stack = UIStackView()
    private var selectionHandler: ((AppAccent) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        
        selectionStyle = .none
        
        titleLabel.text = "Color Style"
        titleLabel.font = .systemFont(ofSize: 16)
        
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        
        let container = UIStackView(arrangedSubviews: [titleLabel, stack])
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(container)
        
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(selected: AppAccent,
                   onSelect: @escaping (AppAccent) -> Void) {
        
        selectionHandler = onSelect
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for accent in AppAccent.allCases {
            
            let button = UIButton()
            button.backgroundColor = accent.color
            button.layer.cornerRadius = 12   // smaller radius
            button.translatesAutoresizingMaskIntoConstraints = false
            
            button.widthAnchor.constraint(equalToConstant: 24).isActive = true
            button.heightAnchor.constraint(equalToConstant: 24).isActive = true
            
            if accent == selected {
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.label.cgColor
            }
            
            button.addAction(UIAction { [weak self] _ in
                self?.selectionHandler?(accent)
            }, for: .touchUpInside)
            
            stack.addArrangedSubview(button)
        }
    }
}
