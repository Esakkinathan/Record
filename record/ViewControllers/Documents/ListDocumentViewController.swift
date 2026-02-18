//
//  ListDocumentViewController.swift
//  record
//
//  Created by Esakkinathan B on 25/01/26.
//
import UIKit

class ListDocumentViewController: CustomSearchBarController {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = PaddingSize.cellSpacing
        layout.minimumInteritemSpacing = PaddingSize.cellSpacing
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInsetAdjustmentBehavior = .automatic
        view.keyboardDismissMode = .onDrag
        view.backgroundColor = AppColor.background
        return view
    }()
    
    var presenter: ListDocumentPresenterProtocol!
    
    let sortView = SortHeaderView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setUpNavigationBar()
        setUpContents()
        
    }
    
    func setUpNavigationBar() {
        title = DocumentConstantData.document
        navigationController?.navigationBar.isTranslucent = false
        let searchButton = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(openSearch)
        )
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        
        let spacer = UIBarButtonItem(
            barButtonSystemItem: .fixedSpace,
            target: nil,
            action: nil
        )
        spacer.width = 12
        
        navigationItem.rightBarButtonItems = [addButton, spacer, searchButton]
        
    }
    
    
    func setUpContents() {
        
        view.backgroundColor = AppColor.background
        view.add(sortView)
        view.add(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(ListDocumentViewCell.self, forCellWithReuseIdentifier: ListDocumentViewCell.identifier)
        
        NSLayoutConstraint.activate([
            sortView.topAnchor.constraint(equalTo: view.topAnchor,constant: PaddingSize.height),
            sortView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PaddingSize.width),
            sortView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PaddingSize.content),
            
            
            collectionView.topAnchor.constraint(equalTo: sortView.bottomAnchor,constant: PaddingSize.height),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, ),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PaddingSize.width),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PaddingSize.width),
            
        ])
    }
    @objc func openSearch() {
        showSearch()
    }
    override func searchScrollingView() -> UIScrollView? {
        collectionView
    }

    override func performSearch(text: String?) {
        presenter.search(text: text)
    }


    
}
extension ListDocumentViewController {

}

extension ListDocumentViewController {
    
    @objc func addButtonClicked() {
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
            title: DocumentSortField.name.rawValue,
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
            title: DocumentSortField.createdAt.rawValue,
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
            title: DocumentSortField.updatedAt.rawValue,
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
            title: DocumentSortField.expiryDate.rawValue,
            subtitle: subtitle(
                field: .expiryDate,
                asc: "Newest to Oldest",
                desc: "Oldest to Newest"
            ),
            state: current.field == .expiryDate ? .on : .off
        ) { [weak self] _ in
            self?.presenter.didSelectSortField(.expiryDate)
        }
        
        sortView.configure(text: current.field.rawValue, iconName: current.direction == .ascending ? IconName.arrowUp : IconName.arrowDown)
        sortView.button.menu = UIMenu(
            title: "Sort By",
            children: [name, created, updated, expiry]
        )
    }


}


extension ListDocumentViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfRows()
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let document = presenter.document(at: indexPath.row)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListDocumentViewCell.identifier, for: indexPath) as! ListDocumentViewCell
        cell.configure(document: document)
        cell.onShareButtonClicked = { [weak self] in
            self?.shareButtonClicked(indexPath)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let totalSpacing = PaddingSize.cellSpacing
        
        let width = (collectionView.frame.width - totalSpacing) / 2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
            
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let delete = UIAction(title: AppConstantData.delete,
                                  image: UIImage(systemName: IconName.trash),
                                  attributes: .destructive) { [weak self] _ in
                self?.presenter.deleteDocument(at: indexPath.row)
            }
            
            return UIMenu(title: "", children: [delete])
        }
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
            $0.returnKeyType = .next
        }
        alert.addTextField {
            $0.placeholder = "Confirm Password"
            $0.isSecureTextEntry = true
            $0.returnKeyType = .done
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Share", style: .default) { [weak self, weak alert] _ in
            guard let self = self, let alert = alert else { return }
            
            alert.textFields?[1].resignFirstResponder()
            let password = alert.textFields?[0].text ?? ""
            let confirm = alert.textFields?[1].text ?? ""
            
            if password.isEmpty || confirm.isEmpty {
                alert.dismiss(animated: true) {
                    self.showToastVC(message: "Enter Password", type: .error)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.askForPasswordAndShare(at: index)
                    }
                    
                }
                return
            }
            
            if password != confirm {
                alert.dismiss(animated: true) {
                    self.showToastVC(message: "Password does not match", type: .error)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.askForPasswordAndShare(at: index)
                    }
                }
                return
            }
            
            if password.count < 4 || password.count > 8 {
                alert.dismiss(animated: true) {
                    self.showToastVC(message: "Password length between 4 to 8", type: .error)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.askForPasswordAndShare(at: index)
                    }
                }
                return
            }
            
            // All validation passed
            self.presenter.shareDocumentWithLock(at: index, password: password)
        })
        present(alert, animated: true)
    }}


extension ListDocumentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectedRow(at: indexPath.row)
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
        collectionView.reloadData()
    }
    func refreshSortMenu() {
        buildSortMenu()
    }
    func showToastVC(message: String, type: ToastType) {
        showToast(message: message, type: type)
    }
}


/*
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
 */
