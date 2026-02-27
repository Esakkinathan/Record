//
//  DetailMedicalItemViewController.swift
//  record
//
//  Created by Esakkinathan B on 26/02/26.
//
import UIKit

class DetailMedicalItemViewController: UIViewController {
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.separatorStyle = .singleLine
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    var presenter: DetailMedicalItemPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setUpContent()
        setUpNavigationBar()
    }
    func setUpNavigationBar() {
        title = presenter.title
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.largeTitleDisplayMode = .never
    }
    func setUpContent() {
        
        view.add(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(FormLabel.self, forCellReuseIdentifier: FormLabel.identifier)
        tableView.register(DonutChartCell.self, forCellReuseIdentifier: DonutChartCell.identifier)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}
extension DetailMedicalItemViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSection()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfSectionRows(at: section)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.getTitle(for: section)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let field = presenter.section(at: indexPath)
        switch field {
        case .info:
            return UITableView.automaticDimension
        default:
            return 300
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = presenter.section(at: indexPath)
        var cell: UITableViewCell
        switch field {
        case .info(let section):
            let newCell = tableView.dequeueReusableCell(withIdentifier: FormLabel.identifier, for: indexPath) as! FormLabel
            newCell.configure(title: section.title, text: section.value)
            cell = newCell
        case .dashBoard(let segments):
            let newCell = tableView.dequeueReusableCell(withIdentifier: DonutChartCell.identifier, for: indexPath) as! DonutChartCell
            newCell.configure(segments: segments)
            cell = newCell
        default:
            cell = UITableViewCell()
        }
        return cell
    }
}

extension DetailMedicalItemViewController: DetailMedicalItemViewDelegate {
    func reloadData() {
        tableView.reloadData()
    }
    
}
