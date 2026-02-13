//
//  DetailMedicalViewController.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//

import UIKit


class DetailMedicalViewController: KeyboardNotificationViewController {
    
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.separatorStyle = .singleLine
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    var presenter: DetailMedicalPresenterProtocol!
    var onUpdateNotes: ((String?,Int) -> Void)?
    var onEdit: ((Medical) -> Void)?
    
    override var keyboardScrollableView: UIScrollView? {
        return tableView
    }
    
    override var scrollToIndexPathOnKeyboardShow: IndexPath? {
        return IndexPath(row: 0, section: 1)
    }
    
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
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
            
        case .info(let section):
            let newCell = tableView.dequeueReusableCell(withIdentifier: FormLabel.identifier, for: indexPath) as! FormLabel
            newCell.configure(title: section.title, text: section.value)
            cell = newCell
            
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
            newCell.accessoryType = .disclosureIndicator
            //newCell.selectionStyle = .none
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


extension DetailMedicalViewController: DetailMedicalViewDelegate {
    func updateMedicalNotes(text: String?, id: Int) {
        onUpdateNotes?(text,id)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func updateMedicalRecord(_ medical: Medical) {
        onEdit?(medical)
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
