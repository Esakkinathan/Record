//
//  Toast.swift
//  record
//
//  Created by Esakkinathan B on 06/02/26.
//
import UIKit

enum ToastType {
    case info
    case success
    case warning
    case error
    
    var backgroundColor: UIColor {
        switch self {
        case .info:
            return UIColor.systemBlue
        case .success:
            return UIColor.systemGreen
        case .warning:
            return UIColor.systemOrange
        case .error:
            return UIColor.systemRed
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .info:
            return UIImage(systemName: "info.circle.fill")
        case .success:
            return UIImage(systemName: "checkmark.circle.fill")
        case .warning:
            return UIImage(systemName: "exclamationmark.triangle.fill")
        case .error:
            return UIImage(systemName: "xmark.octagon.fill")
        }
    }
}

class ToastView: UIView {
    
    private let label = UILabel()
    private let imageView = UIImageView()
    
    init(message: String, type: ToastType) {
        super.init(frame: .zero)
        
        backgroundColor = type.backgroundColor.withAlphaComponent(0.95)
        layer.cornerRadius = 14
        clipsToBounds = true
        
        imageView.image = type.icon
        imageView.tintColor = .white
        
        label.text = message
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.spacing = 10
        stack.alignment = .center
        
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIViewController {
    
    func showToast(
        message: String,
        type: ToastType,
        duration: TimeInterval = 2.5
    ) {
        let toast = ToastView(message: message, type: type)
        view.addSubview(toast)
        
        toast.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -56),
            toast.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.9)
        ])
        
        toast.alpha = 0
        toast.transform = CGAffineTransform(translationX: 0, y: 20)
        
        UIView.animate(withDuration: 0.3) {
            toast.alpha = 1
            toast.transform = .identity
        }
        
        UIView.animate(
            withDuration: 0.3,
            delay: duration,
            options: .curveEaseInOut
        ) {
            toast.alpha = 0
            toast.transform = CGAffineTransform(translationX: 0, y: 20)
        } completion: { _ in
            toast.removeFromSuperview()
        }
    }
}
