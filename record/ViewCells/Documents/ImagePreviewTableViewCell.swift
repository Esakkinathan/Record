//
//  FileImagePreviewCollectionViewCell.swift
//  record
//
//  Created by Esakkinathan B on 29/01/26.
//

import UIKit


class NoImagePreview: UIView {
    let imageView:  UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "arrow.up.document.fill")
        view.tintColor = AppColor.primaryColor
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let label1: UILabel = {
        let label = UILabel()
        label.text = "No Document Uploaded"
        label.labelSetUp()
        label.textColor = AppColor.SecondaryColor
        label.font =  AppFont.heading3
        label.textAlignment = .center
        return label
    }()
    
    let label2: UILabel = {
        let label = UILabel()
        label.text = "Upload PDF or Image"
        label.labelSetUp()
        label.textColor = .secondaryLabel

        label.textAlignment = .center
        label.font =  AppFont.heading2
        return label
    }()
    
    let button: AppButton = {
        let button = AppButton(type: .system)
        button.setTitle("Upload Document", for: .normal)
        button.enableDialPadEffect()
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpContents()
        addDashedBorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.removeAll(where: { $0 is CAShapeLayer })
        addDashedBorder()
    }

    func setUpContents() {
        add(imageView)
        add(label1)
        add(label2)
        //add(button)
        let topSpacer = UIView()
        let bottomSpacer = UIView()
        
        add(topSpacer)
        add(bottomSpacer)
        
        NSLayoutConstraint.activate([

            topSpacer.topAnchor.constraint(equalTo: topAnchor),
            topSpacer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2),

            imageView.topAnchor.constraint(equalTo: topSpacer.bottomAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3),
            
            label1.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: PaddingSize.height),
            label1.centerXAnchor.constraint(equalTo: centerXAnchor),

            label2.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: PaddingSize.height),
            label2.centerXAnchor.constraint(equalTo: centerXAnchor),

//            button.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: PaddingSize.height),
//            button.centerXAnchor.constraint(equalTo: centerXAnchor),
//            button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
//            button.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2),

            bottomSpacer.topAnchor.constraint(equalTo: label2.bottomAnchor),
            bottomSpacer.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomSpacer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2)
        ])
    }
}


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
    
    var uploadView: NoImagePreview = {
        let view = NoImagePreview()
        return view
    }()
    
    var onUploadButtonClicked: (() -> Void)?
    
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
            imagePreview.isHidden = false
            imagePreview.isUserInteractionEnabled = true
            uploadView.isHidden = true
        } else {
            imagePreview.isHidden = true
            imagePreview.isUserInteractionEnabled = false
            uploadView.isHidden = false

        }
        
    }

    func setUpContentView() {
        contentView.add(imagePreview)
        contentView.add(uploadView)
        selectionStyle = .none
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageClicked))
        imagePreview.addGestureRecognizer(tapGesture)
        
        //uploadView.button.addTarget(self, action: #selector(uploadButtonClicked), for: .touchUpInside)
        
        uploadView.clipsToBounds = true
        uploadView.isHidden = true
        
        NSLayoutConstraint.activate([
            imagePreview.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imagePreview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            imagePreview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            imagePreview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            uploadView.topAnchor.constraint(equalTo: contentView.topAnchor),
            uploadView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            uploadView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            uploadView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    @objc func uploadButtonClicked() {
        //onUploadButtonClicked?()
    }
    
    @objc func imageClicked() {
        onShow?()
    }
}
