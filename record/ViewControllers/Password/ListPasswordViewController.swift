//
//  ListPasswordViewController.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

import UIKit

class ListPasswordViewController: UIViewController {
    static let identifier = "ListPasswordCell"
    
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
    var presenter: ListPasswordProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setUpNavigationBar()
        setUpContents()
    }
    
    func setUpNavigationBar() {
        title = "Password Manager"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppConstantData.exit, style: AppConstantData.buttonStyle, target: self, action: #selector(exitClicked))
       // navigationItem.titleView = timerLabel
    }
    
    @objc func exitClicked() {
        presenter.exitClicked()
    }
    
    func setUpContents() {
        view.add(tableView)
        view.add(timerLabel)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ListPasswordCell.self, forCellReuseIdentifier: ListPasswordCell.identifier)
        
        NSLayoutConstraint.activate([
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: PaddingSize.height),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: PaddingSize.height),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

    }
    @objc func addButtonClicked() {
        presenter.gotoAddPasswordScreen()
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
    
}

extension ListPasswordViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectedRow(at: indexPath.row)
    }
}

extension ListPasswordViewController: ListPasswordViewDelegate {
    func reloadData() {
        tableView.reloadData()
    }
    func reloadCellAt(_ indexRow: Int) {
        tableView.reloadRows(at: [IndexPath(row: indexRow, section: 1)], with: .automatic)
    }
    func dismiss() {
        dismiss(animated: true)
    }
    
    func updateTimer(_ time: String) {
        timerLabel.text = time
    }
    
    func showExitPrompt(expired: Bool) {

        let title = expired ? "Session Expired" : "Exit Passwords?"
        let message = "Do you want to stay for another 5 minutes?"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { [weak self] _ in
            self?.presenter.exitPassoword()
        })

        alert.addAction(UIAlertAction(title: "Stay", style: .default) { [weak self] _ in
            self?.presenter.extendSession()
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

