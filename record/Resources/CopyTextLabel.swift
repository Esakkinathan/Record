//
//  CopyTextLabel.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//
import UIKit


/*
class CopyTextLabel: UIView {
    let textLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.verysmall
        label.layer.cornerRadius = PaddingSize.cornerRadius
        //label.backgroundColor = .secondarySystemBackground
        label.labelSetUp()
        return label
    }()
//    lazy var button: UIButton = {
//        let btn = UIButton(type: .system)
//        btn.setTitle("", for: .normal)
//        btn.showsMenuAsPrimaryAction = true
//        return btn
//    }()
    let copyButton: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(systemName: IconName.copy)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()
    let contentView = UIView()
    var text: String? {
        get {
            return textLabel.text
        } set(value) {
            textLabel.text = value
        }
    }
    
    init() {
        super.init(frame: .zero)
        setUpContents()
    }
    func setText(_ text: String) {
        textLabel.text = text
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUpContents() {
        
        contentView.add(textLabel)
        contentView.add(copyButton)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = PaddingSize.cornerRadius
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.content),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.content),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.content),
            textLabel.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -PaddingSize.content),
            copyButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.content),
            copyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.content),
            copyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.content),
            copyButton.widthAnchor.constraint(equalToConstant: PaddingSize.copyButtonSize),
            copyButton.heightAnchor.constraint(equalToConstant: PaddingSize.copyButtonSize),
            
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(copyToClipBoard))
        copyButton.addGestureRecognizer(tap)
        
        add(contentView)
        //add(button)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
//            button.leadingAnchor.constraint(equalTo: leadingAnchor),
//            button.topAnchor.constraint(equalTo: topAnchor),
//            button.bottomAnchor.constraint(equalTo: bottomAnchor),
//            button.trailingAnchor.constraint(equalTo: trailingAnchor),
        
            
        //contentView.heightAnchor.constraint(equalTo: copyButton.heightAnchor),
        ])
        
        //updateMenu()
    }
        
//    func updateMenu() {
//        let copyAction = UIAction(title: "Copy", image: UIImage(systemName: IconName.folder)) { [weak self] _ in
//            self?.copyToClipBoard()
//        }
//        
//        button.menu = UIMenu(title: "", children: [copyAction])
//
//    }
    
    @objc func copyToClipBoard() {
        copyButton.animateScaleUp()
        copyButton.animateScaleDown()
        if let textToCopy = textLabel.text {
            UIPasteboard.general.string = textToCopy
        }
    }

    
}
*/


class TimerView: UIView {
    let textLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.body
        label.numberOfLines = 0
        return label
    }()
    let contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = PaddingSize.cornerRadius
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.separator.withAlphaComponent(0.5).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    func setText(_ text: String) {
        textLabel.text = text
    }


    init() {
        super.init(frame: .zero)
        setupLayout()
    }
    private func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false

        contentView.add(textLabel)
        add(contentView)

        let p = PaddingSize.content

        NSLayoutConstraint.activate([
            // contentView fills self
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),

            // textLabel
            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: p),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -p),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
        ])
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class CopyTextLabel: UIView {
    
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.verysmall
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let copyIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: IconName.copy)
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .secondaryLabel
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()

    private let checkIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "checkmark.circle.fill")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGreen
        iv.clipsToBounds = true
        iv.alpha = 0
        iv.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        return iv
    }()

    let contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = PaddingSize.cornerRadius
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.separator.withAlphaComponent(0.5).cgColor
        return v
    }()


    var text: String? {
        get { textLabel.text }
        set { textLabel.text = newValue }
    }

    func setText(_ text: String) {
        textLabel.text = text
    }


    init() {
        super.init(frame: .zero)
        setupLayout()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false

        // Icon container — stack copy + check on top of each other
        let iconContainer = UIView()
        iconContainer.isUserInteractionEnabled = true
        iconContainer.add(copyIconView)
        iconContainer.add(checkIconView)

        contentView.add(textLabel)
        contentView.add(iconContainer)
        add(contentView)

        let p = PaddingSize.content
        let iconSize = PaddingSize.copyButtonSize

        NSLayoutConstraint.activate([
            // contentView fills self
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),

            // textLabel
            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: p),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -p),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            textLabel.trailingAnchor.constraint(equalTo: iconContainer.leadingAnchor, constant: -3),

            // iconContainer
            iconContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            iconContainer.widthAnchor.constraint(equalToConstant: iconSize),
            iconContainer.heightAnchor.constraint(equalToConstant: iconSize),

            // copy icon fills iconContainer
            copyIconView.topAnchor.constraint(equalTo: iconContainer.topAnchor),
            copyIconView.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor),
            copyIconView.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor),
            copyIconView.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor),

            // check icon fills iconContainer
            checkIconView.topAnchor.constraint(equalTo: iconContainer.topAnchor),
            checkIconView.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor),
            checkIconView.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor),
            checkIconView.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor),
        ])
    }

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(copyToClipboard))
        // Tap anywhere on the view copies (more ergonomic)
        addGestureRecognizer(tap)
    }

    // MARK: - Copy Action

    @objc private func copyToClipboard() {
        guard let textToCopy = textLabel.text, !textToCopy.isEmpty else { return }
        UIPasteboard.general.string = textToCopy
        animateCopied()
    }

    private func animateCopied() {
        // Phase 1: shrink & fade out copy icon, pop in check icon
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseIn) {
            self.copyIconView.alpha = 0
            self.copyIconView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }

        UIView.animate(withDuration: 0.25, delay: 0.08,
                       usingSpringWithDamping: 0.55,
                       initialSpringVelocity: 0.8,
                       options: []) {
            self.checkIconView.alpha = 1
            self.checkIconView.transform = .identity
            // Briefly tint the background green
            self.contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.08)
            self.contentView.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.4).cgColor
        }

        // Phase 2: revert after a beat
        UIView.animate(withDuration: 0.2, delay: 1.4, options: .curveEaseIn) {
            self.checkIconView.alpha = 0
            self.checkIconView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.contentView.backgroundColor = .secondarySystemBackground
            self.contentView.layer.borderColor = UIColor.separator.withAlphaComponent(0.5).cgColor
        }

        UIView.animate(withDuration: 0.25, delay: 1.52,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.5,
                       options: []) {
            self.copyIconView.alpha = 1
            self.copyIconView.transform = .identity
        }
    }
}
