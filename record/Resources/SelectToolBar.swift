//
//  SelectToolBar.swift
//  record
//
//  Created by Esakkinathan B on 17/03/26.
//

import UIKit

class SelectionToolbarView: UIView {

    // MARK: UI
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemThinMaterial)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        return view
    }()
    
    let totalLabel: UILabel = {
       let label = UILabel()
        label.textColor = .label
        label.font = AppFont.body
        label.text = "Total: 0"
        return label
    }()
    let selectedLabel: UILabel = {
       let label = UILabel()
        label.textColor = .label
        label.font = AppFont.body
        label.text = "Selected: 0"
        return label
    }()

    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: Setup
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 30
        layer.masksToBounds = false

        addSubview(blurView)
        addSubview(stackView)
        add(totalLabel)
        add(selectedLabel)
        let height: CGFloat = 6
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            totalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            totalLabel.topAnchor.constraint(equalTo: topAnchor, constant: height),
            
            selectedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            selectedLabel.topAnchor.constraint(equalTo: topAnchor, constant: height),
            
            
            stackView.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: height),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -height),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
        ])
    }

    
    func configure(total: Int, selected: Int) {
        totalLabel.text = "Total: \(total)"
        selectedLabel.text = "Selected: \(selected)"
    }
    // MARK: Public — VC calls this to inject buttons
    func setButtons(_ buttons: [UIButton]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttons.forEach { stackView.addArrangedSubview($0) }
    }

    // MARK: Show / Hide (self-contained animation)
    func show(in view: UIView, bottomConstraint: NSLayoutConstraint, bottomOffset: CGFloat = -92) {
        isHidden = false
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: 20)
        bottomConstraint.constant = bottomOffset

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.transform = .identity
            view.layoutIfNeeded()
        }
    }

    func hide(in view: UIView, bottomConstraint: NSLayoutConstraint, defaultOffset: CGFloat) {
        isHidden = true
        bottomConstraint.constant = defaultOffset

        UIView.animate(withDuration: 0.25) {
            view.layoutIfNeeded()
        }
    }
    
}
