//
//  SwitchCell.swift
//  record
//
//  Created by Esakkinathan B on 19/02/26.
//
import UIKit
final class SwitchCell: UITableViewCell {
    static let identifier = "SwitchCell"
    private let titleLabel = UILabel()
    private let toggle = UISwitch()
    private var handler: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        accessoryView = toggle
        toggle.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    func configure(title: String, isOn: Bool, onChange: @escaping (Bool) -> Void) {
        textLabel?.text = title
        toggle.isOn = isOn
        handler = onChange
    }
    
    @objc private func valueChanged() {
        handler?(toggle.isOn)
    }
}
