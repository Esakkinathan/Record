//
//  PasswordCopyLabel.swift
//  record
//
//  Created by Esakkinathan B on 25/02/26.
//

import UIKit

class PasswordCopyLabel: UIView {


    var password: String? {
        didSet { updateDisplay() }
    }


    private let contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .tertiarySystemBackground
        v.layer.cornerRadius = PaddingSize.cornerRadius
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.separator.withAlphaComponent(0.5).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let passwordLabel: UILabel = {
        let l = UILabel()
        l.font = AppFont.body
        l.numberOfLines = 1
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.7
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let eyeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: IconName.eye), for: .normal)
        b.tintColor = .secondaryLabel
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let copyIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: IconName.copy)
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .secondaryLabel
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let checkIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "checkmark.circle.fill")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGreen
        iv.alpha = 0
        iv.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let lastCopiedLabel: UILabel = {
        let l = UILabel()
        l.font = AppFont.verysmall
        l.textColor = .systemGray5
        l.text = "" // hidden until first copy
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()


    private var isRevealed = false
    private var autoHideTimer: Timer?
    var onCopy: (() -> Void)?
    var lastCopiedDate: Date? {
        didSet {
            updateLastCopiedLabel()
        }
    }
    //private var lastCopiedTimer: Timer?


    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
        setupActions()
        updateDisplay()
    }

    required init?(coder: NSCoder) { fatalError() }


    private func setupLayout() {
        addSubview(contentView)
        addSubview(lastCopiedLabel)

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(copyIconView)
        iconContainer.addSubview(checkIconView)

        contentView.addSubview(passwordLabel)
        contentView.addSubview(eyeButton)
        contentView.addSubview(iconContainer)

        let p: CGFloat = 12
        let iconSize: CGFloat = PaddingSize.copyButtonSize

        NSLayoutConstraint.activate([
            // contentView
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),

            // lastCopiedLabel
            lastCopiedLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 4),
            lastCopiedLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            lastCopiedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            lastCopiedLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            // passwordLabel
            passwordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: p),
            passwordLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -p),
            passwordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            passwordLabel.trailingAnchor.constraint(equalTo: eyeButton.leadingAnchor, constant: -6),

            // eyeButton
            eyeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            eyeButton.trailingAnchor.constraint(equalTo: iconContainer.leadingAnchor, constant: -8),
            eyeButton.widthAnchor.constraint(equalToConstant: iconSize),
            eyeButton.heightAnchor.constraint(equalToConstant: iconSize),

            // iconContainer
            iconContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            iconContainer.widthAnchor.constraint(equalToConstant: iconSize),
            iconContainer.heightAnchor.constraint(equalToConstant: iconSize),

            // copyIconView fills iconContainer
            copyIconView.topAnchor.constraint(equalTo: iconContainer.topAnchor),
            copyIconView.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor),
            copyIconView.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor),
            copyIconView.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor),

            // checkIconView fills iconContainer
            checkIconView.topAnchor.constraint(equalTo: iconContainer.topAnchor),
            checkIconView.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor),
            checkIconView.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor),
            checkIconView.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(copyToClipboard))
        iconContainer.isUserInteractionEnabled = true
        iconContainer.addGestureRecognizer(tap)
    }


    private func setupActions() {
        eyeButton.addTarget(self, action: #selector(toggleReveal), for: .touchUpInside)
    }

    @objc private func toggleReveal() {
        isRevealed ? hidePassword() : revealPassword()
    }

    private func revealPassword() {
        isRevealed = true
        updateDisplay()
        animateEyeButton(revealed: true)

        autoHideTimer?.invalidate()
        autoHideTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            guard let self = self, self.isRevealed else { return }
            self.hidePassword()
        }
    }

    private func hidePassword() {
        isRevealed = false
        autoHideTimer?.invalidate()
        autoHideTimer = nil
        updateDisplay()
        animateEyeButton(revealed: false)
    }


    private func updateDisplay() {
        guard let pwd = password, !pwd.isEmpty else {
            passwordLabel.text = "••••••••"
            return
        }
        if isRevealed {
            passwordLabel.text = pwd
            passwordLabel.textColor = .label
        } else {
            passwordLabel.text = String(repeating: "•", count: min(pwd.count, 16))
            passwordLabel.textColor = .secondaryLabel
        }
    }


    private func animateEyeButton(revealed: Bool) {
        let newImage = UIImage(systemName: revealed ? IconName.eyeSlash : IconName.eye)
        UIView.transition(with: eyeButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.eyeButton.setImage(newImage, for: .normal)
            self.eyeButton.tintColor = revealed ? .label : .secondaryLabel
        }

        UIView.animate(withDuration: 0.15, delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 1.0) {
            self.eyeButton.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        } completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.5) {
                self.eyeButton.transform = .identity
            }
        }
    }


    @objc private func copyToClipboard() {
        guard let text = password, !text.isEmpty else { return }
        UIPasteboard.general.string = text
        lastCopiedDate = Date()
        //startLastCopiedTimer()
        animateCopied()
        onCopy?()
        
    }


    private func animateCopied() {
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
            self.contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.08)
            self.contentView.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.4).cgColor
        }

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


//    private func startLastCopiedTimer() {
//        lastCopiedTimer?.invalidate()
//        updateLastCopiedLabel()
//        lastCopiedTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
//            self?.updateLastCopiedLabel()
//        }
//    }
//    
    func configure(text: String, date: Date) {
        passwordLabel.text = text
        lastCopiedLabel.text = date.reminderFormatted()
    }

    private func updateLastCopiedLabel() {
        guard let date = lastCopiedDate else {
            lastCopiedLabel.text = ""
            return
        }
        let text = "Last copied at: \(date.reminderFormatted())"

        UIView.transition(with: lastCopiedLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.lastCopiedLabel.text = text
        }
    }
}
