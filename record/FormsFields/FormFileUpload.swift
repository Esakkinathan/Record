//
//  FormFileUpload.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit

class FormFileUpload: FormFieldCell {

    static let identifier = "FormFileUpload"
    
    
    let documentImage = UIImageView(image: UIImage(systemName: "arrow.up.document.fill"))
    
    let addLabel: UILabel = {
        let label = UILabel()
        label.labelSetUp()
        label.text = DocumentConstantData.addDocument
        label.textColor = AppColor.fileUploadColor
        label.font = AppFont.small
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
        stack.layer.cornerRadius = 12
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
    
    var onUploadDocument: (() -> Void)?
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
        
        uploadView.insertArrangedSubview(documentImage, at: 0)
        uploadView.insertArrangedSubview(addLabel, at: 1)
                
        addLabel.text = "Upload PDF or Image"
        
        addLabel.textColor = AppColor.fileUploadColor
        
        documentImage.tintColor = AppColor.fileUploadColor
        documentImage.contentMode = .scaleAspectFit
                
        let previewSize: CGFloat = 110
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

        ])
        updateMenus()
        
    }
    
    
    private func updateMenus() {
        
        let pickAction = UIAction(title: "Choose from Files", image: UIImage(systemName: IconName.folder)) { [weak self] _ in
            self?.onUploadDocument?()
        }
        
        uploadButton.menu = UIMenu(title: "", children: [pickAction])

        let viewAction = UIAction(title: "View", image: UIImage(systemName: IconName.eye)) { [weak self] _ in
            self?.onViewDocument?()
        }
        
        let replaceAction = UIAction(title: "Replace", image: UIImage(systemName: IconName.replace)) { [weak self] _ in
            self?.onUploadDocument?()
        }
        
        let removeAction = UIAction(title: "Remove", image: UIImage(systemName: IconName.trash), attributes: .destructive) { [weak self] _ in
            self?.onRemoveDocument?()
        }
        
        previewButton.menu = UIMenu(title: "", children: [viewAction, replaceAction, removeAction])
    }
    
    func setDocuments(hasDocument: Bool, fileUrl: String? = nil) {
        uploadView.isHidden = hasDocument
        fileImagePreview.isHidden = !hasDocument
        uploadButton.isHidden = hasDocument
        previewButton.isHidden = !hasDocument
        if let path = fileUrl {
            DocumentThumbnailProvider.generate(for: path) { [weak self] image in
                self?.fileImagePreview.image = image ?? self?.documentImage.image
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

