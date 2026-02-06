//
//  AppButton.swift
//  record
//
//  Created by Esakkinathan B on 21/01/26.
//
import UIKit


class AppButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        var customConfiguration = UIButton.Configuration.borderedTinted()
        customConfiguration.cornerStyle = .capsule
        configuration = customConfiguration
        
    }
    
    func enableDialPadEffect(
        scale: CGFloat = 1.08,
        highlightAlpha: CGFloat = 0.85
    ) {
        configurationUpdateHandler = { button in
            var config = button.configuration

            if button.isHighlighted {
                let backColor = config?.baseBackgroundColor ?? .systemBlue
                config?.baseBackgroundColor = backColor.withAlphaComponent(highlightAlpha)

                UIView.animate(
                    withDuration: 0.15,
                    delay: 0,
                    usingSpringWithDamping: 0.55,
                    initialSpringVelocity: 0.8,
                    options: [.allowUserInteraction]
                ) {
                    button.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            } else {
                UIView.animate(withDuration: 0.12) {
                    button.transform = .identity
                }
            }

            button.configuration = config
        }
    }

}
