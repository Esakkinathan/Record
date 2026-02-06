//
//  CopyTextLabel.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//
import UIKit


class CopyTextLabel: UIView {
    let textLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.small
        label.layer.cornerRadius = 20
        label.backgroundColor = .secondarySystemBackground
        label.labelSetUp()
        return label
    }()
    let copyButton: UIImageView = {
        let imgView = UIImageView(image: UIImage(systemName: IconName.copy))
        imgView.contentMode = .scaleAspectFit
        imgView.isUserInteractionEnabled = true
        return imgView
    }()
    
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
        let stackView: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [textLabel,copyButton])
            stack.axis = .horizontal
            stack.alignment = .center
            stack.distribution = .fill
            stack.spacing = PaddingSize.content
            return stack
        }()
        add(stackView)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(copyToClipBoard))
        copyButton.addGestureRecognizer(tapRecognizer)
    
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
        
    @objc func copyToClipBoard() {
        copyButton.animateScaleUp()
        copyButton.animateScaleDown()
        if let textToCopy = textLabel.text {
            UIPasteboard.general.string = textToCopy
        }
    }

    
}
