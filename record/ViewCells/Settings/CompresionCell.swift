//
//  CompresionCell.swift
//  record
//
//  Created by Esakkinathan B on 02/03/26.
//
import UIKit
class CompresionCell: UITableViewCell {
    static let identifier = "compressionCell"
    
    var button: UIButton = {
        let button = UIButton(type: .custom)
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .secondaryLabel
        config.baseBackgroundColor = .secondarySystemBackground
        config.imagePlacement = .trailing
        config.imagePadding = 4
        button.configuration = config
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
        return button

    }()
    
    var handler: ((PDFCompressionLevel) -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    let buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = PaddingSize.cornerRadius
        return view
    }()

    func setUpContentView() {
        buttonView.add(button)
        let space: CGFloat = 3
        textLabel?.text = "Select Pdf Compression Level"
        selectionStyle = .none
        NSLayoutConstraint.activate([
            
            button.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: space),
            button.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: -space),
            button.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: space),
            button.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -space),
            
        ])
        
        contentView.add(buttonView)
        NSLayoutConstraint.activate([
            buttonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width),
            buttonView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.height),
            buttonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height)
        ])
        
        buildMenu()
    }
    
    func buildMenu() {
        let lowAction = UIAction(title: "Low") { [weak self] _ in
            //self?.configure(text: "Low")
            self?.handler?(.low)
        }
        let mediumAction = UIAction(title: "Medium") { [weak self] _ in
            //self?.configure(text: "Medium")

            self?.handler?(.medium)
        }
        let highAction = UIAction(title: "High") { [weak self] _ in
            //self?.configure(text: "High")
            self?.handler?(.high)
        }
        button.menu = UIMenu(title: "",children: [lowAction, mediumAction, highAction])


    }
    
    func configure(text: String) {
        button.configuration?.title = text
    }

}
