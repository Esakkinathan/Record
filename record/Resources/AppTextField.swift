//
//  AppTextField.swift
//  record
//
//  Created by Esakkinathan B on 21/01/26.
//

import UIKit

class AppTextField: UITextField {
    private let fieldHeight: CGFloat = 48

    let normalBorderColor = UIColor.separator.cgColor
    let activeBorderColor = AppColor.primaryColor.cgColor

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: fieldHeight)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        borderStyle = .none
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = normalBorderColor

        backgroundColor = .secondarySystemBackground
        font = AppFont.body
        textColor = .label
        setLeftPadding(12)
        setRightPadding(12)
        //borderStyle = .

    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        activateBorder()
        return result
    }

    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        deactivateBorder()
        return result
    }

    
    private func activateBorder() {
        layer.borderColor = activeBorderColor
        layer.borderWidth = 1.5
    }

    private func deactivateBorder() {
        layer.borderColor = normalBorderColor
        layer.borderWidth = 1
    }
}

extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 0))
        leftView = paddingView
        leftViewMode = .always
    }

    func setRightPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 0))
        rightView = paddingView
        rightViewMode = .always
    }
}


