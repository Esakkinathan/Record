//
//  DetailDocumentViewController.swift
//  record
//
//  Created by Esakkinathan B on 27/01/26.
//

import UIKit
import QuickLook

class DetailDocumentViewController: UIViewController {
    var document: Document!
    
    let nameLabel = UILabel()
    let numberLabel = UILabel()
    let expiryDateLabel = UILabel()
    var documentImage: UIImage?
    var collectionView: UICollectionView!
    var previewUrl: URL?
    var onEdit: ((Document) -> Void)?
    
    let documentName = "Document Name"
    let documentNumber = "Document Number"
    let expiryDate = "Expiry Date"
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpContent()
        setUpNavigationBar()
    }
    
    func configure(document: Document) {
        self.document = document
    }
    
    func setUpNavigationBar() {
        title = document.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppConstantData.edit, style: AppConstantData.buttonStyle, target: self, action: #selector(editDocument))
    }
    
    func setUpContent() {
        collectionView = {
            let layout = getUpCompositionalLayout()
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            return collectionView
        } ()
        
        view.basicSetUp(for: collectionView)
        collectionView.dataSource = self
        
        collectionView.register(FileImagePreviewCollectionViewCell.self, forCellWithReuseIdentifier: FileImagePreviewCollectionViewCell.identifier)
        collectionView.register(TextViewCollectionViewCell.self, forCellWithReuseIdentifier: TextViewCollectionViewCell.identifier)
        
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: PaddingSize.heightPadding),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PaddingSize.widthPadding),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PaddingSize.widthPadding)
        ])

    }
    
    func getUpCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (section, _) in
            guard let self = self else { return nil }
            switch section {
            case 0:
                return self.createImagePreviewSection()
            case 1:
                return self.createDetailListSection()
            default:
                return nil
            }
        }
        return layout
    }

    func createImagePreviewSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(250))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.bottom = 30
        
        return section

    }
    
    func createDetailListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.bottom = 30
        return section
    }

    @objc func editDocument() {
        let vc = AddDocumentViewController()
        vc.configure(document.type, action: .edit, document: document)
        vc.onEdit = { [weak self] document in
            guard let self = self else { return }
            self.document = document
            self.collectionView.reloadData()
            self.onEdit?(document)
        }
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .formSheet

        present(navVc, animated: true)

    }

}

extension DetailDocumentViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        default:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        switch indexPath.section {
        case 0:
            let newCell = collectionView.dequeueReusableCell(withReuseIdentifier: FileImagePreviewCollectionViewCell.identifier, for: indexPath) as! FileImagePreviewCollectionViewCell
            
            if let filePath = document.file {
                newCell.configure(with: filePath)
                newCell.onShow = { [weak self] in
                    guard let self = self else {return}
                    self.previewUrl = URL(fileURLWithPath: self.document.file ?? "")
                    let previweVC = QLPreviewController()
                    previweVC.dataSource = self
                    self.present(previweVC, animated: true)
                }
            }
            cell = newCell
            
        case 1:
            let newCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextViewCollectionViewCell.identifier, for: indexPath) as! TextViewCollectionViewCell
            switch indexPath.row {
            case 0:
                newCell.configure(text: "\(documentName) \(document.name)" )
            case 1:
                newCell.configure(text: "\(documentNumber) \(document.number)")
            default:
                newCell.configure(text: "\(expiryDate) \(document.expiryDate?.toString() ?? "" )")
            }
            cell = newCell
        default:
            cell = UICollectionViewCell()
        }
        return cell
    }
}

extension DetailDocumentViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
        return previewUrl! as QLPreviewItem
    }

}
