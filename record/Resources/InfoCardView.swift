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

    // MARK: - UI

    private let headerStack = UIStackView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let rowsStack = UIStackView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous   // smoother Apple-style rounding
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.07
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 16

        // Icon
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .systemBlue
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.isHidden = true
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
        ])

        // Title
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .label

        // Subtitle (optional, hidden by default)
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .tertiaryLabel
        subtitleLabel.isHidden = true

        // Title text column
        let titleColumn = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleColumn.axis = .vertical
        titleColumn.spacing = 2

        // Header row: icon + title column
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 10
        headerStack.addArrangedSubview(iconView)
        headerStack.addArrangedSubview(titleColumn)

        // Divider under header
        let headerDivider = makeDivider()

        // Rows stack
        rowsStack.axis = .vertical
        rowsStack.spacing = 0  // We'll manage spacing via dividers

        // Root container
        let root = UIStackView(arrangedSubviews: [headerStack, headerDivider, rowsStack])
        root.axis = .vertical
        root.spacing = 16
        root.translatesAutoresizingMaskIntoConstraints = false

        addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            root.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            root.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            root.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])
    }

    // MARK: - Configure

    /// Basic configure — matches your existing SectionViewModel API
    func configure(section: SectionViewModel) {
        titleLabel.text = section.title
        subtitleLabel.isHidden = true
        iconView.isHidden = true
        rebuildRows(section.rows)
    }

    /// Extended configure with icon + subtitle
    func configure(section: SectionViewModel, icon: UIImage? = nil, subtitle: String? = nil, iconTint: UIColor = .systemBlue) {
        titleLabel.text = section.title

        if let icon {
            iconView.image = icon
            iconView.tintColor = iconTint
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }

        if let subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }

        rebuildRows(section.rows)
    }

    private func rebuildRows(_ rows: [InfoRowModel]) {
        rowsStack.arrangedSubviews.forEach {
            rowsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for (index, row) in rows.enumerated() {
            let rowView = makeRowView(for: row)
            rowsStack.addArrangedSubview(rowView)

            // Divider between rows (not after the last one)
            if index < rows.count - 1 {
                let divider = makeDivider()
                rowsStack.addArrangedSubview(divider)
                rowsStack.setCustomSpacing(12, after: rowView)
                rowsStack.setCustomSpacing(12, after: divider)
            }
        }
    }

    // MARK: - Row View

    private func makeRowView(for model: InfoRowModel) -> UIView {
        // Left side: label + optional detail
        let leftLabel = UILabel()
        leftLabel.text = model.title
        leftLabel.font = .systemFont(ofSize: 15, weight: .medium)
        leftLabel.textColor = .secondaryLabel
        leftLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        leftLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Right side: colored pill badge
        let badge = makeBadge(text: model.summary, style: model.style)

        let rowStack = UIStackView(arrangedSubviews: [leftLabel, badge])
        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.spacing = 8
        rowStack.distribution = .fill

        return rowStack
    }

    // MARK: - Badge

    private func makeBadge(text: String, style: InfoRowModel.Style) -> UIView {
        let colors = badgeColors(for: style)

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = colors.text
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)

        let pill = UIView()
        pill.backgroundColor = colors.background
        pill.layer.cornerRadius = 10
        pill.layer.cornerCurve = .continuous

        pill.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: pill.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -10),
        ])

        return pill
    }

    private func badgeColors(for style: InfoRowModel.Style) -> (text: UIColor, background: UIColor) {
        switch style {
        case .normal:  return (.secondaryLabel,  .tertiarySystemFill)
        case .success: return (.systemGreen,     .systemGreen.withAlphaComponent(0.12))
        case .warning: return (.systemOrange,    .systemOrange.withAlphaComponent(0.12))
        case .danger:  return (.systemRed,       .systemRed.withAlphaComponent(0.12))
        }
    }

    // MARK: - Helpers

    private func makeDivider() -> UIView {
        let line = UIView()
        line.backgroundColor = .separator.withAlphaComponent(0.5)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return line
    }

    // MARK: - Shadow

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
    }

    // MARK: - Press feedback

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animatePress(down: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animatePress(down: false)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animatePress(down: false)
    }

    private func animatePress(down: Bool) {
        UIView.animate(withDuration: down ? 0.12 : 0.25,
                       delay: 0,
                       usingSpringWithDamping: down ? 1 : 0.6,
                       initialSpringVelocity: down ? 0 : 0.5) {
            self.transform = down ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            self.layer.shadowOpacity = down ? 0.03 : 0.07
        }
    }
}

/*
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
        leftLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        leftLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let rightLabel = UILabel()
        rightLabel.text = model.summary
        rightLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        rightLabel.textAlignment = .right
        rightLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        rightLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        switch model.style {
        case .normal:   rightLabel.textColor = .secondaryLabel
        case .success:  rightLabel.textColor = .systemGreen
        case .warning:  rightLabel.textColor = .systemOrange
        case .danger:   rightLabel.textColor = .systemRed
        }

        let rowStack = UIStackView(arrangedSubviews: [leftLabel, rightLabel])
        rowStack.axis = .horizontal
        rowStack.spacing = 8
        rowStack.distribution = .fill

        return rowStack
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
    }
}
*/
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
