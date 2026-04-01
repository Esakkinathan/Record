//
//  FormFileUpload.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit

enum DocumentType {
    case pdf
    case image
}

class FormFileUpload: FormFieldCell {

    static let identifier = "FormFileUpload"
    
    
    let documentImage: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "arrow.up.document.fill"))
        view.tintColor = AppColor.fileUploadColor
        view.contentMode = .scaleAspectFit
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        return view
    }()
    private let infoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray.withAlphaComponent(0.08)
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.25).cgColor
        return view
    }()

    private let infoIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "info.circle.fill"))
        iv.tintColor = .systemGray
        iv.contentMode = .scaleAspectFit
        iv.widthAnchor.constraint(equalToConstant: 18).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 18).isActive = true
        return iv
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Max \(AppConstantData.maxFiles) file / \(AppConstantData.maxImageFiles) images allowed. Files will be merged into a one."
        label.textAlignment = .justified
        return label
    }()

    private lazy var infoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [infoIcon, infoLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    let addLabel: UILabel = {
        let label = UILabel()
        label.labelSetUp()
        label.textColor = .label
        label.font = AppFont.verysmall
        label.text = "Upload PDF or Image"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let uploadView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = 2
        stack.layer.borderWidth = 2
        stack.layer.borderColor = AppColor.primaryColor.cgColor
        stack.layer.cornerRadius = PaddingSize.cornerRadius
        stack.clipsToBounds = true
        stack.backgroundColor = .systemGray6.withAlphaComponent(0.6)
        stack.isUserInteractionEnabled = false
        return stack
    }()

    let fileImagePreview: UIImageView = {
        let iv = UIImageView()
        iv.setAsEmptyDocument()
        iv.layer.cornerRadius = 10
        iv.isUserInteractionEnabled = false
        iv.tintColor = AppColor.emptyDocumentColor
        return iv
    }()
    
    lazy var uploadButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("", for: .normal)
        btn.showsMenuAsPrimaryAction = true
        btn.isHidden = false
        return btn
    }()
        
    private lazy var previewButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("", for: .normal)
        btn.showsMenuAsPrimaryAction = true
        btn.isHidden = true
        return btn
    }()
    
    var onUploadDocument: ((DocumentType) -> Void)?
    var onOpenCamera: (() -> Void)?
    var onRemoveDocument: (() -> Void)?
    var onViewDocument: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpContentView()
        setTitleLabelTop()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUpContentView() {
        
        super.setUpContentView()
        
        rightView.add(uploadView)
        rightView.add(uploadButton)
        
        rightView.add(fileImagePreview)
        rightView.add(previewButton)
        rightView.add(infoContainer)
        infoContainer.add(infoStack)
        uploadView.insertArrangedSubview(documentImage, at: 0)
        uploadView.insertArrangedSubview(addLabel, at: 1)
                
        
                
        let previewSize: CGFloat = 110
        let space: CGFloat = 6
        NSLayoutConstraint.activate([
                        
            uploadView.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.height),
            uploadView.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.width),
            uploadView.bottomAnchor.constraint(equalTo: rightView.bottomAnchor, constant: -FormSpacing.width),
            uploadView.widthAnchor.constraint(equalToConstant: previewSize),
            uploadView.heightAnchor.constraint(equalToConstant: previewSize),
            uploadButton.leadingAnchor.constraint(equalTo: uploadView.leadingAnchor),
            uploadButton.trailingAnchor.constraint(equalTo: uploadView.trailingAnchor),
            uploadButton.topAnchor.constraint(equalTo: uploadView.topAnchor),
            uploadButton.bottomAnchor.constraint(equalTo: uploadView.bottomAnchor),
            
            fileImagePreview.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: FormSpacing.width),
            fileImagePreview.topAnchor.constraint(equalTo: rightView.topAnchor, constant: FormSpacing.height),
            fileImagePreview.widthAnchor.constraint(equalToConstant: previewSize),
            fileImagePreview.heightAnchor.constraint(equalToConstant: previewSize),
            fileImagePreview.bottomAnchor.constraint(lessThanOrEqualTo: rightView.bottomAnchor, constant: -FormSpacing.height),
            
            previewButton.leadingAnchor.constraint(equalTo: fileImagePreview.leadingAnchor),
            previewButton.trailingAnchor.constraint(equalTo: fileImagePreview.trailingAnchor),
            previewButton.topAnchor.constraint(equalTo: fileImagePreview.topAnchor),
            previewButton.bottomAnchor.constraint(equalTo: fileImagePreview.bottomAnchor),
            
            infoContainer.leadingAnchor.constraint(equalTo: uploadView.trailingAnchor, constant: PaddingSize.width),
            infoContainer.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -FormSpacing.width),
            infoContainer.centerYAnchor.constraint(equalTo: uploadView.centerYAnchor),
            
            infoStack.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: space),
            infoStack.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: -space),
            infoStack.topAnchor.constraint(equalTo: infoContainer.topAnchor, constant: space),
            infoStack.bottomAnchor.constraint(equalTo: infoContainer.bottomAnchor, constant: -space)

        ])
        updateMenus()
        
    }
    
    
    private func updateMenus() {
        
        let pickPdfAction = UIAction(title: "Upload Pdf", image: UIImage(systemName: IconName.folder)) { [weak self] _ in
            self?.onUploadDocument?(.pdf)
        }
        let pickImageAction = UIAction(title: "Upload Images", image: UIImage(systemName: IconName.photoAdd)) { [weak self] _ in
            self?.onUploadDocument?(.image)
        }
        let cameraAction = UIAction(title: "Take Picture", image: UIImage(systemName: IconName.camera)) { [weak self] _ in
            self?.onOpenCamera?()
        }
        let uploadMenu = UIMenu(title: "Upload", children: [pickPdfAction, pickImageAction, cameraAction])
        uploadButton.menu = uploadMenu

        let viewAction = UIAction(title: "View", image: UIImage(systemName: IconName.eye)) { [weak self] _ in
            self?.onViewDocument?()
        }
        
        
        let removeAction = UIAction(title: "Remove", image: UIImage(systemName: IconName.trash), attributes: .destructive) { [weak self] _ in
            self?.onRemoveDocument?()
        }
        let replace = UIMenu(title: "Upload", options: .singleSelection,children: [pickPdfAction, pickImageAction,cameraAction])

         
        previewButton.menu = UIMenu(title: "", children: [viewAction, replace, removeAction])
    }
    
    func setDocuments(hasDocument: Bool, fileUrl: String? = nil) {
        uploadView.isHidden = hasDocument
        uploadButton.isHidden = hasDocument
        fileImagePreview.isHidden = !hasDocument
        previewButton.isHidden = !hasDocument
        infoContainer.isHidden = hasDocument
        if let path = fileUrl {
            DocumentThumbnailProvider.generate(for: path) { [weak self] image in
                self?.fileImagePreview.image = image ?? DocumentConstantData.docImage
            }
        }
    }
    
    func configure(title: String, filePath: String?,isRequired: Bool = false) {
        super.configure(title: title, isRequired: isRequired)
        if let path = filePath {
            setDocuments(hasDocument: true, fileUrl: path)
        } else {
            setDocuments(hasDocument: false)
        }
    }
    
    func configure(field: DocumentFormField,isRequired: Bool = false) {
        super.configure(title: field.label, isRequired: isRequired)
        if let path = field.value as? String {
            setDocuments(hasDocument: true, fileUrl: path)
        } else {
            setDocuments(hasDocument: false)
        }
    }
    
    func configureDocument(filePath: String) {
        setDocuments(hasDocument: true,fileUrl: filePath)
    }
    
    func refreshMenus() {
        updateMenus()
    }

}

