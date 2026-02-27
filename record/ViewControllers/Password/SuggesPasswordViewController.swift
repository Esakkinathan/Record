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

    let passwordLabel: CopyTextLabel = {
        let label = CopyTextLabel()
        label.textLabel.font = AppFont.heading3
        label.textLabel.textAlignment = .center
        label.textLabel.numberOfLines = 0
        label.text = "—"
        return label
    }()
     let minLabel: UILabel = {
         let label = UILabel()
         label.font = AppFont.body
         label.text = "6"
         return label
     }()
     let maxLabel: UILabel = {
         let label = UILabel()
         label.font = AppFont.body
         label.text = "20"
         return label
     }()
     private let lengthSlider: AppSlider = {
         let slider = AppSlider()
         slider.minimumValue = 6
         slider.maximumValue = 20
         slider.value = 12
         //slider.isContinuous = false
         slider.tintColor = AppColor.primaryColor
//         slider.setMinimumTrackImage(UIImage(systemName: "6"), for: .normal)
//         slider.setMaximumTrackImage(UIImage(systemName: "20"), for: .normal)
         slider.sliderStyle = .default
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

     private let regenerateButton: AppButton = {
         let button = AppButton(type: .system)
         button.setTitle("Generate", for: .normal)
         return button
     }()

    private var currentPassword: String = ""
    var lengthLabeText: String {
         return "Current: \(Int(lengthSlider.value))"
     }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        setUpNavigationBar()
        setUpContents()
    }
     func setUpNavigationBar() {
         title = "Suggest Password"
         navigationItem.largeTitleDisplayMode = .never
         navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppConstantData.cancel, style: AppConstantData.buttonStyle, target: self, action: #selector(cancelClicked))
         navigationItem .rightBarButtonItem = UIBarButtonItem(title: AppConstantData.apply, style: AppConstantData.buttonStyle, target: self, action: #selector(applyButtonClicked))
     }
    func setUpContents() {
        lengthLabel.text = lengthLabeText
        lettersSwitch.isOn = true
        numbersSwitch.isOn = true
        symbolsSwitch.isOn = true
        
        lengthSlider.addTarget(self,action: #selector(lengthChanged),for: .valueChanged)
        let sliderStack: UIStackView = {
           let stack = UIStackView(arrangedSubviews: [minLabel, lengthSlider, maxLabel])
            stack.axis = .horizontal
            stack.spacing = PaddingSize.content
            stack.distribution = .fill
            return stack
        }()

        let stackView: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [
                passwordLabel,
                lengthLabel,
                sliderStack,
                optionRow(title: "Include Letters", toggle: lettersSwitch),
                optionRow(title: "Include Numbers", toggle: numbersSwitch),
                optionRow(title: "Include Symbols", toggle: symbolsSwitch),
                regenerateButton
            ])
            stack.axis = .vertical
            stack.spacing = PaddingSize.cellSpacing
            return stack
        }()
        
//        copyButton.setTitle("Copy", for: .normal)
//        regenerateButton.setTitle("Generate", for: .normal)
//        
//        copyButton.addTarget(self, action: #selector(copyButtonClicked), for: .touchUpInside)
        regenerateButton.addTarget(self, action: #selector(regenerateButtonClicked), for: .touchUpInside)
        regenerateButton.setContentHuggingPriority(.required, for: .horizontal)
        view.add(stackView)
        view.add(regenerateButton)
        updatePassword()
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: PaddingSize.height),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: PaddingSize.width),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -PaddingSize.width),
            passwordLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            regenerateButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: PaddingSize.cellSpacing),
            regenerateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            regenerateButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            regenerateButton.heightAnchor.constraint(equalToConstant: 40),

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
//        copyButton.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [regenerateButton])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually

        return stack
    }
        
}
