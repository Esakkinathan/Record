//
//  ListDocumentViewController.swift
//  record
//
//  Created by Esakkinathan B on 25/01/26.
//
import UIKit

class ListDocumentViewController: UIViewController {
    
    let tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentInsetAdjustmentBehavior = .automatic
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 100
        return view
    }()
    
    let sortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: IconName.threeDot), for: .normal)
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    var presenter: ListDocumentProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setUpNavigationBar()
        setUpContents()
        //showToast(message: "Hello screen is opened", type: .warning,duration: 5)
    }
    
    func setUpNavigationBar() {
        title = DocumentConstantData.document
        navigationController?.navigationBar.isTranslucent = false
        let searchButton = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(openSearch)
        )
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openAddDocumentView))
        
        let spacer = UIBarButtonItem(
            barButtonSystemItem: .fixedSpace,
            target: nil,
            action: nil
        )
        spacer.width = 12

        navigationItem.rightBarButtonItems = [addButton, spacer, searchButton, spacer, UIBarButtonItem(customView: sortButton)]

        
        searchController.searchResultsUpdater = self
        //searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = DocumentConstantData.searchDocument
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.delegate = self
        
        definesPresentationContext = true
    }
    
    @objc func openSearch() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }

    func setUpContents() {
        
        view.backgroundColor = AppColor.background
        view.add(tableView)
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(ListDocumentTableViewCell.self, forCellReuseIdentifier: ListDocumentTableViewCell.identifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor,constant: PaddingSize.height),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc func openAddDocumentView() {
        presenter.gotoAddDocumentScreen()
    }
    
    func buildSortMenu() {
        let current = presenter.currentSort

        func subtitle(
            field: DocumentSortField,
            asc: String,
            desc: String
        ) -> String {
            guard current.field == field else { return asc }
            return current.direction == .ascending ? asc : desc
        }

        let name = UIAction(
            title: "Name",
            subtitle: subtitle(
                field: .name,
                asc: "Ascending",
                desc: "Descending"
            ),
            state: current.field == .name ? .on : .off
        ) { [weak self] _ in
            self?.presenter.didSelectSortField(.name)
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

        let expiry = UIAction(
            title: "Expiry Date",
            subtitle: subtitle(
                field: .expiryDate,
                asc: "Newest to Oldest",
                desc: "Oldest to Newest"
            ),
            state: current.field == .expiryDate ? .on : .off
        ) { [weak self] _ in
            self?.presenter.didSelectSortField(.expiryDate)
        }

        sortButton.menu = UIMenu(
            title: "Sort By",
            children: [name, created, updated, expiry]
        )
    }

    
}

extension ListDocumentViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let document = presenter.document(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: ListDocumentTableViewCell.identifier, for: indexPath) as! ListDocumentTableViewCell
        cell.configure(document: document)
        cell.onShareButtonClicked = { [weak self] in
            self?.shareButtonClicked(indexPath)
            //self?.presenter.shareDocument(at: indexPath.row)
        }

        return cell
    }
    
    @objc func shareButtonClicked(_ indexPath: IndexPath) {
        
        let alert = UIAlertController(
            title: "Share Document",
            message: "How would you like to share?",
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "Without Lock", style: .default) { [weak self]_ in
            self?.presenter.shareDocument(at: indexPath.row)
        })

        alert.addAction(UIAlertAction(title: "With Lock", style: .default) { [weak self] _ in
            self?.askForPasswordAndShare(at: indexPath.row)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)

    }
    
    func askForPasswordAndShare(at index: Int) {
        let alert = UIAlertController(
            title: "Set Password",
            message: "Enter a password to protect the document",
            preferredStyle: .alert
        )

        alert.addTextField {
            $0.placeholder = "Password"
            $0.isSecureTextEntry = true
        }

        alert.addTextField {
            $0.placeholder = "Confirm Password"
            $0.isSecureTextEntry = true
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Share", style: .default) { [weak self]_ in
            let password = alert.textFields?[0].text ?? ""
            let confirm = alert.textFields?[1].text ?? ""

            guard !password.isEmpty, password == confirm else {
                return
            }

            self?.presenter.shareDocumentWithLock(at: index, password: password)
        })

        present(alert, animated: true)

    }
    
}

extension ListDocumentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectedRow(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: AppConstantData.delete) { [weak self] _, _, completion in
            self?.presenter.deleteDocument(at: indexPath.row)
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: IconName.trash)
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = true
        return swipeAction
    }

}
extension ListDocumentViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        presenter.search(text: searchController.searchBar.text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationItem.searchController = nil
    }
}

extension ListDocumentViewController: DocumentNavigationDelegate {
    
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true)
    }
    
    func push(_ vc: UIViewController) {
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension ListDocumentViewController: ListDocumentViewDelegate {
    func reloadData() {
        tableView.reloadData()
    }
    func refreshSortMenu() {
        buildSortMenu()
    }
}
