//
//  DetailMedicalViewController.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//

import UIKit
import VTDB
import QuickLook

class DetailMedicalViewController: KeyboardNotificationViewController {
    
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.separatorStyle = .singleLine
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    var presenter: DetailMedicalPresenterProtocol!
    var onUpdateNotes: ((String?,Int) -> Void)?
    var onEdit: ((Persistable) -> Void)?
    var previewUrl: URL?
    private var loadingOverlay: LoadingOverlayView?

    override var keyboardScrollableView: UIScrollView? {
        return tableView
    }
    
//    override var scrollToIndexPathOnKeyboardShow: IndexPath? {
//        return IndexPath(row: 0, section: 1)
//    }
    
    static let cellIdentifier = "DetailMedicalCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setUpContent()
        setUpNavigationBar()
        //hideKeyboardWhenTappedAround()
        
    }
    func setUpNavigationBar() {
        title = presenter.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editMedicalClicked))
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.largeTitleDisplayMode = .never
    }
    
    @objc func editMedicalClicked() {
        presenter.editButtonClicked()
    }
    
    func setUpContent() {
        
        view.add(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(FormLabel.self, forCellReuseIdentifier: FormLabel.identifier)
        tableView.register(TextViewTableViewCell.self, forCellReuseIdentifier: TextViewTableViewCell.identifier)
        tableView.register(EditNoteTableHeaderView.self, forHeaderFooterViewReuseIdentifier: EditNoteTableHeaderView.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: DetailMedicalViewController.cellIdentifier)
        tableView.register(ImagePreviewTableViewCell.self, forCellReuseIdentifier: ImagePreviewTableViewCell.identifier)
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
        tableView.register(DonutChartCell.self, forCellReuseIdentifier: DonutChartCell.identifier)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

}

extension DetailMedicalViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSection()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfSectionRows(at: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.getTitle(for: section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let field = presenter.section(at: indexPath)
        switch field {
        case .info, .medicalItem:
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
        
        switch field {
        case .image(let filePath):
            let newCell = tableView.dequeueReusableCell(withIdentifier: ImagePreviewTableViewCell.identifier, for: indexPath) as! ImagePreviewTableViewCell
            newCell.configure(with: filePath)
            newCell.onShow = { [weak self] in
                guard let self = self else {return}
                    self.previewUrl = URL(fileURLWithPath: filePath)
                    presenter.viewDocument()
                }
            
            cell = newCell
        case .info(let section):
            if section.title == "button" {
                let newCell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath) as! ButtonTableViewCell
                newCell.configure(title: section.value)
                newCell.onButtonClicked = { [weak self] in
                    self?.presenter.exportDocumentClicked()
                }
                newCell.backgroundColor = .secondarySystemBackground
                cell = newCell

            } else {
                let newCell = tableView.dequeueReusableCell(withIdentifier: FormLabel.identifier, for: indexPath) as! FormLabel
                newCell.configure(title: section.title, text: section.value)
                cell = newCell

            }
            
        case .notes(let text, let isEditable):
            let newCell = tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.identifier, for: indexPath) as! TextViewTableViewCell
            newCell.configure(text: text, value: isEditable)
            newCell.onValueChange = { [weak self] text in
                self?.presenter.updateNotes(text: text)
            }
            cell = newCell
            
        case .medicalItem(let medicalKind):
            let newCell = tableView.dequeueReusableCell(withIdentifier: DetailMedicalViewController.cellIdentifier, for: indexPath)
            newCell.textLabel?.text = medicalKind.rawValue
            newCell.imageView?.image = UIImage(systemName: medicalKind.image)
            newCell.accessoryType = .disclosureIndicator
            cell = newCell
        case .dashBoard(let segments):
            let newCell = tableView.dequeueReusableCell(withIdentifier: DonutChartCell.identifier, for: indexPath) as! DonutChartCell
            newCell.configure(segments: segments)
            cell = newCell
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRowAt(indexPath: indexPath)
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        switch indexPath.section {
//        case 2:
//            return true
//        default:
//            return false
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let deleteAction = UIContextualAction(style: .normal, title: AppConstantData.edit) { [weak self] _, _, completion in
//            self?.presenter.editMedicalItem(at: indexPath.row)
//            completion(true)
//        }
//        
//        deleteAction.image = UIImage(systemName: IconName.edit)
//        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
//        swipeAction.performsFirstActionWithFullSwipe = true
//        return swipeAction
//
//    }
//    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let deleteAction = UIContextualAction(style: .destructive, title: AppConstantData.delete) { [weak self] _, _, completion in
//            self?.presenter.deleteMedicalItem(at: indexPath.row)
//            completion(true)
//        }
//        
//        deleteAction.image = UIImage(systemName: IconName.trash)
//        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
//        swipeAction.performsFirstActionWithFullSwipe = true
//        return swipeAction
//
//    }


}

extension DetailMedicalViewController: QLPreviewControllerDataSource {
    
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

extension DetailMedicalViewController: DetailMedicalViewDelegate {
    func showAlertToIncludeNotes(completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Notes?", message: "Do you want to include notes?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            completion(true)
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
            completion(false)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { [weak self] _ in
            alert.dismiss(animated: true)
            self?.stopLoading()
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        alert.addAction(cancel)

        present(alert, animated: true)

    }
    
    func updateMedicalNotes(text: String?, id: Int) {
        onUpdateNotes?(text,id)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func updateMedicalRecord(_ medical: Persistable) {
        onEdit?(medical)
    }
    func showLoading() {
        
        let overlay = LoadingOverlayView()
        view.add(overlay)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        loadingOverlay = overlay

    }
    
    func stopLoading() {
        loadingOverlay?.removeFromSuperview()
        loadingOverlay = nil

    }

    
    func reloadSection(at section: Int) {
//        let rowCount = tableView.numberOfRows(inSection: section)
//
//        let indexPaths = (0..<rowCount).map {
//            IndexPath(row: $0, section: section)
//        }
//
//        tableView.reloadRows(at: indexPaths, with: .automatic)

        tableView.reloadSections([section], with: .automatic)
    }
    
}

extension DetailMedicalViewController: DocumentNavigationDelegate {
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true)
    }
    
    func push(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
