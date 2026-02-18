//
//  ListBillViewController.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//

import UIKit

class ListBillViewController: UIViewController {
    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.contentInsetAdjustmentBehavior = .automatic
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 100
        return view
    }()

    //let searchController = UISearchController(searchResultsController: nil)
    var presenter: ListBillPresenterProtocol!

    //let identifier = "ListBillTabelViewCell"
    
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
        tableView.register(ListBillViewCell.self, forCellReuseIdentifier: ListBillViewCell.identifier)

        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor,constant: PaddingSize.height),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    @objc func addButtonClicked() {
        presenter.gotoAddBillScreen()
    }

}


extension ListBillViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bill = presenter.billContent(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: ListBillViewCell.identifier) as! ListBillViewCell
        cell.configure(bill.text1, bill.text2,value: bill.value)
        cell.onSwitchValueChanged = { [weak self] in
            self?.presenter.markAsPaidClicked(at: indexPath.row)
        }
        return cell

    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: AppConstantData.edit) { [weak self] _, _, completion in
            self?.presenter.editBill(at: indexPath.row)
            completion(true)
        }
        
        editAction.image = UIImage(systemName: IconName.edit)
        let swipeAction = UISwipeActionsConfiguration(actions: [editAction])
        swipeAction.performsFirstActionWithFullSwipe = true
        return swipeAction

    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: AppConstantData.delete) { [weak self] _, _, completion in
            self?.presenter.deleteBill(at: indexPath.row)
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: IconName.trash)
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = true
        return swipeAction
    }
}


extension ListBillViewController: ListBillViewDelegate {
    func reloadField(at index: Int) {
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func refreshSortMenu() {
        
    }
    func openMarkAsPaidAlert(completion: @escaping (Date) -> Void) {
        let alert = UIAlertController(
            title: "Mark as Paid",
            message: "", // space for date picker
            preferredStyle: .alert
        )
        
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 50, width: 270, height: 150))
        
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .compact
        }
        
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.date = Date()
        
        alert.view.addSubview(datePicker)
        
        let todayAction = UIAlertAction(title: "Today", style: .default) { _ in
            completion(Date())
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            completion(datePicker.date)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self]_ in
            self?.reloadData()
            alert.dismiss(animated: true)
        }
        
        alert.addAction(todayAction)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)

    }
    
    
}

extension ListBillViewController: DocumentNavigationDelegate {
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true)
    }
    
    func push(_ vc: UIViewController) {
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
