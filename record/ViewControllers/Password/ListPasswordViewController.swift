//
//  ListPasswordViewController.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

import UIKit

class ListPasswordViewController: UIViewController {
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
        
    }()
    
    let timerLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.body
        label.backgroundColor = AppColor.primaryColor
        label.labelSetUp()
        return label
    }()
    
    let sortView = SortHeaderView()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var presenter: ListPasswordProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        tableView.backgroundColor = AppColor.background
        presenter.viewDidLoad()
        setUpNavigationBar()
        setUpContents()
    }
    
    func setUpNavigationBar() {
        title = "Password Manager"
        navigationController?.navigationBar.isTranslucent = false
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        
        let spacer = UIBarButtonItem(
            barButtonSystemItem: .fixedSpace,
            target: nil,
            action: nil
        )
        spacer.width = 12

        navigationItem.rightBarButtonItem = addButton
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: IconName.cancel), style: AppConstantData.buttonStyle, target: self, action: #selector(exitClicked))
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = DocumentConstantData.searchDocument
        searchController.searchBar.searchBarStyle = .minimal
        //searchController.searchBar.backgroundImage = UIImage()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

    }
        
    func setUpContents() {
        view.add(tableView)
        view.add(sortView)
        
        sortView.timerLabel.isHidden = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(ListPasswordCell.self, forCellReuseIdentifier: ListPasswordCell.identifier)
        
        NSLayoutConstraint.activate([
//            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: PaddingSize.height),
//            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sortView.topAnchor.constraint(equalTo: view.topAnchor,constant: PaddingSize.height),
            sortView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PaddingSize.width * 2 ),
            sortView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PaddingSize.content),

            tableView.topAnchor.constraint(equalTo: sortView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

    }

}

extension ListPasswordViewController {
    
//    @objc func openSearch() {
//
//        DispatchQueue.main.async {
//            self.searchController.searchBar.becomeFirstResponder()
//        }
//
//    }

    @objc func addButtonClicked() {
        presenter.gotoAddPasswordScreen()
    }
    
    @objc func exitClicked() {
        presenter.exitClicked()
    }
    
    func buildSortMenu() {
        let current = presenter.currentSort

        func subtitle(
            field: PasswordSortField,
            asc: String,
            desc: String
        ) -> String {
            guard current.field == field else { return asc }
            return current.direction == .ascending ? asc : desc
        }

        let name = UIAction(
            title: "Title",
            subtitle: subtitle(
                field: .title,
                asc: "Ascending",
                desc: "Descending"
            ),
            state: current.field == .title ? .on : .off
        ) { [weak self] _ in
            self?.presenter.didSelectSortField(.title)
        }

        let created = UIAction(
            title: "Created At",
            subtitle: subtitle(
                field: .createdAt,
                asc: "Newest to Oldest",
                desc: "Oldest to Newest"
            ),
            state: current.field == .createdAt ? .on : .off
        ) { [weak self] _ in
            self?.presenter.didSelectSortField(.createdAt)
        }

        let updated = UIAction(
            title: "Updated At",
            subtitle: subtitle(
                field: .updatedAt,
                asc: "Newest to Oldest",
                desc: "Oldest to Newest"
            ),
            state: current.field == .updatedAt ? .on : .off
        ) { [weak self] _ in
            self?.presenter.didSelectSortField(.updatedAt)
        }

        let favorite = UIAction(
            title: "Favourite",
            state: presenter.isFavoriteSelected ? .on : .off
        ) { [weak self] _ in
            self?.presenter.didSelectedFavourite()
        }
        sortView.configure(text: current.field.rawValue, iconName: current.direction == .ascending ? IconName.arrowUp : IconName.arrowDown)
        sortView.button.menu = UIMenu(
            title: "Sort By",
            children: [name, created, updated, favorite]
        )
    }
    

}

extension ListPasswordViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfPasswords()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let password = presenter.password(at: indexPath.row)
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ListPasswordCell.identifier
        ) as! ListPasswordCell
                
        cell.configure(password.title, password.username, isFavourite: password.isFavorite)
        cell.onFavoriteButtonClicked = { [weak self] in
            self?.presenter.toggleFavorite(password)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: AppConstantData.delete) { [weak self] _, _, completion in
            self?.presenter.deletePassword(index: indexPath.row)
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: IconName.trash)
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = true
        return swipeAction
    }

}

extension ListPasswordViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectedRow(at: indexPath.row)
    }
}

extension ListPasswordViewController: ListPasswordViewDelegate {
    func refreshSortMenu() {
        buildSortMenu()
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    func reloadCellAt(_ indexRow: Int) {
        tableView.reloadRows(at: [IndexPath(row: indexRow, section: 1)], with: .automatic)
    }
    func dismiss() {
        if presentedViewController != nil {
            dismiss(animated: false) { [weak self] in
                self?.navigationController?.dismiss(animated: true)
            }
        } else {
            navigationController?.dismiss(animated: true)
        }
    }
    
    func updateTimer(_ time: String) {
        let fullText = "Auto exit in \(time)"
        let attributed = NSMutableAttributedString(string: fullText)

        // Find range of number part
        if let range = fullText.range(of: time) {
            let nsRange = NSRange(range, in: fullText)
            
            attributed.addAttribute(
                .foregroundColor,
                value: UIColor.red,
                range: nsRange
            )
        }

        sortView.setTimer(text: attributed)
    }
    
    func showExitPrompt(expired: Bool) {

        let title = expired ? "Session Expired" : "Exit Passwords?"
        var message = expired ? "Do you want to stay for another \(AppConstantData.passwordSession / 60) minutes?" :  "Are you sure want to exit?"
        message += " Auto Exit in \(AppConstantData.autoExitTime) secoonds"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { [weak self] _ in
            self?.presenter.exitPassoword()
        })

        alert.addAction(UIAlertAction(title: "Stay", style: .default) { [weak self] _ in
            if expired {
                self?.presenter.extendSession()
            }
            
        })

        present(alert, animated: true)
    }
    
}

extension ListPasswordViewController: DocumentNavigationDelegate {
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true)
    }
    
    func push(_ vc: UIViewController) {
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ListPasswordViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return}
        presenter.search(text: text)
    }
    
}
