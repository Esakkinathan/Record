//
//  FormTextField.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//
import UIKit

class FormLabel: FormFieldCell {
    
//    func register(tableView: UITableView) {
//        tableView.register(FormLabel.self, forCellReuseIdentifier: identifier)
//    }
//    
//    func dequeue(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
//        return cell
//    }

    
    static let identifier = "FormLabel"
    let contentLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
        setTitleLabelCenter()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, text: String,isRequired: Bool = false) {
        super.configure(title: title, isRequired: isRequired)
        contentLabel.text = text
    }
    override func setUpContentView() {
        
        super.setUpContentView()
        
        rightView.add(contentLabel)
        contentLabel.font = AppFont.body
        contentLabel.labelSetUp()
        NSLayoutConstraint.activate([
            contentLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            contentLabel.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width),
            contentLabel.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
        ])
        
    }
    

}
