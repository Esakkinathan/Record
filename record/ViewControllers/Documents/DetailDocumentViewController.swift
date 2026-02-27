//
//  DetailDocumentViewController.swift
//  record
//
//  Created by Esakkinathan B on 27/01/26.
//

import UIKit
import QuickLook
import VTDB


class DetailDocumentViewController: KeyboardNotificationViewController {
    let remainderCell = "RemainderCell"
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.separatorStyle = .singleLine
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    var previewUrl: URL?
    var onEdit: ((Persistable) -> Void)?
    
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
        tableView.backgroundColor = AppColor.background
        presenter.viewDidLoad()
        setUpContent()
        setUpNavigationBar()
        hideKeyboardWhenTappedAround()
    }
    
    
    func setUpNavigationBar() {
        title = presenter.title
        navigationItem.largeTitleDisplayMode = .never
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
        tableView.register(RemainderTableViewCell.self, forCellReuseIdentifier: RemainderTableViewCell.identifier)
        tableView.register(TextViewTableViewCell.self, forCellReuseIdentifier: TextViewTableViewCell.identifier)
        tableView.register(EditNoteTableHeaderView.self, forHeaderFooterViewReuseIdentifier: EditNoteTableHeaderView.identifier)
        tableView.register(AddRemainderHeaderView.self, forHeaderFooterViewReuseIdentifier: AddRemainderHeaderView.identifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
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
        let field = presenter.getRow(at: indexPath)
        switch field {
        case .info, .remainder:
            return UITableView.automaticDimension
        default:
            return 300
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let field = presenter.getRow(at: IndexPath(row: 0, section: section))
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
        case .remainder(let count,_):
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: AddRemainderHeaderView.identifier) as! AddRemainderHeaderView
            header.configure(count: count,title: "Remainder",expiryDate: presenter.expiryDate)
            header.handleOffsetSelection = { [weak self] offset, expiryDate in
                self?.presenter.handleOffsetSelection(offset: offset, date: expiryDate)
            }
            
            return header

        default:
            return nil
        } 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = presenter.getRow(at: indexPath)
        var cell: UITableViewCell
        
        switch  field {
            
        case .image(let filePath):
            let newCell = tableView.dequeueReusableCell(withIdentifier: ImagePreviewTableViewCell.identifier, for: indexPath) as! ImagePreviewTableViewCell
            newCell.configure(with: filePath)
            newCell.onUploadButtonClicked = { [weak self] in
                self?.presenter.uploadDocument()
            }
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
        case .remainder(let count,let data):
            if let remainder = data {
                let newCell = tableView.dequeueReusableCell(withIdentifier: RemainderTableViewCell.identifier, for: indexPath) as! RemainderTableViewCell
                newCell.configure(count: count, remainder: remainder)
                cell = newCell
            } else {
                let newCell = tableView.dequeueReusableCell(withIdentifier: remainderCell) ?? UITableViewCell(style: .subtitle, reuseIdentifier: remainderCell)
                newCell.backgroundColor = .secondarySystemBackground
                newCell.textLabel?.text = "No Remainders"
                newCell.detailTextLabel?.text = "Click + to add"
                cell = newCell
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        presenter.canEditAt(indexPath)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: AppConstantData.delete) { [weak self] _, _, completion in
            self?.presenter.deleteRemainder(index: indexPath.row)
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: IconName.trash)
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = true
        return swipeAction

    }

}
extension DetailDocumentViewController: UIDocumentPickerDelegate {

    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        guard let url = urls.first else { return }
        presenter.didPickDocument(url: url)
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
    func showToastVC(message: String, type: ToastType) {
        showToast(message: message, type: type)
    }
    
    func showAlertOnAddRemainder() {
                
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .compact
        picker.minimumDate = Date()
        picker.date = Date()
        picker.maximumDate = presenter.expiryDate
        let alert = UIAlertController(
            title: "Select Date",
            message: "\n\n",
            preferredStyle: .alert
        )

        alert.view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50)
        ])

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            self?.presenter.addRemainder(date: picker.date, )
        })
        present(alert, animated: true)
    }
    func showTimePicker(baseDate: Date) {
        
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .compact
        
        let alert = UIAlertController(
            title: "Select Time",
            message: "\n\n",
            preferredStyle: .alert
        )
        
        alert.view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            picker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50)
        ])
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            
            let calendar = Calendar.current
            
            let timeComponents = calendar.dateComponents([.hour, .minute], from: picker.date)
            
            var finalComponents = calendar.dateComponents([.year, .month, .day], from: baseDate)
            finalComponents.hour = timeComponents.hour
            finalComponents.minute = timeComponents.minute
            
            if let finalDate = calendar.date(from: finalComponents) {
                self?.presenter.addRemainder(date: finalDate)
            }
        })
        
        present(alert, animated: true)
    }

    
    
    func reloadData() {
        title = presenter.title
        tableView.reloadData()
    }
    func updateDocumentNotes(text: String?,id: Int) {
        onUpdateNotes?(text,id)
    }
    
    func updateDocument(document: Persistable) {
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


