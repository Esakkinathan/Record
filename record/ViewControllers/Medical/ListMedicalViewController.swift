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
    
    
    //let activeTreatementView = InfoCardView()
    let todayMedicineView = InfoCardView()
    let categorySelector: CategorySelectorView =  {
        let view = CategorySelectorView(frame: .zero, options: MedicalType.getList(), images: MedicalType.getImage())
        return view
    }()
    let sortView = SortHeaderView()

    var presenter: ListMedicalPresenterProtocol!

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
        presenter.viewDidLoad()
        setUpNavigationBar()
        setUpContents()
        setupTableHeader()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let summary = presenter.getActiveSummary()
        todayMedicineView.configure(dashboard: summary,icon: UIImage(systemName: "list.clipboard.fill"), subtitle: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none,), iconTint: SettingsManager.shared.accent.color)
        categorySelector.applyTint()
        //activeTreatementView.configure(section: summary.row2)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setUpNavigationBar() {
        title = presenter.title
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))

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
    }
    
    
    func setUpContents() {
        view.add(tableView)
        tableView.dataSource = self
        tableView.delegate = self

        categorySelector.onSelect = { [weak self] text in
            self?.presenter.didSelectCategory(text)
        }
        todayMedicineView.onBadgeTapped = { [weak self] rowModel, segment in
            guard let self else { return }
            let medicines = segment == .completed ? rowModel.completed : rowModel.remaining
            let popup = MedicinePopupViewController(
                scheduleName: rowModel.schedule.rawValue,
                segment: segment,
                medicines: medicines
            )
            self.present(popup, animated: true)
        }

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: PaddingSize.height),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    private var dashboardTopConstraint: NSLayoutConstraint?

    private func setupTableHeader() {
        let padding = PaddingSize.width

        dashboardContainer.clipsToBounds = true
        if todayMedicineView.superview == nil {
            dashboardContainer.add(todayMedicineView)
            NSLayoutConstraint.activate([
                todayMedicineView.topAnchor.constraint(equalTo: dashboardContainer.topAnchor),
                todayMedicineView.leadingAnchor.constraint(equalTo: dashboardContainer.leadingAnchor),
                todayMedicineView.trailingAnchor.constraint(equalTo: dashboardContainer.trailingAnchor),
                todayMedicineView.bottomAnchor.constraint(equalTo: dashboardContainer.bottomAnchor)
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
            self.todayMedicineView.alpha = 0
            self.headerWrapper.layoutIfNeeded()
        } completion: { _ in
            self.invalidateHeaderLayout()
        }
    }

    func expandDashboard() {
        guard dashboardHeightConstraint.isActive else { return }  // already expanded
        dashboardHeightConstraint.isActive = false

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.todayMedicineView.alpha = 1
            self.headerWrapper.layoutIfNeeded()
        } completion: { _ in
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
        presenter.search(text: text)
    }
    override func searchDidShow() {
        searchButton.isEnabled = false
        collapseDashboard()
    }
    override func searchDidHide() {
        searchButton.isEnabled = true
        expandDashboard()
    }

}

extension ListMedicalViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let medical = presenter.medical(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        cell.textLabel?.text = medical.title
        cell.detailTextLabel?.text = "From \(medical.date.toString())"
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .secondarySystemBackground
        cell.selectionStyle = .none
        cell.imageView?.image = UIImage(systemName: medical.type.image)
        return cell

    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: AppConstantData.delete) { [weak self] _, _, completion in
            self?.presenter.deleteMedical(at: indexPath.row)
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: IconName.trash)
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = true
        return swipeAction
    }
}

extension ListMedicalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectedRow(at: indexPath.row)
    }
}

extension ListMedicalViewController: ListMedicalViewDelegate {
    func refreshSortMenu() {
        buildSortMenu()
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
                tableView.setEmptyView(
                    image: "tray.full",
                    title: "No Matching Health Record Found",
                    subtitle: "Search with title, hospital and doctor name"
                )
            }
        } else {
            tableView.restoreFooter()
            tableView.restoreBackgroundView()
        }
    }

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
            title: "Recorded At",
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

        sortView.configure(text: current.field.rawValue, iconName: current.direction == .ascending ? IconName.arrowUp : IconName.arrowDown)
        sortView.button.menu = UIMenu(
            title: "Sort By",
            children: [name, created, updated]
        )
    }
}
