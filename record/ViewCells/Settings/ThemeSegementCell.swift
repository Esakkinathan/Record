//
//  ThemeSegementCell.swift
//  record
//
//  Created by Esakkinathan B on 19/02/26.
//
import UIKit

class ThemeSegmentCell: UITableViewCell {
    static let identifier = "ThemeSegmentCell"
    
    private let titleLabel = UILabel()
    private let segmented = UISegmentedControl(items: ["System", "Light", "Dark"])
    
    private var handler: ((AppTheme) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        
        selectionStyle = .none
        
        titleLabel.text = "Theme"
        titleLabel.font = .systemFont(ofSize: 16)
        
        segmented.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, segmented])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stack)
        
        // Make title hug left
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(current: AppTheme,
                   accent: UIColor,
                   onChange: @escaping (AppTheme) -> Void) {
        
        handler = onChange
        
        segmented.selectedSegmentIndex = {
            switch current {
            case .system: return 0
            case .light: return 1
            case .dark: return 2
            }
        }()
        
        // Accent color styling
        segmented.selectedSegmentTintColor = accent
        segmented.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )
        segmented.setTitleTextAttributes(
            [.foregroundColor: UIColor.label],
            for: .normal
        )
    }
    
    @objc private func valueChanged() {
        let theme: AppTheme
        
        switch segmented.selectedSegmentIndex {
        case 0: theme = .system
        case 1: theme = .light
        case 2: theme = .dark
        default: theme = .system
        }
        
        handler?(theme)
    }
}
