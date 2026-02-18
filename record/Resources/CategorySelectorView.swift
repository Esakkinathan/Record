//
//  CategorySelectorView.swift
//  record
//
//  Created by Esakkinathan B on 16/02/26.
//

import UIKit

class CategorySelectorView: UIView {
    let stack = UIStackView()
    var onSelect: ((String) -> Void)?
    
    init(frame: CGRect, options: [String], images: [String]) {
        super.init(frame: frame)
        setUpContens()
        createButtons(options: options, images: images)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var buttons: [String: PillButton] = [:]
    
    func setUpContens() {
        stack.axis = .horizontal
        stack.spacing = PaddingSize.content
        stack.alignment = .center
        
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        
        add(scroll)
        scroll.add(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: topAnchor),
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PaddingSize.width),
            scroll.trailingAnchor.constraint(equalTo: trailingAnchor),

            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.heightAnchor.constraint(equalTo: scroll.heightAnchor)
        ])
        
    }
    func createButtons(options: [String], images: [String]) {
        let button = PillButton(title: "All", image: UIImage(systemName: "square.grid.2x2"))
        button.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
        buttons["All"] = button
        stack.addArrangedSubview(button)
                         
        for (option, image) in zip(options, images) {
            let button = PillButton(title: option,image: UIImage(systemName: image))
            button.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
            buttons[option] = button
        }

        select("All")
        }

    @objc func tap(_ sender: PillButton) {
        guard let category = buttons.first(where: { $0.value == sender })?.key else { return }
        select(category)
        onSelect?(category)
    }
    func select(_ category: String) {
            buttons.forEach { $0.value.isSelected = ($0.key == category) }
        }
}
