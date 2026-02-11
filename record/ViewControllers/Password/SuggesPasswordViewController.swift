//
//  SuggesPasswordViewController.swift
//  record
//
//  Created by Esakkinathan B on 04/02/26.
//

import UIKit

struct PasswordOptions {
    let length: Int
    let includeLetters: Bool
    let includeNumbers: Bool
    let includeSymbols: Bool
}

struct PasswordGenerator {

    static func generate(options: PasswordOptions) -> String {
        var characters = ""

        if options.includeLetters {
            characters += "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
        if options.includeNumbers {
            characters += "0123456789"
        }
        if options.includeSymbols {
            characters += "!@#$%^&*()-_=+[]{};:,.<>?"
        }

        guard !characters.isEmpty else { return "" }

        return String((0..<options.length).compactMap { _ in
            characters.randomElement()
        })
    }
}

 class SuggesPasswordViewController: UIViewController {

    var onApply: ((String) -> Void)?

    let passwordLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.heading3
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 8
        label.layer.borderColor = UIColor.systemGray4.cgColor
        label.backgroundColor = .secondarySystemBackground
        label.text = "—"
        return label
    }()
    
     private let lengthSlider: AppSlider = {
         let slider = AppSlider()
         slider.tintColor = AppColor.primaryColor
         slider.setMinimumTrackImage(UIImage(systemName: "6"), for: .normal)
         slider.setMaximumTrackImage(UIImage(systemName: "20"), for: .normal)
         slider.sliderStyle = .thumbless
         return slider
     }()
    private let lengthLabel: UILabel = {
        let label = UILabel()
        label.labelSetUp()
        label.font = AppFont.body
        return label
    }()

    private let lettersSwitch = UISwitch()
    private let numbersSwitch = UISwitch()
    private let symbolsSwitch = UISwitch()

    private let copyButton = AppButton(type: .system)
    private let regenerateButton = AppButton(type: .system)

    private var currentPassword: String = ""
    var lengthLabeText: String {
         return "\(Int(lengthSlider.value))"
     }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        setUpNavigationBar()
        setUpContents()
    }
     func setUpNavigationBar() {
         title = "Suggest Password"
         
         navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppConstantData.cancel, style: AppConstantData.buttonStyle, target: self, action: #selector(cancelClicked))
         navigationItem .rightBarButtonItem = UIBarButtonItem(title: AppConstantData.apply, style: AppConstantData.buttonStyle, target: self, action: #selector(applyButtonClicked))
     }
    func setUpContents() {
        lengthSlider.minimumValue = 6
        lengthSlider.maximumValue = 20
        lengthSlider.value = 12
        lengthLabel.text = lengthLabeText
        lettersSwitch.isOn = true
        numbersSwitch.isOn = true
        symbolsSwitch.isOn = true
        
        lengthSlider.addTarget(self,action: #selector(lengthChanged),for: .valueChanged)
        
        let stackView: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [
                passwordLabel,
                lengthLabel,
                lengthSlider,
                optionRow(title: "Include Letters", toggle: lettersSwitch),
                optionRow(title: "Include Numbers", toggle: numbersSwitch),
                optionRow(title: "Include Symbols", toggle: symbolsSwitch),
                buttonRow()
            ])
            stack.axis = .vertical
            stack.spacing = 16
            return stack
        }()
        
        copyButton.setTitle("Copy", for: .normal)
        regenerateButton.setTitle("Generate", for: .normal)
        
        copyButton.addTarget(self, action: #selector(copyButtonClicked), for: .touchUpInside)
        regenerateButton.addTarget(self, action: #selector(regenerateButtonClicked), for: .touchUpInside)
        
        view.add(stackView)
        
        updatePassword()
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: PaddingSize.height),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PaddingSize.width),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PaddingSize.width),
            passwordLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])

    }
    @objc func applyButtonClicked() {
        if currentPassword.isEmpty { return }
        onApply?(currentPassword)
        cancelClicked()
    }
    
    @objc func copyButtonClicked() {
        UIPasteboard.general.string = currentPassword
    }
    
    @objc func regenerateButtonClicked() {
        updatePassword()
    }
    
     @objc func cancelClicked() {
         dismiss(animated: true)
     }
    
    
    @objc private func lengthChanged() {
        lengthLabel.text = lengthLabeText
        updatePassword()
    }
    
    private func updatePassword() {
        let options = PasswordOptions(
            length: Int(lengthSlider.value),
            includeLetters: lettersSwitch.isOn,
            includeNumbers: numbersSwitch.isOn,
            includeSymbols: symbolsSwitch.isOn
        )

        currentPassword = PasswordGenerator.generate(options: options)
        passwordLabel.text = currentPassword
    }
    
    func optionRow(title: String, toggle: UISwitch) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 15)

        let stack = UIStackView(arrangedSubviews: [label, toggle])
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        return stack
    }
    
    func buttonRow() -> UIView {
        regenerateButton.setContentHuggingPriority(.required, for: .horizontal)
        copyButton.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [regenerateButton, copyButton])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually

        return stack
    }
        
}
