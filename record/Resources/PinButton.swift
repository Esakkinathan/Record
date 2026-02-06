//
//  PinButton.swift
//  record
//
//  Created by Esakkinathan B on 06/02/26.
//
import UIKit

final class PinButton: UIButton {

    init(number: String) {
        super.init(frame: .zero)
        setTitle(number, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 28, weight: .medium)
        setTitleColor(.label, for: .normal)
        layer.cornerRadius = 35
        backgroundColor = .secondarySystemBackground
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        widthAnchor.constraint(equalToConstant: 80).isActive = true
        configuration = .clearGlass()
    }

    required init?(coder: NSCoder) { fatalError() }
}
