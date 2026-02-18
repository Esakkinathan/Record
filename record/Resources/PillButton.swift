//
//  PillButton.swift
//  record
//
//  Created by Esakkinathan B on 16/02/26.
//
import UIKit

class PillButton: UIButton {
    
    private var pillTitle: String
    private var pillImage: UIImage?
    
    override var isSelected: Bool {
        didSet {
            updateAppearance(animated: true, )
            invalidateIntrinsicContentSize()
        }
    }
    
    init(title: String, image: UIImage?) {
        self.pillTitle = title
        self.pillImage = image
        super.init(frame: .zero)
        setUpContens()
        layer.cornerRadius = 18
        clipsToBounds = true


    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpContens() {
        var config = UIButton.Configuration.plain()
        config.image = pillImage
        config.image?.withTintColor(.systemGray2)
        config.imagePlacement = .leading
        config.imagePadding = 6

        configuration = config

        updateAppearance(animated: false)

    }
    
    func updateAppearance(animated: Bool) {
        guard var config = configuration else {return}
        if isSelected {
            config.title = pillTitle
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 14)
            backgroundColor = AppColor.primaryColor
            tintColor = .white
        } else {
            config.title = nil
            config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            backgroundColor = .systemGray5
            tintColor = .secondaryLabel
        }
        if animated {
            UIView.transition(with: self, duration: 0.4, options: .curveEaseOut) {
                self.configuration = config
                self.layoutIfNeeded()
            }
        } else {
            configuration = config
        }

    }
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if !isSelected {
            size.width = size.height
        }
        return size
    }

}

/*

import UIKit

class PillButton: UIButton {
    
    private var pillTitle: String
    private var pillImage: UIImage?
    
    // Glass Effect
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blur)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            updateAppearance(animated: true)
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: - Init
    
    init(title: String, image: UIImage?) {
        self.pillTitle = title
        self.pillImage = image?.withRenderingMode(.alwaysTemplate)
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setup() {
        layer.cornerRadius = 18
        clipsToBounds = true
        
        insertSubview(blurView, at: 0)
        
        var config = UIButton.Configuration.plain()
        config.image = pillImage
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 10, leading: 10, bottom: 10, trailing: 10
        )
        
        configuration = config
        
        updateAppearance(animated: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
        blurView.layer.cornerRadius = layer.cornerRadius
        blurView.clipsToBounds = true
    }
    
    // MARK: - Appearance
    
    private func updateAppearance(animated: Bool) {
        guard var config = configuration else { return }
        
        if isSelected {
            // Expanded pill
            config.title = pillTitle

            config.baseForegroundColor = .white
            tintColor = .white
            config.contentInsets = NSDirectionalEdgeInsets(
                top: 8, leading: 14, bottom: 8, trailing: 16
            )
            
            blurView.isHidden = true
            backgroundColor = AppColor.primaryColor
            
            // Soft shadow
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.2
            layer.shadowRadius = 6
            layer.shadowOffset = CGSize(width: 0, height: 4)
            
        } else {
            // Circular icon
            config.title = nil
            tintColor = .secondaryLabel
            config.contentInsets = NSDirectionalEdgeInsets(
                top: 10, leading: 10, bottom: 10, trailing: 10
            )
            
            blurView.isHidden = false
            backgroundColor = .clear
            
            layer.shadowOpacity = 0
            config.image = pillImage?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
            // Optional subtle border
            layer.borderWidth = 1
            layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [.curveEaseInOut]
            ) {
                self.configuration = config
                self.layoutIfNeeded()
            }
        } else {
            configuration = config
        }
    }
    
    // MARK: - Intrinsic Size
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        
        // When not selected → make it a circle
        if !isSelected {
            size.width = size.height
        }
        
        return size
    }
}
*/
