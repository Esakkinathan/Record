//
//  ListMedicalViewController.swift
//  record
//
//  Created by Esakkinathan B on 08/02/26.
//
import UIKit

class ListMedicalViewController: CustomSearchBarController {
    
    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.contentInsetAdjustmentBehavior = .automatic
        view.rowHeight = UITableView.automaticDimension
        view.backgroundColor = AppColor.background
        view.estimatedRowHeight = 100
        return view
    }()
    private let selectionToolbar = SelectionToolbarView()

    var selectButton: UIBarButtonItem!

    let overview = OverviewCard()
    let categorySelector: CategorySelectorView =  {
        let view = CategorySelectorView(frame: .zero, options: MedicalType.getList(), images: MedicalType.getImage())
        return view
    }()
    let sortView = SortHeaderView()

    var presenter: ListMedicalPresenterProtocol!
    var collectionBottomConstraint: NSLayoutConstraint!

    let identifier = "ListMedicalTabelViewCell"
    var searchButton: UIBarButtonItem!

    private let dashboardContainer = UIView()
    private var dashboardHeightConstraint: NSLayoutConstraint!

    // Cached natural height of the dashboard card
    private var dashboardNaturalHeight: CGFloat = 0
    private let headerWrapper = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        
        setUpNavigationBar()
        setUpContents()
        setupTableHeader()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewDidLoad()
        //let summary = presenter.getActiveSummary()
        presenter.dateChangedForOverview(date: nil)
//        overview.infoCardView.configure(dashboard: summary,icon: UIImage(systemName: "list.clipboard.fill"), subtitle: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none,), iconTint: SettingsManager.shared.accent.color)
        categorySelector.applyTint()
        //activeTreatementView.configure(section: summary.row2)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    func setUpNavigationBar() {
        title = presenter.title
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        selectButton =  UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectButtonClicked))

        let spacer = UIBarButtonItem(
            barButtonSystemItem: .fixedSpace,
            target: nil,
            action: nil
        )
        
        spacer.width = 12
        
        searchButton = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(openSearch)
        )


        navigationController?.navigationBar.isTranslucent = false
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItems = [addButton, spacer, searchButton]
        navigationItem.leftBarButtonItem = selectButton
    }
    
    
    func setUpContents() {
        view.add(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        selectionToolbar.configure(total: presenter.total, selected: presenter.selectedIndexes.count)
        
        categorySelector.onSelect = { [weak self] text in
            self?.presenter.didSelectCategory(text)
        }
        overview.dateNavigator.delegate = self
        overview.infoCardView.onBadgeTapped = { [weak self] rowModel, segment in
            guard let self else { return }
            
            let popup = MedicinePopupViewController(
                scheduleName: rowModel.schedule.rawValue,
                segment: segment,
                rowModel: rowModel
            )
            //popup.modalPresentationStyle = .
            self.present(popup, animated: true)
        }
        view.add(selectionToolbar)
        selectionToolbar.isHidden = true

        NSLayoutConstraint.activate([
            selectionToolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: PaddingSize.width * 2),
            selectionToolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -PaddingSize.width * 2),
            selectionToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -PaddingSize.height),
            selectionToolbar.heightAnchor.constraint(equalToConstant: 72),
        ])
        collectionBottomConstraint = tableView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: -PaddingSize.height
        )

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: PaddingSize.height),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionBottomConstraint
        ])
    }
    private var dashboardTopConstraint: NSLayoutConstraint?

    private func setupTableHeader() {
        let padding = PaddingSize.width

        dashboardContainer.clipsToBounds = true
        if overview.superview == nil {
            dashboardContainer.add(overview)
            NSLayoutConstraint.activate([
                overview.topAnchor.constraint(equalTo: dashboardContainer.topAnchor),
                overview.leadingAnchor.constraint(equalTo: dashboardContainer.leadingAnchor),
                overview.trailingAnchor.constraint(equalTo: dashboardContainer.trailingAnchor),
                overview.bottomAnchor.constraint(equalTo: dashboardContainer.bottomAnchor)
            ])
        }

        if dashboardHeightConstraint == nil {
            dashboardHeightConstraint = dashboardContainer.heightAnchor.constraint(equalToConstant: 0)
        }

        headerWrapper.subviews.forEach { $0.removeFromSuperview() }

        let headerStack = UIStackView(arrangedSubviews: [
            dashboardContainer,
            categorySelector,
            sortView
        ])
        headerStack.axis = .vertical
        headerStack.spacing = PaddingSize.height

        headerWrapper.add(headerStack)
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: headerWrapper.topAnchor, constant: PaddingSize.height),
            headerStack.leadingAnchor.constraint(equalTo: headerWrapper.leadingAnchor, constant: padding),
            headerStack.trailingAnchor.constraint(equalTo: headerWrapper.trailingAnchor, constant: -padding),
            headerStack.bottomAnchor.constraint(equalTo: headerWrapper.bottomAnchor, constant: -PaddingSize.height)
        ])

        tableView.tableHeaderView = headerWrapper
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard tableView.window != nil else { return }
        guard let header = tableView.tableHeaderView else { return }

        header.frame.size.width = tableView.bounds.width
        let fittedHeight = header.systemLayoutSizeFitting(
            CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        if abs(header.frame.size.height - fittedHeight) > 1 {
            header.frame.size.height = fittedHeight
            tableView.tableHeaderView = header
        }
    }

    private func invalidateHeaderLayout() {
        guard let header = tableView.tableHeaderView else { return }
        header.frame.size.width = tableView.bounds.width
        let fittedHeight = header.systemLayoutSizeFitting(
            CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        header.frame.size.height = fittedHeight
        tableView.tableHeaderView = header
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    func collapseDashboard() {
        headerWrapper.layoutIfNeeded()
        dashboardNaturalHeight = dashboardContainer.bounds.height

        guard dashboardNaturalHeight > 0 else { return }

        dashboardHeightConstraint.constant = dashboardNaturalHeight
        dashboardHeightConstraint.isActive = true
        headerWrapper.layoutIfNeeded()

        dashboardHeightConstraint.constant = 0

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.overview.alpha = 0
            self.headerWrapper.layoutIfNeeded()
            self.invalidateHeaderLayout()
        }
    }

    func expandDashboard() {
        guard dashboardHeightConstraint.isActive else { return }  // already expanded
        dashboardHeightConstraint.isActive = false

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.overview.alpha = 1
            self.headerWrapper.layoutIfNeeded()
            self.invalidateHeaderLayout()
        } 
    }
    
    @objc func openSearch() {
        showSearch()
    }

    @objc func addButtonClicked() {
        presenter.gotoAddMedicalScreen()
    }
    override var searchScrollingView: UIScrollView? {
        return tableView
    }

    override func performSearch(text: String?) {
        let enteredText = text?.trimmingCharacters(in: .whitespacesAndNewlines)
        presenter.search(text: enteredText)
    }
    override func searchDidShow() {
        searchButton.isEnabled = false
        selectButton.isEnabled = false
        collapseDashboard()
    }
    override func searchDidHide() {
        searchButton.isEnabled = true
        selectButton.isEnabled = true

        expandDashboard()
    }

}

extension ListMedicalViewController {
    @objc func selectButtonClicked() {
        presenter.isSelectionMode.toggle()
        
        if presenter.isSelectionMode {
            searchButton.isEnabled = false
            navigationItem.leftBarButtonItem?.title = "Cancel"
            tableView.allowsMultipleSelection = true
            showBottomToolbar()
            tableView.reloadData()
        } else {
            navigationItem.leftBarButtonItem?.title = "Select"
            searchButton.isEnabled = true
            tableView.allowsMultipleSelection = false
            presenter.clearSelection()
            hideBottomToolbar()
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

        var buttons: [UIButton] = []
        let delete = makeToolbarButton(image: IconName.trash, action: #selector(deleteSelected))

        buttons.append(delete)

        selectionToolbar.setButtons(buttons)
    }
    @objc func deleteSelected() {
        presenter.deleteMultiple()
    }
    func makeToolbarButton(image: String, action: Selector) -> UIButton {
        var config = UIButton.Configuration.clearGlass()
        config.image = UIImage(systemName: image)
        let button = UIButton(configuration: config)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }



}

extension ListMedicalViewController: UITableViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if position > contentHeight - frameHeight - 100 {
            presenter.loadMedical(reset: false)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let medical = presenter.medical(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        let isSelected = presenter.selectedIndexes.contains(medical.id)

        cell.textLabel?.text = medical.title
        cell.detailTextLabel?.text = "From \(medical.date.toString())"
        if presenter.isSelectionMode {
            if isSelected {
                cell.accessoryType = .checkmark
                cell.backgroundColor = AppColor.primaryColor.withAlphaComponent(0.3)
            } else {
                cell.accessoryType = .none
                cell.backgroundColor = .secondarySystemBackground
            }

        } else {
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = .secondarySystemBackground

        }
        //cell.backgroundColor = .secondarySystemBackground
        cell.selectionStyle = .none
        cell.imageView?.image = UIImage(systemName: medical.type.image)
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
    func clearSelectedRow() {
        for indexPath in tableView.indexPathsForSelectedRows ?? [] {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

}

extension ListMedicalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if presenter.isSelectionMode {
            presenter.toggleSelection(at: indexPath.row)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            selectionToolbar.configure(total: presenter.total, selected: presenter.selectedIndexes.count)

            updateToolbar()
        } else {
            presenter.didSelectedRow(at: indexPath.row)
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        presenter.toggleSelection(at: indexPath.row)
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        selectionToolbar.configure(total: presenter.total, selected: presenter.selectedIndexes.count)

        updateToolbar()

    }

}

extension ListMedicalViewController: ListMedicalViewDelegate {
    func reloadSumary() {
        presenter.dateChangedForOverview(date: nil)
    }
    func exitSelectionMode() {
        presenter.isSelectionMode = false
        navigationItem.leftBarButtonItem?.title = "Select"
        searchButton.isEnabled = true
        tableView.allowsMultipleSelection = false
        hideBottomToolbar()
        clearSelectedRow()
        presenter.clearSelection()
        tableView.reloadData()

    }

    func showOverviewSummary(data: DashboardViewModel, date: Date) {
        print("at configuration stage")
        overview.infoCardView.configure(dashboard: data, icon: UIImage(systemName: "list.clipboard.fill"), subtitle: date.toString(), iconTint: SettingsManager.shared.accent.color)
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
            self?.presenter.deleteMedical(at: index )
        })
        present(alert, animated: true)
    }
    func showAlertOnDelete(_ medicals: [Medical]) {
        let alert = UIAlertController(
            title: "Delete?",
            message: "Are you sure you want to delete \(medicals.count) items?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            for medical in medicals {
                self?.presenter.deleteMedical(medical)
            }
            self?.presenter.loadMedical(reset: true)
            self?.exitSelectionMode()

            //self?.presenter.deleteMedical(at: index )
        })
        present(alert, animated: true)
    }

    func reloadData() {
        tableView.reloadData()
        let isEmpty = presenter.isEmpty
        let isSearching = presenter.isSearching

        if isSearching && isEmpty {
            tableView.tableHeaderView = nil
        } else if tableView.tableHeaderView == nil {
            setupTableHeader()
        }

        if isEmpty {
            if !isSearching {
                tableView.setEmptyFoooterView(
                    image: "tray.full",
                    title: "No Health Records",
                    subtitle: "Tap + on top to create your first Record."
                )
            } else {
                tableView.setHeaderEmptyView(
                    image: "tray.full",
                    title: "No Matching Health Record Found",
                    subtitle: "Search with title, hospital or doctor name"
                )
            }
        } else {
            tableView.restoreFooter()
            setupTableHeader()
        }

    }
    

    /*
    func reloadData() {
        tableView.reloadData()

        let isEmpty = presenter.isEmpty
        let isSearching = presenter.isSearching

        if isSearching && isEmpty {
            headerWrapper.isHidden = true
        } else {
            headerWrapper.isHidden = false
        }

        if isEmpty {
            if !isSearching {
                tableView.setEmptyFoooterView(
                    image: "tray.full",
                    title: "No Health Records",
                    subtitle: "Tap + on top to create your first Record."
                )
            } else {
                tableView.setHeaderEmptyView(
                    image: "tray.full",
                    title: "No Matching Health Record Found",
                    subtitle: "Search with title, hospital and doctor name"
                )
            }
        } else {
            tableView.restoreFooter()
        }
    }
     */
}

extension ListMedicalViewController: DocumentNavigationDelegate {
    func presentVC(_ vc: UIViewController) {
        vc.hidesBottomBarWhenPushed = true
        present(vc, animated: true)
    }
    
    func push(_ vc: UIViewController) {
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ListMedicalViewController {
    func buildSortMenu() {
        let current = presenter.currentSort

        func subtitle(
            field: MedicalSortField,
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
            title: "Diagonsed At",
            subtitle: subtitle(
                field: .createdAt,
                asc: "Oldest to Newest",
                desc: "Newest to Oldest"
            ),
            state: current.field == .createdAt ? .on : .off
        ) { [weak self] _ in
            self?.presenter.didSelectSortField(.createdAt)
        }

        let updated = UIAction(
            title: "Recent",
            subtitle: subtitle(
                field: .updatedAt,
                asc: "Oldest to Newest",
                desc: "Newest to Oldest"
            ),
            state: current.field == .updatedAt ? .on : .off
        ) { [weak self] _ in
            self?.presenter.didSelectSortField(.updatedAt)
        }

        sortView.configure(text: current.field.rawValue)
        sortView.button.menu = UIMenu(
            title: "Sort By",
            children: [name, created, updated]
        )
    }
}
extension ListMedicalViewController: DateNavigatorViewDelegate {
    func dateNavigator(_ navigator: DateNavigatorView, didChange date: Date) {
        print("data change \(date.toString())")
        presenter.dateChangedForOverview(date: date)
    }
    
    func dateNavigatorRequestedPicker(_ navigator: DateNavigatorView, current: Date) {
        let datePickerVC = DatePickerPopoverViewController()
        datePickerVC.modalPresentationStyle = .popover
        datePickerVC.datePicker.minimumDate = AppConstantData.minDate
        datePickerVC.datePicker.date = current
        datePickerVC.datePicker.maximumDate = Date()
        // Done button action
        datePickerVC.onDone = { [weak navigator] date in
            navigator?.setDate(date)
        }

        if let popover = datePickerVC.popoverPresentationController {
            popover.sourceView = overview.dateNavigator
            popover.sourceRect = overview.dateNavigator.bounds
            popover.permittedArrowDirections = .any
            popover.delegate = self
        }

        present(datePickerVC, animated: true)


    }

    
}
extension ListMedicalViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
