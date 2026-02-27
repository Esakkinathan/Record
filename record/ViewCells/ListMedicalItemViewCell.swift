//
//  ListMedicalItemViewCell.swift
//  record
//
//  Created by Esakkinathan B on 17/02/26.
//
import UIKit

/*
class ImageTextView: UIView {

    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    let label: UILabel = {
        let l = UILabel()
        l.font = AppFont.body
        l.textColor = .label
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContents()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupContents() {
        addSubview(imageView)
        addSubview(label)
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 16),
            imageView.heightAnchor.constraint(equalToConstant: 16),

            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    func configure(text: String) { label.text = text }
    func configure(image: String, tint: UIColor) {
        imageView.image = UIImage(systemName: image,
                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium))
        imageView.tintColor = tint
    }
}

// MARK: - ListMedicalItemViewCell (redesigned)

class ListMedicalItemViewCell: UITableViewCell {

    static let identifier = "ListMedicalItemViewCell"

    // MARK: - Card

    private let card: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 18
        v.layer.cornerCurve = .continuous
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowRadius = 10
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Left accent bar

    private let accentBar: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBlue
        v.layer.cornerRadius = 3
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Info rows

    private let nameRow: ImageTextView = {
        let v = ImageTextView()
        v.label.font = .systemFont(ofSize: 16, weight: .semibold)
        v.label.textColor = .label
        v.configure(image: IconName.medicalName, tint: .systemBlue)
        return v
    }()

    private let instructionRow: ImageTextView = {
        let v = ImageTextView()
        v.label.font = .systemFont(ofSize: 14, weight: .regular)
        v.label.textColor = .secondaryLabel
        v.configure(image: IconName.instruction, tint: .systemOrange)
        return v
    }()

    private let dosageRow: ImageTextView = {
        let v = ImageTextView()
        v.label.font = .systemFont(ofSize: 13, weight: .regular)
        v.label.textColor = .tertiaryLabel
        v.configure(image: IconName.dosage, tint: .systemGreen)
        return v
    }()

    // MARK: - Toggle area

    private let toggleContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .tertiarySystemFill
        v.layer.cornerRadius = 14
        v.layer.cornerCurve = .continuous
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let markLabel: UILabel = {
        let l = UILabel()
        l.text = "Taken"
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    let toggle: UISwitch = {
        let s = UISwitch()
        s.onTintColor = .systemGreen
        s.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // MARK: - Taken overlay badge

    private let takenBadge: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGreen.withAlphaComponent(0.12)
        v.layer.cornerRadius = 10
        v.layer.cornerCurve = .continuous
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    private let takenBadgeLabel: UILabel = {
        let l = UILabel()
        l.text = "✓  Taken"
        l.font = .systemFont(ofSize: 11, weight: .bold)
        l.textColor = .systemGreen
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Callback

    var onToggleChanged: ((Bool) -> Void)?

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear

        // Info stack
        let infoStack = UIStackView(arrangedSubviews: [nameRow, instructionRow, dosageRow])
        infoStack.axis = .vertical
        infoStack.spacing = 7
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        // Toggle container internals
        let toggleStack = UIStackView(arrangedSubviews: [markLabel, toggle])
        toggleStack.axis = .vertical
        toggleStack.alignment = .center
        toggleStack.spacing = 2
        toggleStack.translatesAutoresizingMaskIntoConstraints = false

        toggleContainer.addSubview(toggleStack)

        // Taken badge
        takenBadge.addSubview(takenBadgeLabel)

        // Assemble card
        card.addSubview(accentBar)
        card.addSubview(infoStack)
        card.addSubview(toggleContainer)
        card.addSubview(takenBadge)
        contentView.addSubview(card)

        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)

        NSLayoutConstraint.activate([

            // Card fills contentView with inset margins
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Accent bar — left edge stripe
            accentBar.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            accentBar.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            accentBar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            accentBar.widthAnchor.constraint(equalToConstant: 4),

            // Info stack — next to accent bar
            infoStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            infoStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            infoStack.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 14),
            infoStack.trailingAnchor.constraint(equalTo: toggleContainer.leadingAnchor, constant: -12),

            // Toggle container — right side
            toggleContainer.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            toggleContainer.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            toggleContainer.widthAnchor.constraint(equalToConstant: 60),

            // Toggle stack inside container
            toggleStack.topAnchor.constraint(equalTo: toggleContainer.topAnchor, constant: 10),
            toggleStack.bottomAnchor.constraint(equalTo: toggleContainer.bottomAnchor, constant: -10),
            toggleStack.centerXAnchor.constraint(equalTo: toggleContainer.centerXAnchor),

            // Taken badge — top-right of card
            takenBadge.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            takenBadge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),

            takenBadgeLabel.topAnchor.constraint(equalTo: takenBadge.topAnchor, constant: 4),
            takenBadgeLabel.bottomAnchor.constraint(equalTo: takenBadge.bottomAnchor, constant: -4),
            takenBadgeLabel.leadingAnchor.constraint(equalTo: takenBadge.leadingAnchor, constant: 8),
            takenBadgeLabel.trailingAnchor.constraint(equalTo: takenBadge.trailingAnchor, constant: -8),
        ])
    }

    // MARK: - Toggle action

    @objc private func toggleChanged() {
        let on = toggle.isOn
        onToggleChanged?(on)
        animateTakenState(on)
    }

    // MARK: - Taken state animation

    private func animateTakenState(_ taken: Bool) {
        if taken {
            // Accent bar → green
            UIView.animate(withDuration: 0.3) {
                self.accentBar.backgroundColor = .systemGreen
                self.card.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.04)
                self.toggleContainer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            }
            // Badge pop-in
            takenBadge.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            takenBadge.alpha = 0
            takenBadge.isHidden = false
            UIView.animate(withDuration: 0.35, delay: 0.1,
                           usingSpringWithDamping: 0.55, initialSpringVelocity: 0.8) {
                self.takenBadge.transform = .identity
                self.takenBadge.alpha = 1
            }
            // Name label strikethrough
            if let text = nameRow.label.text {
                let attrs: [NSAttributedString.Key: Any] = [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .strikethroughColor: UIColor.secondaryLabel,
                    .foregroundColor: UIColor.secondaryLabel
                ]
                nameRow.label.attributedText = NSAttributedString(string: text, attributes: attrs)
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.accentBar.backgroundColor = .systemBlue
                self.card.backgroundColor = .secondarySystemGroupedBackground
                self.toggleContainer.backgroundColor = .tertiarySystemFill
                self.takenBadge.alpha = 0
            } completion: { _ in
                self.takenBadge.isHidden = true
            }
            // Remove strikethrough
            if let text = nameRow.label.attributedText?.string {
                nameRow.label.attributedText = nil
                nameRow.label.text = text
                nameRow.label.textColor = .label
            }
        }
    }

    // MARK: - Configure

    func configure(text1: String, text2: String, text3: String, canShow: Bool, state: Bool) {
        nameRow.configure(text: text1)
        instructionRow.configure(text: text2)
        dosageRow.configure(text: text3)

        toggleContainer.isHidden = !canShow
        toggle.setOn(state, animated: false)

        // Apply initial state without animation
        accentBar.backgroundColor = state ? .systemGreen : .systemBlue
        card.backgroundColor = state
            ? UIColor.systemGreen.withAlphaComponent(0.04)
            : .secondarySystemGroupedBackground
        toggleContainer.backgroundColor = state
            ? UIColor.systemGreen.withAlphaComponent(0.1)
            : .tertiarySystemFill
        takenBadge.isHidden = !state
        takenBadge.alpha = state ? 1 : 0

        if state, let text = nameRow.label.text {
            let attrs: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .strikethroughColor: UIColor.secondaryLabel,
                .foregroundColor: UIColor.secondaryLabel
            ]
            nameRow.label.attributedText = NSAttributedString(string: text, attributes: attrs)
        }
    }

    // MARK: - Layout (shadow path)

    override func layoutSubviews() {
        super.layoutSubviews()
        card.layer.shadowPath = UIBezierPath(roundedRect: card.bounds, cornerRadius: 18).cgPath
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        toggleContainer.isHidden = false
        takenBadge.isHidden = true
        takenBadge.alpha = 0
        accentBar.backgroundColor = .systemBlue
        card.backgroundColor = .secondarySystemGroupedBackground
        toggleContainer.backgroundColor = .tertiarySystemFill
        nameRow.label.attributedText = nil
        nameRow.label.textColor = .label
        onToggleChanged = nil
    }
}
*/

class ImageTextView: UIView {
    let imageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = AppFont.body
        label.textColor = .label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //label.setContentCompressionResistancePriority(.required, for: .horizontal)
        setUpContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpContents() {
        add(imageView)
        add(label)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: PaddingSize.content),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),

        ])
    }
    
    func configure(text: String ) {
        label.text = text
    }
    func configure(image: String, _ tint: UIColor) {
        imageView.image = UIImage(systemName: image)
        imageView.tintColor = tint
    }
}
class ListMedicalItemViewCell: UITableViewCell {
    let label1: ImageTextView = {
        let label = ImageTextView()
        label.label.font = AppFont.heading3
        label.label.textColor = .label
        label.configure(image: IconName.medicalName, .systemBlue)
        return label
    }()
    let label2: ImageTextView = {
        let label = ImageTextView()
        label.label.font = AppFont.body
        label.label.textColor = .secondaryLabel
        label.configure(image: IconName.instruction, .systemOrange)
        return label
    }()
    let label3: ImageTextView = {
        let label = ImageTextView()
        label.label.font = AppFont.small
        label.label.textColor = .secondaryLabel
        label.configure(image: IconName.dosage, .systemGreen)
        return label
    }()
    
    let markLabel: UILabel = {
       let label = UILabel()
        label.text = "Mark As Taken"
        label.textAlignment = .center
        label.font = AppFont.caption
        return label
    }()
    
    let toggle = UISwitch()
    
    let toggleContainer: UIView = {
       let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = PaddingSize.cornerRadius
        return view
    }()
    var onToggleChanged: ((Bool) -> Void)?
    
    static let identifier = "ListMedicalItemViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpContentView() {
        let bottomLine: UIView = {
            let view = UIView()
            view.backgroundColor = .lightGray
            view.heightAnchor.constraint(equalToConstant: 1).isActive = true
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        let stack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [label1, label2, label3])
            stack.axis = .vertical
            stack.spacing = PaddingSize.content
            stack.layer.cornerRadius = PaddingSize.cornerRadius
            stack.backgroundColor = .secondarySystemBackground
            stack.layoutMargins = UIEdgeInsets(top: PaddingSize.content, left: PaddingSize.content, bottom: PaddingSize.content, right: PaddingSize.content)
            stack.isLayoutMarginsRelativeArrangement = true
            return stack
        }()
        
        //toggle.isOn = false
        selectionStyle = .none
        contentView.add(stack)
        toggleContainer.add(toggle)
        
        contentView.add(toggleContainer)
        toggleContainer.add(markLabel)
        
        NSLayoutConstraint.activate([
            
            markLabel.topAnchor.constraint(equalTo: toggleContainer.topAnchor, constant: PaddingSize.content),
            markLabel.leadingAnchor.constraint(equalTo: toggleContainer.leadingAnchor, constant: PaddingSize.content),
            markLabel.trailingAnchor.constraint(equalTo: toggleContainer.trailingAnchor, constant: -PaddingSize.content),
            toggle.topAnchor.constraint(equalTo: markLabel.bottomAnchor, constant: PaddingSize.content),
            toggle.bottomAnchor.constraint(equalTo: toggleContainer.bottomAnchor, constant: -PaddingSize.content),
            toggle.leadingAnchor.constraint(equalTo: toggleContainer.leadingAnchor, constant: PaddingSize.content),
            toggle.trailingAnchor.constraint(equalTo: toggleContainer.trailingAnchor, constant: -PaddingSize.content)
        ])
        
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.content),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.content),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width * 3),
            
            stack.trailingAnchor.constraint(equalTo: toggle.leadingAnchor, constant: -PaddingSize.width*2),
            
            
            toggleContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width * 3),
            toggleContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    @objc func toggleChanged() {
        onToggleChanged?(toggle.isOn)
    }
    
    func configure(text1: String, text2: String, text3: String, canShow: Bool, state: Bool) {
        label1.configure(text: text1)
        label2.configure(text: text2)
        label3.configure(text: text3)
        markLabel.isHidden = !canShow
        toggle.isHidden = !canShow
        toggleContainer.isHidden = !canShow
        markLabel.text = state ? "Taken" : "Mark as taken"
        toggle.setOn(state, animated: false)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        toggle.isHidden = false
        markLabel.isHidden = false
        onToggleChanged = nil
    }
}

