//
//  ListMedicalItemViewController.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
import UIKit

class ListMedicalItemViewController: UIViewController {
    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.contentInsetAdjustmentBehavior = .automatic
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 100
        return view
    }()

    //let searchController = UISearchController(searchResultsController: nil)
    var presenter: ListMedicalItemPresenterProtocol!

    let identifier = "ListMedicalItemTabelViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        presenter.viewDidLoad()
        setUpNavigationBar()
        setUpContents()

    }
    
    func setUpNavigationBar() {
        title = presenter.title
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
    }
    
    
    func setUpContents() {
        
        view.backgroundColor = AppColor.background
        view.add(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)

        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor,constant: PaddingSize.height),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    @objc func addButtonClicked() {
        presenter.gotoAddMedicalItemScreen()
    }

}


extension ListMedicalItemViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let medical = presenter.medicalItem(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        cell.textLabel?.text = "Take \(medical.kind.rawValue) for \(medical.duration) \(medical.durationType.rawValue) Dosage: \(medical.dosage) on \(medical.instruction.value)"
        cell.detailTextLabel?.text = "Name \(medical.name) At \(medical.shedule.dbValue)"
        //cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell

    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: AppConstantData.edit) { [weak self] _, _, completion in
            self?.presenter.editMedicalItem(at: indexPath.row)
            completion(true)
        }
        
        editAction.image = UIImage(systemName: IconName.edit)
        let swipeAction = UISwipeActionsConfiguration(actions: [editAction])
        swipeAction.performsFirstActionWithFullSwipe = true
        return swipeAction

    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: AppConstantData.delete) { [weak self] _, _, completion in
            self?.presenter.deleteMedicalItem(at: indexPath.row)
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: IconName.trash)
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = true
        return swipeAction
    }
}


extension ListMedicalItemViewController: ListMedicalItemViewDelegate {
    func reloadData() {
        tableView.reloadData()
    }
    
    func refreshSortMenu() {
        
    }
    
    
}

extension ListMedicalItemViewController: DocumentNavigationDelegate {
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true)
    }
    
    func push(_ vc: UIViewController) {
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
