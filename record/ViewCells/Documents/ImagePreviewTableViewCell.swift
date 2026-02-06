//
//  FileImagePreviewCollectionViewCell.swift
//  record
//
//  Created by Esakkinathan B on 29/01/26.
//

import UIKit

class FileImagePreviewCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "FileImagePreviewCollectionViewCell"
    
    var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = AppColor.emptyDocumentColor
        imgView.isUserInteractionEnabled = false
        imgView.clipsToBounds = true
        imgView.image = DocumentConstantData.docImage
        return imgView
    }()
    var onShow: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpContentView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpContentView()
    }

    func configure(with imagePath: String?) {
        if let path = imagePath {
            DocumentThumbnailProvider.generate(for: path) { [weak self] image in
                self?.imageView.image = image ?? DocumentConstantData.docImage
            }
            imageView.isUserInteractionEnabled = true
        } else {
            imageView.isUserInteractionEnabled = false
        }
        
    }

    func setUpContentView() {
        contentView.add(imageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageClicked))
        imageView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PaddingSize.height),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PaddingSize.height),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: PaddingSize.width),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -PaddingSize.width)
        ])
    }
    
    @objc func imageClicked() {
        onShow?()
    }
}
