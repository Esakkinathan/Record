//
//  FileImagePreviewCollectionViewCell.swift
//  record
//
//  Created by Esakkinathan B on 29/01/26.
//

import UIKit

class ImagePreviewTableViewCell: UITableViewCell {
    
    static let identifier = "ImagePreviewTableViewCell"
    
    var imagePreview: UIImageView = {
        let imgView = UIImageView()
        imgView.image = DocumentConstantData.docImage
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = AppColor.emptyDocumentColor
        imgView.isUserInteractionEnabled = false
        imgView.clipsToBounds = true
        return imgView
    }()
    
    var onShow: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpContentView()
    }

    func configure(with imagePath: String?) {
        if let path = imagePath {
            DocumentThumbnailProvider.generate(for: path) { [weak self] image in
                self?.imagePreview.image = image ?? DocumentConstantData.docImage
            }
            imagePreview.isUserInteractionEnabled = true
        } else {
            imagePreview.isUserInteractionEnabled = false
        }
        
    }

    func setUpContentView() {
        contentView.add(imagePreview)
        
        selectionStyle = .none
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageClicked))
        imagePreview.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            imagePreview.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imagePreview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            imagePreview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            imagePreview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ])
    }
    
    @objc func imageClicked() {
        onShow?()
    }
}
