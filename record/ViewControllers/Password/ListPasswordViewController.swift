//
//  ListPasswordViewController.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

import UIKit

class ListPasswordViewController: KeyboardNotificationViewController {
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInsetAdjustmentBehavior = .automatic
        return tableView
        
    }()
    let maxCount = 30
    override var keyboardScrollableView: UIScrollView? {
        return tableView
    }
    var selectButton: UIBarButtonItem!
    private let selectionToolbar = SelectionToolbarView()

    let timerLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.body
        label.backgroundColor = AppColor.primaryColor
        label.labelSetUp()
        return label
    }()
    
    let sortView: SortHeaderView = {
        let view = SortHeaderView()
        view.button.configuration?.title = "Options"
        view.setTimerViewHidden(false)
        view.button.configuration?.image = nil
        return view
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var presenter: ListPasswordProtocol!
    var collectionBottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        tableView.backgroundColor = AppColor.background
        setUpNavigationBar()
        presenter.viewDidLoad()
        setUpContents()
    }
        
    func setUpNavigationBar() {
        title = "Password Manager"
        navigationController?.navigationBar.isTranslucent = false
        selectButton =  UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectButtonClicked))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        
        let spacer = UIBarButtonItem(
            barButtonSystemItem: .fixedSpace,
            target: nil,
            action: nil
        )
        spacer.width = 12

        navigationItem.rightBarButtonItems = [selectButton,addButton]
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: IconName.cancel), style: AppConstantData.buttonStyle, target: self, action: #selector(exitClicked))
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        //searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.searchBarStyle = .minimal
        //searchController.searchBar.backgroundImage = UIImage()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    func clearSelectedRow() {
        for indexPath in tableView.indexPathsForSelectedRows ?? [] {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func setUpContents() {
        view.add(tableView)
        view.add(sortView)
        selectionToolbar.configure(total: presenter.total, selected: presenter.selectedIndexes.count)

        tableView.dataSource = self
        tableView.delegate = self
        collectionBottomConstraint = tableView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: -PaddingSize.height
        )

        tableView.register(ListPasswordCell.self, forCellReuseIdentifier: ListPasswordCell.identifier)
        view.add(selectionToolbar)
        selectionToolbar.isHidden = true

        NSLayoutConstraint.activate([
            selectionToolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: PaddingSize.width * 2),
            selectionToolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -PaddingSize.width * 2),
            selectionToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -PaddingSize.height),
            selectionToolbar.heightAnchor.constraint(equalToConstant: 72),
        ])

        NSLayoutConstraint.activate([
            sortView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: PaddingSize.height),
            sortView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: PaddingSize.width * 2 ),
            sortView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -PaddingSize.width),

            tableView.topAnchor.constraint(equalTo: sortView.bottomAnchor, constant: PaddingSize.height),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionBottomConstraint
        ])

    }
    @objc func selectButtonClicked() {
        presenter.isSelectionMode.toggle()
        
        if presenter.isSelectionMode {
            //searchButton.isEnabled = false
            navigationItem.rightBarButtonItems?.first?.title = "Cancel"
            tableView.allowsMultipleSelection = true
            searchController.isActive = false
            searchController.searchBar.isHidden = true
            navigationItem.searchController = nil
            showBottomToolbar()
        } else {
            navigationItem.rightBarButtonItems?.first?.title = "Select"
            //searchButton.isEnabled = true
            tableView.allowsMultipleSelection = false
            presenter.clearSelection()
            hideBottomToolbar()
            searchController.isActive = true
            searchController.searchBar.isHidden = false
            navigationItem.searchController = searchController
            clearSelectedRow()
            tableView.reloadData()
        }

    }
    func showBottomToolbar() {
        updateToolbar()
        tabBarController?.tabBar.isHidden = true
        selectionToolbar.show(in: view, bottomConstraint: collectionBottomConstraint)
    }

    func hideBottomToolbar() {
        
        tabBarController?.tabBar.isHidden = false
        selectionToolbar.hide(in: view, bottomConstraint: collectionBottomConstraint, defaultOffset: -PaddingSize.height)
    }
    func updateToolbar() {
        let state = presenter.selectionState()

        var buttons: [UIButton] = []
        let delete = makeToolbarButton(image: IconName.trash, action: #selector(deleteSelected))


        switch state {
        case .allLocked:
            let unstar = makeToolbarButton(image: IconName.star, action: #selector(unlockSelected))
            buttons.append(unstar)

        case .allUnlocked:
            let star = makeToolbarButton(image: IconName.starFill, action: #selector(lockSelected))
            buttons.append(star)

        case .mixed:
            let unstar = makeToolbarButton(image: IconName.star, action: #selector(lockSelected))
            let star = makeToolbarButton(image: IconName.starFill, action: #selector(unlockSelected))
            buttons.append(unstar)
            buttons.append(star)

        case .none:
            break
        }

        buttons.append(delete)
        selectionToolbar.setButtons(buttons)
    }
    func makeToolbarButton(image: String, action: Selector) -> UIButton {
        var config = UIButton.Configuration.clearGlass()
        config.image = UIImage(systemName: image)
        let button = UIButton(configuration: config)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    @objc func deleteSelected() {
        presenter.deleteMultiple()
    }
    
    @objc func lockSelected() {
        presenter.updateFavouriteForSelected(lock: true)
    }
    
    @objc func unlockSelected() {
        presenter.updateFavouriteForSelected(lock: false)
    }

}

extension ListPasswordViewController {
    
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
            title: "Recent",
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
            self?.presenter.didSelectedFavourite(reset: true)
        }
        let filterMenu = UIMenu(
            title: "Filter",
            options: .displayInline,
            children: [favorite]
        )
        
        let sortMenu = UIMenu(
            title: "Sort By",
            options: .displayInline,
            children: [name, created, updated]
        )

        
        sortView.configure(text: current.field.rawValue)
//        DispatchQueue.main.async { [weak self] in
            sortView.button.menu = UIMenu(
                title: "",
                children: [filterMenu, sortMenu]
            )

//        }
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
        let isSelected = presenter.selectedIndexes.contains(password.id)

        cell.configure(password.title, password.username, isFavourite: password.isFavorite)
        cell.setSelectedState(isSelected, isSelectionMode: presenter.isSelectionMode)

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
            self?.presenter.deleteClicked(at: indexPath.row)
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
        if presenter.isSelectionMode {
            presenter.toggleSelection(at: indexPath.row)
            tableView.reloadData()
            selectionToolbar.configure(total: presenter.total, selected: presenter.selectedIndexes.count)
            updateToolbar()
        } else {
            presenter.didSelectedRow(at: indexPath.row)
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard presenter.isSelectionMode else { return }
        presenter.toggleSelection(at: indexPath.row)
        tableView.reloadData()
        selectionToolbar.configure(total: presenter.total, selected: presenter.selectedIndexes.count)

        updateToolbar()

    }
}

extension ListPasswordViewController: ListPasswordViewDelegate {
    
    func exitSelectionMode() {
        presenter.isSelectionMode = false
        navigationItem.rightBarButtonItems?.first?.title = "Cancel"
        tableView.allowsMultipleSelection = false
        presenter.clearSelection()
        hideBottomToolbar()
        clearSelectedRow()
        tableView.reloadData()
        searchController.isActive = true
        searchController.searchBar.isHidden = false
        navigationItem.searchController = searchController

    }
    
    func showToastVC(message: String, type: ToastType) {
        showToast(message: message, type: type)
    }
    
    func refreshSortMenu() {
        buildSortMenu()
    }
    func showAlertOnDelete(at index: Int) {
        let alert = UIAlertController(
            title: "Delete?",
            message: "Are you sure you want to delete?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.presenter.deletePassword(index: index)
        })
        present(alert, animated: true)
    }
    func showAlertOnDelete(_ passwords: [Password]) {
        let alert = UIAlertController(
            title: "Delete?",
            message: "Are you sure you want to delete \(passwords.count) items?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            for password in passwords {
                self?.presenter.deletePassword(password)
            }
            self?.presenter.loadPasswords()
            self?.exitSelectionMode()
        })
        present(alert, animated: true)
    }

    func reloadData() {
        tableView.reloadData()
        let isEmpty = presenter.isEmpty
        let isSearching = presenter.isSearching
        sortView.isHidden = isSearching && isEmpty
        if isEmpty {
            if !isSearching {
                tableView.setEmptyView(image: "key.slash", title: "No Passwords", subtitle: "Tap + on top to create your first password.")
            } else {
                tableView.setHeaderEmptyView(image: "key.slash", title: "No Matching Password Found", subtitle: "Search with Password title or user name")
            }
        } else {
            tableView.restoreView()
        }

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
        PasswordSessionManager.shared.isAutoExitAlertShowing = true
        let title = expired ? "Session Expired" : "Exit Passwords?"
        var message = expired ? "Do you want to stay for another \(AppConstantData.passwordSession / 60) minutes?" :  "Are you sure want to exit?"
        message += " Auto Exit in \(AppConstantData.autoExitTime) seconds"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Stay", style: .default) { [weak self] _ in
            PasswordSessionManager.shared.isAutoExitAlertShowing = false
            if expired {
                self?.presenter.extendSession()
            } else {
                self?.presenter.stopAutoExitTimer()
            }
            
        })

        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { [weak self] _ in
            PasswordSessionManager.shared.isAutoExitAlertShowing = false
            self?.presenter.exitPassoword()
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
        guard var text = searchController.searchBar.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) else { return }

        if text.count > maxCount {
            let endIndex = text.index(text.startIndex, offsetBy: maxCount)
            text = String(text[..<endIndex])
            searchController.searchBar.text = text

            showToast(message: "Enter maximum of \(maxCount) characters", type: .warning)
            return
        }

        presenter.search(text: text)
    }
    
}
