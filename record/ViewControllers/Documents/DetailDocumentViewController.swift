//
//  DetailDocumentViewController.swift
//  record
//
//  Created by Esakkinathan B on 27/01/26.
//

import UIKit
import QuickLook



class DetailDocumentViewController: KeyboardNotificationViewController {
    
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.separatorStyle = .singleLine
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    var previewUrl: URL?
    var onEdit: ((Document) -> Void)?
    
    var presenter: DetailDocumentPresenterProtocol!
    var onUpdateNotes: ((String?,Int) -> Void)?
    
    override var keyboardScrollableView: UIScrollView? {
        return tableView
    }

    override var scrollToIndexPathOnKeyboardShow: IndexPath? {
        return IndexPath(row: 0, section: 2)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        setUpContent()
        setUpNavigationBar()
        hideKeyboardWhenTappedAround()
    }
    
    
    func setUpNavigationBar() {
        title = presenter.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editDocument))
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    func setUpContent() {
        
        view.add(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(ImagePreviewTableViewCell.self, forCellReuseIdentifier: ImagePreviewTableViewCell.identifier)
        tableView.register(FormLabel.self, forCellReuseIdentifier: FormLabel.identifier)
        tableView.register(FormCopyLabel.self, forCellReuseIdentifier: FormCopyLabel.identifier)
        tableView.register(TextViewTableViewCell.self, forCellReuseIdentifier: TextViewTableViewCell.identifier)
        tableView.register(EditNoteTableHeaderView.self, forHeaderFooterViewReuseIdentifier: EditNoteTableHeaderView.identifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
    @objc func editDocument() {
        presenter.editButtonClicked()
    }
}

extension DetailDocumentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        presenter.numberOfSection()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfSectionRows(at: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.getTitle(for: section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let field = presenter.section(at: indexPath)
        switch field {
        case .info:
            return UITableView.automaticDimension
        default:
            return 300
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let field = presenter.section(at: IndexPath(row: 0, section: section))
        
        switch field {
        case .notes(_, let isEditable):
            let header = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: EditNoteTableHeaderView.identifier
            ) as! EditNoteTableHeaderView

            header.configure(
                title: "Notes",
                isEditing: isEditable
            )
            header.onEditButtonClicked = { [weak self] isEditing in
                self?.view.endEditing(isEditing)
                self?.presenter.toggleNotesEditing(isEditing)
            }
            return header
        default:
            return nil
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = presenter.section(at: indexPath)
        
        var cell: UITableViewCell
        
        switch  field {
            
        case .image(let filePath):
            let newCell = tableView.dequeueReusableCell(withIdentifier: ImagePreviewTableViewCell.identifier, for: indexPath) as! ImagePreviewTableViewCell
            newCell.configure(with: filePath)
            
            newCell.onShow = { [weak self] in
                guard let self = self, let path = filePath else {return}
                    self.previewUrl = URL(fileURLWithPath: path)
                    presenter.viewDocument()
                }
            
            cell = newCell
        case .info(let title, let value):
            if title == "Number" {
                let newCell = tableView.dequeueReusableCell(withIdentifier: FormCopyLabel.identifier, for: indexPath) as! FormCopyLabel
                newCell.configure(title: title, text: value)
                cell = newCell
            } else {
                let newCell = tableView.dequeueReusableCell(withIdentifier: FormLabel.identifier, for: indexPath) as! FormLabel
                
                newCell.configure(title: title, text: value)
                cell = newCell
            }
            
        case .notes(let text, let isEditable):
            let newCell = tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.identifier, for: indexPath) as! TextViewTableViewCell
            newCell.configure(text: text, value: isEditable)
            newCell.onValueChange = { [weak self] text in
                self?.presenter.updateNotes(text: text)
            }
            cell = newCell
        }
        return cell
    }

    
}

extension DetailDocumentViewController: QLPreviewControllerDataSource {
    
    func configureToOpenDocument(previewUrl: URL) {
        self.previewUrl  = previewUrl
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
        return previewUrl! as QLPreviewItem
    }

}

extension DetailDocumentViewController: DetailDocumentViewDelegate {
    
    func reloadData() {
        title = presenter.title
        tableView.reloadData()
    }
    func updateDocumentNotes(text: String?,id: Int) {
        onUpdateNotes?(text,id)
    }
    
    func updateDocument(document: Document) {
        onEdit?(document)
    }
}

extension DetailDocumentViewController: DocumentNavigationDelegate {
    
    func push(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true)
    }
}


//        let vc = AddDocumentViewController()
//        vc.configure(document.type, action: .edit, document: document)
//        vc.onEdit = { [weak self] document in
//            guard let self = self else { return }
//            self.document = document
//            self.collectionView.reloadData()
//            self.onEdit?(document)
//        }
//        let navVc = UINavigationController(rootViewController: vc)
//        navVc.modalPresentationStyle = .formSheet
//
//        present(navVc, animated: true)

/*
    func getUpCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (section, _) in
            guard let self = self else { return nil }
            switch section {
            case 0:
                return self.createImagePreviewSection()
            case 1:
                return self.createDetailListSection()
            case 2:
                return self.createNotesSection()
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
        section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(44)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
            ]
        return section

    }
    
    func createDetailListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.bottom = 30
        section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(44)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
            ]
        return section
    }

    func createNotesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(400))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.bottom = 30
        section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(44)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
            ]
        return section

    }
    
    @objc func editDocument() {
        presenter.editButtonClicked()
    }

}

extension DetailDocumentViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        presenter.numberOfSection()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.numberOfSectionRows(at: section)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView: UICollectionReusableView
        let section = DetailDocumentSection.allCases[indexPath.section]
        switch section {
            
        case .notes:
            
            let newResusbaleView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EditNoteCollectionView.identifier, for: indexPath) as! EditNoteCollectionView
            newResusbaleView.configure(text: section.rawValue)
            newResusbaleView.onEditButtonClicked = { [weak self] value in
                guard let self = self else { return }
                if !value {
                    self.presenter.updateNotes(text: self.getNotesText(indexPath))
                }
                self.setTextViewEditable(value,indexPath: indexPath)
            }
            
            reusableView = newResusbaleView
            
        default:
            
            let newResusbaleView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderCollectionView.identifier, for: indexPath) as! SectionHeaderCollectionView
            newResusbaleView.configure(text: section.rawValue)
            reusableView = newResusbaleView
            
        }
        return reusableView
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        let section = DetailDocumentSection.allCases[indexPath.section]
        
        switch section {
        case .image:
            let newCell = collectionView.dequeueReusableCell(withReuseIdentifier: FileImagePreviewCollectionViewCell.identifier, for: indexPath) as! FileImagePreviewCollectionViewCell
            
            let filePath = presenter.getImagePath()
            newCell.configure(with: filePath)
            newCell.onShow = { [weak self] in
                guard let self = self, let path = presenter.getImagePath() else {return}
                    self.previewUrl = URL(fileURLWithPath: path)
                    presenter.viewDocument()
                }
            cell = newCell
            
        case .text:
            let field = presenter.textRowData(at: indexPath.row)
            
            let newCell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelViewCollectionViewCell.identifier, for: indexPath) as! LabelViewCollectionViewCell
            newCell.configure(text: "\(field.title) \(field.value)")
            cell = newCell
            
        case .notes:
           let newCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextViewCollectionCell.identifier, for: indexPath) as! TextViewCollectionCell
            newCell.configure(text: presenter.getNotes())
            cell  = newCell
        }
        return cell
    }
    
    func getNotesCell(_ indexPath: IndexPath) -> TextViewCollectionCell {
        return collectionView.cellForItem(at: indexPath) as! TextViewCollectionCell
    }
    
    func getNotesText(_ indexPath: IndexPath) -> String? {
        let text = getNotesCell(indexPath).enteredText
        return text
    }
    
    func setTextViewEditable(_ value: Bool, indexPath: IndexPath) {
        let cell = getNotesCell(indexPath)
        cell.modifyEditing(value)
    }
}

*/
