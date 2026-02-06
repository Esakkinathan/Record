//
//  DocumentListViewCell.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit

class ListDocumentTableViewCell: UITableViewCell {
    static let identifier = "listDocumentTableViewCell"
    let nameLabel = UILabel()
    let numberLabel = UILabel()
    var issueDateLabel = UILabel()
    var expiryDateLabel = UILabel()
    let copyButton = UIImageView()
    let shareButton = AppButton()
    let filePreview = UIImageView()
    let subView = UIView()
    var onShareButtonClicked: (() -> Void)?
    let docImage = UIImage(systemName: IconName.emptyDocument)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }
    
    func setUpContentView() {
        //filePreview
        contentView.basicSetUp(for: filePreview)
        filePreview.image = docImage
        filePreview.tintColor = AppColor.emptyDocumentColor
        filePreview.contentMode = .scaleAspectFit
        filePreview.setContentHuggingPriority(.required, for: .horizontal)
        filePreview.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        //subview
        contentView.basicSetUp(for: subView)
        
        // nameLabel
        subView.basicSetUp(for: nameLabel)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.font = AppFont.heading3
        nameLabel.numberOfLines = 0
        nameLabel.textColor = .label
        nameLabel.lineBreakMode = .byWordWrapping
        
        // numberLabel
        subView.basicSetUp(for: numberLabel)
        numberLabel.font = AppFont.small
        numberLabel.backgroundColor = .secondarySystemBackground
        numberLabel.numberOfLines = 0
        numberLabel.textColor = .label
        numberLabel.lineBreakMode = .byWordWrapping
        
        // copyButton
        subView.basicSetUp(for: copyButton)
        copyButton.image = UIImage(systemName: IconName.copy)
        copyButton.contentMode = .scaleAspectFit
        copyButton.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(copyToClipBoard))
        copyButton.addGestureRecognizer(tapRecognizer)
        
        
        // shareButton
        subView.basicSetUp(for: shareButton)
        shareButton.setImage(UIImage(systemName: IconName.share), for: .normal)
        shareButton.configuration = .clearGlass()
        shareButton.addTarget(self, action: #selector(shareButtonClicked), for: .touchUpInside)
        
        // expiryDate
        subView.basicSetUp(for: expiryDateLabel)
        expiryDateLabel.font = AppFont.caption

        
        let filePreviewWidth = contentView.frame.width * 0.25
        //let subViewWidth = contentView.frame.width * 0.75
        
        NSLayoutConstraint.activate([
            filePreview.topAnchor.constraint(equalTo: contentView.topAnchor,constant: PaddingSize.heightPadding),
            filePreview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -PaddingSize.heightPadding),
            filePreview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: PaddingSize.widthPadding),
            filePreview.widthAnchor.constraint(equalToConstant: filePreviewWidth),
            
            subView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: PaddingSize.heightPadding),
            subView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -PaddingSize.heightPadding),
            subView.leadingAnchor.constraint(equalTo: filePreview.trailingAnchor,constant: PaddingSize.widthPadding),
            subView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.widthPadding),
            
            nameLabel.topAnchor.constraint(equalTo: subView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: subView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: shareButton.leadingAnchor, constant: -PaddingSize.widthPadding),
            
            numberLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: PaddingSize.contentSpacing),
            numberLabel.leadingAnchor.constraint(equalTo: subView.leadingAnchor),
            numberLabel.trailingAnchor.constraint(lessThanOrEqualTo: copyButton.leadingAnchor, constant: -PaddingSize.widthPadding),
            
            expiryDateLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: PaddingSize.contentSpacing),
            expiryDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -PaddingSize.heightPadding),
            expiryDateLabel.leadingAnchor.constraint(equalTo: subView.leadingAnchor),

            shareButton.centerYAnchor.constraint(equalTo: subView.centerYAnchor),
            shareButton.trailingAnchor.constraint(equalTo: subView.trailingAnchor,constant: -PaddingSize.widthPadding),
            
            copyButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,constant: PaddingSize.contentSpacing),
            copyButton.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: PaddingSize.widthPadding),
            copyButton.widthAnchor.constraint(equalToConstant: PaddingSize.copyButtonSize),
            copyButton.heightAnchor.constraint(equalToConstant: PaddingSize.copyButtonSize)
        ])
    }
    
    func configure(document: Document) {
        nameLabel.text = document.name
        numberLabel.text = document.number
        
        if let expiryDate = document.expiryDate {
            expiryDateLabel.isHidden = false
            expiryDateLabel.text = expiryDate.toString()
        } else {
            expiryDateLabel.isHidden = true
        }
        if let file = document.file {
            // Set a placeholder immediately while generating the thumbnail
            filePreview.image = docImage
            shareButton.isHidden = false
            DocumentThumbnailProvider.generate(for: file) { [weak self] image in
                guard let self = self else { return }
                self.filePreview.image = image ?? self.docImage
            }
        } else {
            filePreview.image = docImage
            shareButton.isHidden = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func copyToClipBoard() {
        animateScaleDown(copyButton)
        animateScaleUp(copyButton)
        let textToCopy = numberLabel.text ?? ""
        UIPasteboard.general.string = textToCopy
    }
    
    func animateScaleDown(_ view: UIView) {
        UIView.animate(withDuration: 0.3) {
            view.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
    }
    
    @objc func shareButtonClicked() {
        onShareButtonClicked?()
    }
    
    func animateScaleUp(_ view: UIView) {
        UIView.animate(withDuration: 0.3) {
            view.transform = .identity
        }
    }

}

