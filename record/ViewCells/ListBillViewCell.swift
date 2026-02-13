//
//  ListBillViewCell.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//
import UIKit


class ListBillViewCell: UITableViewCell {
    
    
    static let identifier = "ListBillViewCell"
    let toggle = UISwitch()
    
    var onSwitchValueChanged: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ text1: String, _ text2: String, value: Bool) {
        textLabel?.text = text1
        detailTextLabel?.text = text2
        if !value {
            toggle.isHidden = false
            toggle.isEnabled = true
            toggle.isOn = false
        } else{
            toggle.isHidden = true
        }

    }
    func setUpContentView() {
        selectionStyle = .none
        contentView.add(toggle)
        toggle.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        NSLayoutConstraint.activate([
            toggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width*3),
            toggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        
    }
    @objc func switchValueChanged() {
        toggle.isOn = true
        onSwitchValueChanged?()
        //toggle.isEnabled = false
        //toggle.isOn = false
        
    }
    

}
