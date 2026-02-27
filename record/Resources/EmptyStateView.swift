//
//  EmptyStateView.swift
//  record
//
//  Created by Esakkinathan B on 20/02/26.
//

import UIKit

class EmptyStateView: UIView {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .secondaryLabel
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = AppFont.heading3
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = AppFont.body
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    init(image: UIImage?, title: String, subtitle: String, overridden: Bool = false) {
        super.init(frame: .zero)
        
        imageView.image = image
        titleLabel.text = title
        subtitleLabel.text = subtitle
        if !overridden{
            setUpContents()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpContents() {
        add(imageView)
        add(titleLabel)
        add(subtitleLabel)
        
        NSLayoutConstraint.activate([
            
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -60),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PaddingSize.cellSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -PaddingSize.cellSpacing),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PaddingSize.cellSpacing),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -PaddingSize.cellSpacing)
        ])
    }
}



class EmptyFooterView: EmptyStateView {
    init(image: UIImage?, title: String, subtitle: String) {
        super.init(image: image, title: title, subtitle: subtitle, overridden: true)
        setUpContents()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        return view
    }()
    override func setUpContents() {
        let stack = UIStackView(arrangedSubviews: [
            imageView,
            titleLabel,
            subtitleLabel,
            //emptyView
        ])

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12

        add(stack)

        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 60),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: PaddingSize.cellSpacing),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -PaddingSize.cellSpacing)
        ])
    }
}
class EmptyHeaderView: EmptyStateView {
    init(image: UIImage?, title: String, subtitle: String) {
        super.init(image: image, title: title, subtitle: subtitle, overridden: true)
        setUpContents()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setUpContents() {
        let stack = UIStackView(arrangedSubviews: [
            imageView,
            titleLabel,
            subtitleLabel
        ])

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: PaddingSize.cellSpacing),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -PaddingSize.cellSpacing)
        ])
    }
}
final class NotFoundView: UIView {

    let button: AppButton = {
        let button = AppButton()
        var config = UIButton.Configuration.borderedTinted()
        config.image = UIImage(systemName: "plus.circle")
        config.title = "Tap to add"
        button.configuration = config
        return button
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = AppFont.heading2
        label.text = "No Search Result Found"
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    
    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        let stack = UIStackView(arrangedSubviews: [label, button])
        stack.axis = .vertical
        stack.spacing = PaddingSize.cellSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 80),
            button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5)
        ])
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
        
    @objc private func handleTap() {
        onTap?()
    }
}
