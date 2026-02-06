//
//  DocumentListViewCell.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit

class ListDocumentTableViewCell: UITableViewCell {
    
    static let identifier = "listDocumentTableViewCell"
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = AppFont.heading3
        return label
    }()
    
    let copyLabel = CopyTextLabel()
    let createdAtLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption
        label.labelSetUp()
        return label
    }()
    
    let shareButton: AppButton = {
       let but = AppButton()
        but.setImage(UIImage(systemName: IconName.share), for: .normal)
        but.configuration = .clearGlass()
        return but
    }()
    
    let filePreview: UIImageView = {
        let imgView = UIImageView()
        imgView.image = DocumentConstantData.docImage
        imgView.setAsEmptyDocument()
        return imgView
    }()
    
    
    var onShareButtonClicked: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    func setUpContentView() {
        
        let labelsStack = UIStackView(arrangedSubviews: [
            nameLabel,
            copyLabel,
            createdAtLabel
        ])
        labelsStack.axis = .vertical
        labelsStack.spacing = PaddingSize.content

        let actionStack = UIStackView(arrangedSubviews: [
            shareButton,
        ])
        actionStack.axis = .vertical
        actionStack.spacing = PaddingSize.content
        actionStack.alignment = .center

        contentView.add(filePreview)
        contentView.add(labelsStack)
        contentView.add(actionStack)
        
        
        shareButton.addTarget(self, action: #selector(shareButtonClicked), for: .touchUpInside)

        selectionStyle = .none
        
        NSLayoutConstraint.activate([

            filePreview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width),
            filePreview.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.height),
            filePreview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
            filePreview.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),

            labelsStack.leadingAnchor.constraint(equalTo: filePreview.trailingAnchor, constant: PaddingSize.width),
            labelsStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.height),
            labelsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
            labelsStack.trailingAnchor.constraint(lessThanOrEqualTo: actionStack.leadingAnchor, constant: -PaddingSize.width),

            actionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width),
            actionStack.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: PaddingSize.height),
            actionStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -PaddingSize.height),
            actionStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    func configure(document: Document) {
        nameLabel.text = document.name
        copyLabel.setText(document.number)  
        createdAtLabel.text = "Created at: \(document.createdAt.toString())"
        
        if let file = document.file {
            shareButton.isHidden = false
            DocumentThumbnailProvider.generate(for: file) { [weak self] image in
                if let img = image {
                    self?.filePreview.image = img
                }
            }
        } else {
            filePreview.image = DocumentConstantData.docImage
            shareButton.isHidden = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func shareButtonClicked() {
        onShareButtonClicked?()
    }

}

/*
 
 let labelsStack = UIStackView(arrangedSubviews: [
     nameLabel,
     numberLabel,
     createdAtLabel
 ])
 labelsStack.axis = .vertical
 labelsStack.spacing = PaddingSize.height
 labelsStack.translatesAutoresizingMaskIntoConstraints = false

 let actionStack = UIStackView(arrangedSubviews: [
     copyButton,
     shareButton
 ])
 actionStack.axis = .vertical
 actionStack.spacing = PaddingSize.height
 actionStack.alignment = .center
 actionStack.translatesAutoresizingMaskIntoConstraints = false

 contentView.addSubview(filePreview)
 contentView.addSubview(labelsStack)
 contentView.addSubview(actionStack)

 filePreview.translatesAutoresizingMaskIntoConstraints = false

 NSLayoutConstraint.activate([

     filePreview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width),
     filePreview.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.height),
     filePreview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
     filePreview.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),

     labelsStack.leadingAnchor.constraint(equalTo: filePreview.trailingAnchor, constant: PaddingSize.width),
     labelsStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
     labelsStack.trailingAnchor.constraint(lessThanOrEqualTo: actionStack.leadingAnchor, constant: -PaddingSize.width),

     actionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width),
     actionStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

     copyButton.widthAnchor.constraint(equalToConstant: PaddingSize.copyButtonSize),
     copyButton.heightAnchor.constraint(equalToConstant: PaddingSize.copyButtonSize)
 ])

 
 func setUpContentView() {
     
     contentView.add(filePreview)
     contentView.add(nameLabel)
     contentView.add(numberLabel)
     contentView.add(copyButton)
     contentView.add(shareButton)
     contentView.add(createdAtLabel)
     
     let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(copyToClipBoard))
     copyButton.addGestureRecognizer(tapRecognizer)
     
     shareButton.addTarget(self, action: #selector(shareButtonClicked), for: .touchUpInside)

     NSLayoutConstraint.activate([
         
         filePreview.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.height),
         filePreview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -PaddingSize.height),
         filePreview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: PaddingSize.width),
         filePreview.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
         filePreview.widthAnchor.constraint(equalTo: contentView.widthAnchor,multiplier: 0.25),
                     
         nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: PaddingSize.height),
         nameLabel.bottomAnchor.constraint(equalTo: numberLabel.topAnchor),
         nameLabel.leadingAnchor.constraint(equalTo: filePreview.trailingAnchor, constant: PaddingSize.width),
         nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -PaddingSize.width),
         
         
         numberLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: PaddingSize.height),
         numberLabel.bottomAnchor.constraint(equalTo: createdAtLabel.topAnchor),
         numberLabel.leadingAnchor.constraint(equalTo: filePreview.trailingAnchor, constant: PaddingSize.width),
         numberLabel.trailingAnchor.constraint(lessThanOrEqualTo: copyButton.leadingAnchor, constant: -PaddingSize.width),
         
         
         createdAtLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: PaddingSize.height),
         createdAtLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
         createdAtLabel.leadingAnchor.constraint(equalTo: filePreview.trailingAnchor, constant: PaddingSize.width),
         createdAtLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width),
         
         shareButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
         shareButton.leadingAnchor.constraint(equalTo: copyButton.trailingAnchor, constant: PaddingSize.width),
         shareButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -PaddingSize.width),
         
         copyButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
         copyButton.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, ),
         copyButton.bottomAnchor.constraint(equalTo: createdAtLabel.topAnchor),
         copyButton.widthAnchor.constraint(equalToConstant: PaddingSize.copyButtonSize),
         copyButton.heightAnchor.constraint(equalToConstant: PaddingSize.copyButtonSize)
     ]
 }
 

 */
