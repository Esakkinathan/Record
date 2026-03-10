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
//    let lockCopyLabel: UILabel = {
//       let label = UILabel()
//        label.text = "Unlock to view"
//        label.font = AppFont.verysmall
//        return label
//    }()
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
        imgView.widthAnchor.constraint(equalToConstant: PaddingSize.previewSize).isActive = true
        imgView.heightAnchor.constraint(equalToConstant: PaddingSize.previewSize).isActive = true
        imgView.layer.cornerRadius = PaddingSize.cornerRadius
        //imgView.layer.cornerCurve = .circular
        imgView.setAsEmptyDocument()

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
        //view2.add(lockCopyLabel)
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
        dateLabel.setContentHuggingPriority(.required, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        view1.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        view1.setContentHuggingPriority(.defaultHigh, for: .vertical)

        copyLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        NSLayoutConstraint.activate([

            nameLabel.topAnchor.constraint(equalTo: view1.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: view1.leadingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: view1.bottomAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -PaddingSize.width),
            dateLabel.trailingAnchor.constraint(equalTo: view1.trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            view1.topAnchor.constraint(equalTo: view2.topAnchor, constant: PaddingSize.content),
            view1.leadingAnchor.constraint(equalTo: view2.leadingAnchor, constant: PaddingSize.content),
            view1.trailingAnchor.constraint(equalTo: view2.trailingAnchor, constant: -PaddingSize.content),
            
            copyLabel.topAnchor.constraint(equalTo: view1.bottomAnchor, constant: PaddingSize.content),
            copyLabel.bottomAnchor.constraint(equalTo: view2.bottomAnchor, constant: -PaddingSize.content),
            copyLabel.leadingAnchor.constraint(equalTo: view2.leadingAnchor, constant: PaddingSize.content),
            copyLabel.trailingAnchor.constraint(equalTo: view2.trailingAnchor, constant: -PaddingSize.content),
//            lockCopyLabel.topAnchor.constraint(equalTo: view1.bottomAnchor, constant: PaddingSize.content),
//            lockCopyLabel.bottomAnchor.constraint(equalTo: view2.bottomAnchor, constant: -PaddingSize.content),
//            lockCopyLabel.leadingAnchor.constraint(equalTo: view2.leadingAnchor, constant: PaddingSize.content),
//            lockCopyLabel.trailingAnchor.constraint(equalTo: view2.trailingAnchor, constant: -PaddingSize.content),
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
        shareButton.isHidden = document.file == nil
        copyLabel.configure(canCopy: !document.isRestricted)
        if document.isRestricted {
            filePreview.image = UIImage(systemName: IconName.documentLock)
            copyLabel.text = "Unlock to view"
        } else {
            if let file = document.file, let filePath =  DocumentThumbnailProvider.fullURL(from: file) {
                DocumentThumbnailProvider.generate(for: filePath) { [weak self] image in
                    if let img = image {
                        self?.filePreview.image = img
                    }
                }
            } else {
                filePreview.image = DocumentConstantData.docImage
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        filePreview.image = DocumentConstantData.docImage
        nameLabel.text = ""
        dateLabel.text = ""
        copyLabel.setText("")
        shareButton.isHidden = false
        copyLabel.configure(canCopy: false)
    }
    
}
