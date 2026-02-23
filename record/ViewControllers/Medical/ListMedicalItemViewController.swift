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
    
    let categorySelector: CategorySelectorView =  {
        let view = CategorySelectorView(frame: .zero, options: MedicalSchedule.getList(), images: MedicalSchedule.getImage())
        return view
    }()

    
    var presenter: ListMedicalItemPresenterProtocol!

    let identifier = "ListMedicalItemTabelViewCell"
    
    let dateNavigator = DateNavigatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        setUpNavigationBar()
        setUpContents()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewDidLoad()
    }

    
    func setUpNavigationBar() {
        title = presenter.title
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
    }
    
    
    func setUpContents() {
        
        view.backgroundColor = AppColor.background
        view.add(tableView)
        view.add(dateNavigator)
        view.add(categorySelector)
        tableView.dataSource = self
        tableView.delegate = self
        
        dateNavigator.delegate = self
        dateNavigator.minimumDate = presenter.startDate
        dateNavigator.maximumDate = Date()
        
        categorySelector.onSelect = { [weak self] text in
            self?.presenter.didSelectCategory(text)
        }
        
        tableView.register(ListMedicalItemViewCell.self, forCellReuseIdentifier: ListMedicalItemViewCell.identifier)
        
        NSLayoutConstraint.activate([
            dateNavigator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: PaddingSize.height),
            dateNavigator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PaddingSize.width),
            dateNavigator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PaddingSize.width),
            
            categorySelector.topAnchor.constraint(equalTo: dateNavigator.bottomAnchor, constant: PaddingSize.height),
            categorySelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PaddingSize.width),
            categorySelector.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PaddingSize.width),
            
            tableView.topAnchor.constraint(equalTo: categorySelector.bottomAnchor,constant: PaddingSize.height),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    @objc func addButtonClicked() {
        presenter.gotoAddMedicalItemScreen()
    }

}


extension ListMedicalItemViewController: DateNavigatorViewDelegate {
    func dateNavigator(_ navigator: DateNavigatorView, didChange date: Date) {
        presenter.changeSelectedDate(date)
    }
    
    func dateNavigatorRequestedPicker(_ navigator: DateNavigatorView, current: Date) {

        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.minimumDate = presenter.startDate
        picker.maximumDate = presenter.endDate < Date() ? presenter.endDate : Date()
        picker.date = current

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
        alert.addAction(UIAlertAction(title: "Select", style: .default) { _ in
            navigator.setDate(picker.date)
        })

        present(alert, animated: true)
    }

    
}

extension ListMedicalItemViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let medical = presenter.medicalItemViewModel(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: ListMedicalItemViewCell.identifier, for: indexPath) as! ListMedicalItemViewCell
        cell.configure(text1: medical.text1, text2: medical.text2, text3: medical.text3, canShow: medical.canShowToggle, state: medical.toggled)
        cell.onToggleChanged = { [weak self] value in
            self?.presenter.itemToggledAt(indexPath.row, value: value)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        presenter.canEdit
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
    
    func showDeleteAlert(index: Int) {
        
        let alert = UIAlertController(
            title: "Delete Medicine",
            message: "• Delete Completely will remove all past and future records.\n\n• Stop From \(presenter.selectedDate.toString()) will keep past history but prevent future doses.",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Delete Completely", style: .destructive) { [weak self] _ in
            self?.presenter.deleteMedicalItem(at: index)
        })
        
        alert.addAction(UIAlertAction(title: "Stop From \(presenter.selectedDate.toString())", style: .default) { [weak self] _ in
            self?.presenter.updateEndDate(at: index)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: AppConstantData.delete) { [weak self] _, _, completion in
            self?.showDeleteAlert(index: indexPath.row)
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
        if presenter.isEmpty {
            tableView.setEmptyView(image: "tray.full", title: "No \(presenter.title)s", subtitle: "Tap + on top to create your first \(presenter.title).")
                
        } else {
            tableView.restoreView()
        }

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
