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
        label.font = AppFont.verysmall
        label.layer.cornerRadius = PaddingSize.cornerRadius
        //label.backgroundColor = .secondarySystemBackground
        label.labelSetUp()
        return label
    }()
    lazy var button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("", for: .normal)
        btn.showsMenuAsPrimaryAction = true
        return btn
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
        let contentView = UIView()
        contentView.add(textLabel)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = PaddingSize.cornerRadius
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.content),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.content),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.content),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.content)
        ])
        
        add(contentView)
        add(button)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            
            //contentView.heightAnchor.constraint(equalTo: copyButton.heightAnchor),
        ])
        
        updateMenu()
    }
        
    func updateMenu() {
        let copyAction = UIAction(title: "Copy", image: UIImage(systemName: IconName.folder)) { [weak self] _ in
            self?.copyToClipBoard()
        }
        
        button.menu = UIMenu(title: "", children: [copyAction])

    }
    
    @objc func copyToClipBoard() {
        //copyButton.animateScaleUp()
        //copyButton.animateScaleDown()
        if let textToCopy = textLabel.text {
            UIPasteboard.general.string = textToCopy
        }
    }

    
}
