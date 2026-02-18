//
//  InfoCardView.swift
//  record
//
//  Created by Esakkinathan B on 18/02/26.
//
import UIKit

struct InfoRowModel {
    let title: String
    let summary: String
    let style: Style
    
    enum Style {
        case normal
        case success
        case warning
        case danger
    }
}

class InfoCardView: UIView {
    
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        
        stackView.axis = .vertical
        stackView.spacing = 12
        
        let containerStack = UIStackView(arrangedSubviews: [titleLabel, stackView])
        containerStack.axis = .vertical
        containerStack.spacing = 16
        
        addSubview(containerStack)
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    func configure(section: SectionViewModel) {
        
        titleLabel.text = section.title
        
        // Clear old rows
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        section.rows.forEach { row in
            let rowView = makeRowView(for: row)
            stackView.addArrangedSubview(rowView)
        }
    }
    
    private func makeRowView(for model: InfoRowModel) -> UIView {
        
        let leftLabel = UILabel()
        leftLabel.text = model.title
        leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
        leftLabel.textColor = .label
        
        let rightLabel = UILabel()
        rightLabel.text = model.summary
        rightLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        rightLabel.textAlignment = .right
        
        // Style differentiation
        switch model.style {
        case .normal:
            rightLabel.textColor = .secondaryLabel
            
        case .success:
            rightLabel.textColor = .systemGreen
            
        case .warning:
            rightLabel.textColor = .systemOrange
            
        case .danger:
            rightLabel.textColor = .systemRed
        }
        
        let rowStack = UIStackView(arrangedSubviews: [leftLabel, rightLabel])
        rowStack.axis = .horizontal
        rowStack.spacing = 8
        rowStack.distribution = .fill
        
        leftLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rightLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        return rowStack
    }
}
/*
class SectionView: UIView {
    
    private let headerLabel = UILabel()
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        headerLabel.text = "Today's Schedule"
        headerLabel.font = .systemFont(ofSize: 22, weight: .bold)
        headerLabel.textColor = .label
        
        stackView.axis = .vertical
        stackView.spacing = 16
        
        let container = UIStackView(arrangedSubviews: [headerLabel, stackView])
        container.axis = .vertical
        container.spacing = 20
        
        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(with schedules: [SectionViewModel]) {
        
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        schedules.forEach { schedule in
            let card = InfoCardView()
            card.configure(title: schedule.title, rows: schedule.rows)
            stackView.addArrangedSubview(card)
        }
    }
}
*/
