//
//  FormFileUpload.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit

class FormFileUpload: FormField, UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return nil
    }
    
    
    static let identifier = "FormFileUpload"
    
    let documentImage = UIImageView(image: UIImage(systemName: IconName.emptyDocument))
    let addLabel = UILabel()
    let uploadView: UIStackView

    let fileImagePreview = UIImageView()
    
    var onUploadDocument: (() -> Void)?
    var onRemoveDocument: (() -> Void)?
    var onViewDocument: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        uploadView = UIStackView(arrangedSubviews: [documentImage,addLabel])
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
        setTitleLabelTop()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUpContentView() {
        
        super.setUpContentView()
        
        rightView.basicSetUp(for: uploadView)
        rightView.basicSetUp(for: fileImagePreview)
        
        uploadView.axis = .vertical
        uploadView.alignment = .center
        uploadView.layer.borderColor = AppColor.fileUploadColor.cgColor
        uploadView.isUserInteractionEnabled = true
        let uploadViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(uploadViewTapPreview))
        uploadView.addGestureRecognizer(uploadViewTapGesture)
        
        addLabel.text = "Add document"
        addLabel.font = AppFont.small
        addLabel.textColor = AppColor.fileUploadColor
        
        documentImage.tintColor = AppColor.fileUploadColor
        
        fileImagePreview.contentMode = .scaleAspectFit
        fileImagePreview.clipsToBounds = true
        fileImagePreview.isUserInteractionEnabled = true
        let filePreviewTapGesture = UITapGestureRecognizer(target: self, action: #selector(fileImageTapPreview))
        fileImagePreview.addGestureRecognizer(filePreviewTapGesture)
        
        let viewSize: CGFloat = 100
        NSLayoutConstraint.activate([
            uploadView.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: PaddingSize.widthPadding),
            uploadView.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -PaddingSize.widthPadding),
            uploadView.topAnchor.constraint(equalTo: rightView.topAnchor,constant: PaddingSize.heightPadding),
            
            fileImagePreview.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: PaddingSize.widthPadding),
            fileImagePreview.topAnchor.constraint(equalTo: rightView.topAnchor, constant: PaddingSize.heightPadding),
            fileImagePreview.widthAnchor.constraint(equalToConstant: viewSize),
            fileImagePreview.heightAnchor.constraint(equalToConstant: viewSize),
        ])
        
    }
    func uploadDocument() {
        onUploadDocument?()
    }
    
    func removeDocument() {
        onRemoveDocument?()
    }
    
    func viewDocument() {
        onViewDocument?()
    }

    @objc func uploadViewTapPreview() {
        let uploadAction = UIAction(title: "Choose from Files", image: UIImage(systemName: IconName.folder)) { [weak self] _ in
            self?.uploadDocument()
        }
        let menu = UIMenu(title: "", children: [uploadAction])


        uploadView.becomeFirstResponder()
        let interaction = UIContextMenuInteraction(delegate: self)
        uploadView.addInteraction(interaction)
    }
    
    @objc func fileImageTapPreview() {
        let viewAction = UIAction(title: "View", image: UIImage(systemName: IconName.eye)) { [weak self] _ in
            self?.viewDocument()
        }

        let replaceAction = UIAction(title: "Replace", image: UIImage(systemName: IconName.replace)) { [weak self] _ in
            self?.uploadDocument()
        }

        let removeAction = UIAction(title: "Remove", image: UIImage(systemName: IconName.trash), attributes: .destructive) { [weak self] _ in
            self?.removeDocument()
        }

        let menu = UIMenu(title: "", children: [viewAction,replaceAction,removeAction])

        fileImagePreview.becomeFirstResponder()
        let interaction = UIContextMenuInteraction(delegate: self)
        fileImagePreview.addInteraction(interaction)
    }
    
    func configure(title: String, filePath: String? = nil, isRequired: Bool = false) {
        super.configure(title: title, isRequired: isRequired)
        if let path = filePath {
            fileImagePreview.isHidden = false
            uploadView.isHidden = true
            DocumentThumbnailProvider.generate(for: path) { [weak self] image in
                self?.fileImagePreview.image = image ?? UIImage(systemName: IconName.emptyDocument)
            }
        } else {
            fileImagePreview.isHidden = true
            uploadView.isHidden = false
        }
    }
    
    func configureDocument(filePath: String) {
        uploadView.isHidden = true
        fileImagePreview.isHidden = false
        DocumentThumbnailProvider.generate(for: filePath) { [weak self] image in
            self?.fileImagePreview.image = image ?? UIImage(systemName: IconName.emptyDocument)
        }
    }
}

