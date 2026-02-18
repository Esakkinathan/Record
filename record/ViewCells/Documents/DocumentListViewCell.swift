//
//  DocumentListViewCell.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit


class ListDocumentViewCell: UICollectionViewCell {
    
    static let identifier = "listDocumentTableViewCell"
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = AppFont.small
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        return label
        
    }()
    
    let copyLabel = CopyTextLabel()
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption
        label.labelSetUp()
        return label
    }()
    
    let shareButton: AppButton = {
       let but = AppButton()
        but.setImage(UIImage(systemName: IconName.share), for: .normal)
        but.configuration = .clearGlass()
        but.widthAnchor.constraint(equalToConstant: 30).isActive = true
        but.heightAnchor.constraint(equalToConstant: 30).isActive = true

        return but
    }()
    
    let filePreview: UIImageView = {
        let imgView = UIImageView()
        imgView.image = DocumentConstantData.docImage
        imgView.setAsEmptyDocument()
        imgView.widthAnchor.constraint(equalToConstant: PaddingSize.previewSize).isActive = true
        imgView.heightAnchor.constraint(equalToConstant: PaddingSize.previewSize).isActive = true

        return imgView
    }()
    
    
    var onShareButtonClicked: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpContentViews()
    }
    
    var onDeleteClicked: (() -> Void)?
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setUpContentViews()
//    }
    
    
    func setUpContentViews() {
        
        contentView.layer.cornerRadius = PaddingSize.cornerRadius
        contentView.backgroundColor = .secondarySystemBackground
        
        let view2: UIView = {
            let view = UIView()
            view.layer.cornerRadius = PaddingSize.cornerRadius
            view.backgroundColor = AppColor.background
            return view
        }()

        let view1: UIView = {
            let view = UIView()
            view.layer.cornerRadius = PaddingSize.cornerRadius
            return view
        }()
        
        
        
        view2.add(view1)
        view2.add(copyLabel)
        view1.add(nameLabel)
        view1.add(dateLabel)

        contentView.add(filePreview)
        contentView.add(shareButton)
        //contentView.add(view1)
        contentView.add(view2)

        view2.bringSubviewToFront(view1)
        
        NSLayoutConstraint.activate([
            filePreview.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.height),
            filePreview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width),
            
            shareButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.height),
            shareButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width),
            
            view2.topAnchor.constraint(equalTo: filePreview.bottomAnchor, constant: PaddingSize.content),
            view2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.content),
            view2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.content),
            view2.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.content)

        ])
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        dateLabel.setContentHuggingPriority(.required, for: .horizontal)     // or at least .high

        // Optional but often helpful:
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        // Keep view1 stretching
//        view1.bottomAnchor.constraint(lessThanOrEqualTo: dateLabel.bottomAnchor, constant: PaddingSize.content).isActive = true

        // But make sure nameLabel doesn't get squished too much
//        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
//        nameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view1.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        view1.setContentHuggingPriority(.defaultHigh, for: .vertical)

        // And copyLabel should be more flexible
        copyLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        NSLayoutConstraint.activate([

            // name takes as much space as possible
            nameLabel.topAnchor.constraint(equalTo: view1.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: view1.leadingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: view1.bottomAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -PaddingSize.width),
            // date sticks to the right
            dateLabel.trailingAnchor.constraint(equalTo: view1.trailingAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),   // ← usually better visually

            // IMPORTANT: let name compress / truncate before date disappears
        ])
        
        NSLayoutConstraint.activate([
            view1.topAnchor.constraint(equalTo: view2.topAnchor, constant: PaddingSize.content),
            view1.leadingAnchor.constraint(equalTo: view2.leadingAnchor, constant: PaddingSize.content),
            view1.trailingAnchor.constraint(equalTo: view2.trailingAnchor, constant: -PaddingSize.content),
            
            copyLabel.topAnchor.constraint(equalTo: view1.bottomAnchor, constant: PaddingSize.content),
            copyLabel.bottomAnchor.constraint(equalTo: view2.bottomAnchor, constant: -PaddingSize.content),
            copyLabel.leadingAnchor.constraint(equalTo: view2.leadingAnchor, constant: PaddingSize.content),
            copyLabel.trailingAnchor.constraint(equalTo: view2.trailingAnchor, constant: -PaddingSize.content),
        ])

        shareButton.addTarget(self, action: #selector(shareButtonClicked), for: .touchUpInside)
                
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func shareButtonClicked() {
        onShareButtonClicked?()
    }
    func configure(document: Document) {
        nameLabel.text = document.name
        copyLabel.setText(document.number)  
        dateLabel.text = document.createdAt.toString()
        
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        filePreview.image = DocumentConstantData.docImage
        nameLabel.text = ""
        dateLabel.text = ""
        copyLabel.setText("")
    }
    
}

/*
 func setUpContentView() {
     
     let labelsStack = UIStackView(arrangedSubviews: [
         nameLabel,
         copyLabel,
         dateLabel
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

     //selectionStyle = .none
     
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
