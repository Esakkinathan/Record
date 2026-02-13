//
//  DetailUtilityAccountViewController.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//
import UIKit

class DetailUtilityAccountViewController: KeyboardNotificationViewController {
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.separatorStyle = .singleLine
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    var presenter: DetailUtilityAccountPresenterProtocol!
    var onUpdateNotes: ((String?,Int) -> Void)?
    var onEdit: ((UtilityAccount) -> Void)?
    
    override var keyboardScrollableView: UIScrollView? {
        return tableView
    }
    
    override var scrollToIndexPathOnKeyboardShow: IndexPath? {
        return IndexPath(row: 0, section: 1)
    }
    
    static let cellIdentifier = "DetailUtilityAccountCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setUpContent()
        setUpNavigationBar()
        //hideKeyboardWhenTappedAround()
        
    }

    func setUpNavigationBar() {
        title = presenter.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editUtilityAccountClicked))
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    @objc func editUtilityAccountClicked() {
        presenter.editButtonClicked()
    }
    
    func setUpContent() {
        
        view.add(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(FormLabel.self, forCellReuseIdentifier: FormLabel.identifier)
        tableView.register(TextViewTableViewCell.self, forCellReuseIdentifier: TextViewTableViewCell.identifier)
        tableView.register(EditNoteTableHeaderView.self, forHeaderFooterViewReuseIdentifier: EditNoteTableHeaderView.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: DetailUtilityAccountViewController.cellIdentifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
}

extension DetailUtilityAccountViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        case .notes(_, _):
            return 300
        default:
            return UITableView.automaticDimension
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
            
        case .bill(let type):
            let newCell = tableView.dequeueReusableCell(withIdentifier: DetailUtilityAccountViewController.cellIdentifier, for: indexPath)
            newCell.textLabel?.text = type.rawValue
            newCell.accessoryType = .disclosureIndicator
            //newCell.selectionStyle = .none
            cell = newCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRowAt(indexPath: indexPath)
    }
    
}

extension DetailUtilityAccountViewController: DetailUtilityAccountViewDelegate {
    
    func updateUtilityAccountNotes(text: String?, id: Int) {
        onUpdateNotes?(text,id)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func updateUtilityAccountRecord(_ UtilityAccount: UtilityAccount) {
        onEdit?(UtilityAccount)
    }
    
    func reloadSection(at section: Int) {
        tableView.reloadSections([section], with: .automatic)
    }
    
}

extension DetailUtilityAccountViewController: DocumentNavigationDelegate {
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true)
    }
    
    func push(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
