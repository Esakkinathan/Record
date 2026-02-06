//
//  ListDocumentViewController.swift
//  record
//
//  Created by Esakkinathan B on 25/01/26.
//
import UIKit

fileprivate func makeListViewDocumentPresenter(vc: ListDocumentViewDelegate) -> ListDocumentPresenter {
    return ListDocumentPresenter(view: vc)
}


class ListDocumentViewController: UIViewController, ListDocumentViewDelegate {
    func reloadData() {
        tableView.reloadData()
    }
    
    let tableView = UITableView()
    let segmentedControl = UISegmentedControl(items: DocumentCategory.getList())
    var selectedCategory: DocumentCategory = .Default
    var filteredDocuments: [Document] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSearching: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    var presenter: ListDocumentProtocol!
    
    var documentsList: [[Document]] = [
        [Document(id: 1, name: "Adhar Card", number: "228861826825",expiryDate: nil ,file: nil, type: .Default)],
        [Document(id: 1, name: "Marriage Certificate", number: "TnMrgerg-2345sdfg",expiryDate: Date() ,file: nil, type: .Custom)]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        presenter = makeListViewDocumentPresenter(vc: self)
        setUpNavigationBar()
        setUpContents()
    }
    
    func setUpNavigationBar() {
        title = "Documents"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: IconName.add), style: AppConstantData.buttonStyle, target: self, action: #selector(openAddDocumentView))
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search documents"
        searchController.obscuresBackgroundDuringPresentation = false

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        definesPresentationContext = true
    }
    
    func setUpContents() {
        view.backgroundColor = .systemBackground
        view.basicSetUp(for: segmentedControl)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)
        
        view.basicSetUp(for: tableView)
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(ListDocumentTableViewCell.self, forCellReuseIdentifier: ListDocumentTableViewCell.identifier)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: PaddingSize.heightPadding),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.widthAnchor.constraint(equalToConstant: view.frame.width * 0.75),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor,constant: PaddingSize.heightPadding),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc func segmentValueChanged() {
        presenter.segmentChange(index: segmentedControl.selectedSegmentIndex)
    }
    
    func currentDocuments() -> [Document] {
        let docs = documentsList[segmentedControl.selectedSegmentIndex]
        return isSearching ? filteredDocuments : docs
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
            self?.presenter.shareDocument(at: indexPath.row)
        }
        return cell
    }
}

extension ListDocumentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let document = presenter.document(at: indexPath.row)
        let vc = DetailDocumentViewController()
        
        vc.configure(document: document)
        vc.onEdit = { [weak self] document in
            guard let self = self else {return}
            presenter.updateDocument(at: indexPath.row, document: document)
        }
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: AppConstantData.delete) { [weak self] _, _, completion in
            guard let self = self else { return }
            presenter.deleteDocument(at: indexPath.row)
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: IconName.trash)
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = true
        return swipeAction
    }

}
extension ListDocumentViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased() else { return }
        
        let docs = documentsList[segmentedControl.selectedSegmentIndex]
        filteredDocuments = docs.filter {
            $0.name.lowercased().replacingOccurrences(of: " ", with: "").contains(text) ||
            $0.number.lowercased().replacingOccurrences(of: " ", with: "").contains(text)
        }
        tableView.reloadData()
    }
}

extension ListDocumentViewController {
    func shareDocument(url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityVC, animated: true)

    }
    
    @objc func openAddDocumentView() {
        let vc = AddDocumentViewController()
        vc.configure(selectedCategory,action: .add)
        vc.onAdd = { [weak self] document in
            self?.presenter.addDocument(document)
        }
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .formSheet

        present(navVc, animated: true)
    }
}
