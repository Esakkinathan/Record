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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentInsetAdjustmentBehavior = .automatic
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 100
        return view
    }()
    
    
    let activeTreatementView = InfoCardView()
    let todayMedicineView = InfoCardView()
    let categorySelector: CategorySelectorView =  {
        let view = CategorySelectorView(frame: .zero, options: MedicalType.getList(), images: MedicalType.getImage())
        return view
    }()
    let sortView = SortHeaderView()

    var presenter: ListMedicalPresenterProtocol!

    let identifier = "ListMedicalTabelViewCell"
    
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
        let summary = presenter.getActiveSummary()
        todayMedicineView.configure(section: summary.row1)
        activeTreatementView.configure(section: summary.row2)

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
        
        let searchButton = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(openSearch)
        )


        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItems = [addButton, spacer, searchButton]
    }
    
    
    func setUpContents() {
        
        view.backgroundColor = AppColor.background
        view.add(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        categorySelector.onSelect = { [weak self] text in
            self?.presenter.didSelectCategory(text)
        }
        
        NSLayoutConstraint.activate([
                        
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: PaddingSize.height),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupTableHeader() {
        
        let headerStack = UIStackView(arrangedSubviews: [
            todayMedicineView,
            activeTreatementView,
            categorySelector,
            sortView
        ])
        headerStack.axis = .vertical
        headerStack.spacing = PaddingSize.height

        let headerWrapper = UIView()
        headerWrapper.add(headerStack)

        let padding = PaddingSize.width
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

        let height = header.systemLayoutSizeFitting(
            CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        if header.frame.size.height != height {
            header.frame.size.height = height
            tableView.tableHeaderView = header
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
        cell.detailTextLabel?.text = "From \(medical.startDate.toString()) to \(medical.endDate.toString())"
        cell.accessoryType = .disclosureIndicator
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
    func reloadData() {
        tableView.reloadData()
        if presenter.isEmpty {
//            tableView.tableHeaderView?.isHidden = true
//            tableView.tableHeaderView?.frame.size.height = 0
            if !presenter.isSearching {
                tableView.setEmptyFoooterView(image: "tray.full", title: "No Health Records", subtitle: "Tap + on top to create your first Record.")

            } else {
                tableView.setEmptyFoooterView(image: "tray.full", title: "No Matching Health Record Found", subtitle: "Search with title, hospital and doctor name")
            }
        } else {
//            tableView.tableHeaderView?.isHidden = false
            //setupTableHeader()
            tableView.restoreFooter()
        }
    }
    
    func refreshSortMenu() {
        buildSortMenu()
    }
}

extension ListMedicalViewController: DocumentNavigationDelegate {
    func presentVC(_ vc: UIViewController) {
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

        sortView.configure(text: current.field.rawValue, iconName: current.direction == .ascending ? IconName.arrowUp : IconName.arrowDown)
        sortView.button.menu = UIMenu(
            title: "Sort By",
            children: [name, created, updated]
        )
    }
}
