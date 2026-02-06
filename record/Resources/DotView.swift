//
//  DotView.swift
//  record
//
//  Created by Esakkinathan B on 06/02/26.
//
import UIKit

class Dot: UIView {
    let dot = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpContents()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpContents() {
        dot.backgroundColor = AppColor.gray
        dot.layer.cornerRadius = 10
        dot.layer.masksToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        add(dot)
        NSLayoutConstraint.activate([
            dot.centerXAnchor.constraint(equalTo: centerXAnchor),
            dot.centerYAnchor.constraint(equalTo: centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 20),
            dot.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    
}

class DotsView: UIStackView {

    private let maxDots = 6
    private var dots: [Dot] = []

    init() {
        super.init(frame: .zero)
        axis = .horizontal
        distribution = .fillEqually
        spacing = 12
        setup()
    }

    required init(coder: NSCoder) { fatalError() }

    private func setup() {
        for _ in 0..<maxDots {
            let dot = Dot()
            dots.append(dot)
            addArrangedSubview(dot)
        }
    }

    func update(count: Int) {
        for (index, dot) in dots.enumerated() {
            dot.dot.backgroundColor = index < count ? AppColor.primaryColor : AppColor.gray
        }
    }

    func clear() {
        update(count: 0)
    }
}
