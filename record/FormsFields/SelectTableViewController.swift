//
//  SelectTableViewController.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit

class SelectionViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let options: [String]
    var selectedOption: String
    var onValueSelected: ((String) -> Void)?
    
    init(options: [String], selectedOption: String) {
        self.options = options
        self.selectedOption = selectedOption
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Option"
        view.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "optionCell")
        view.add(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
}


extension SelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
        let option = options[indexPath.row]
        cell.textLabel?.text = option
        cell.accessoryType = (option == selectedOption) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selected = options[indexPath.row]
        if selected != selectedOption {
            selectedOption = selected
            tableView.reloadData()
            onValueSelected?(selected)
        }
        navigationController?.popViewController(animated: true)
    }

}
class MultiSelectionViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let options: [String]

    private var selectedOptions: Set<String>

    var onValuesSelected: (([String]) -> Void)?

    init(options: [String], selectedOptions: [String]) {
        self.options = options
        self.selectedOptions = Set(selectedOptions)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Options"
        view.backgroundColor = .systemBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsMultipleSelection = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "optionCell")

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        setupDoneButton()
    }

    private func setupDoneButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,target: self,
            action: #selector(doneTapped)
        )
    }

    @objc private func doneTapped() {
        onValuesSelected?(Array(selectedOptions))
        navigationController?.popViewController(animated: true)
    }
}

extension MultiSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "optionCell",
            for: indexPath
        )

        let option = options[indexPath.row]
        cell.textLabel?.text = option
        cell.accessoryType = selectedOptions.contains(option) ? .checkmark : .none

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let option = options[indexPath.row]

        if selectedOptions.contains(option) {
            if selectedOptions.count == 1 {
                showToast(message: "Must Select One time", type: .warning)
            } else {
                selectedOptions.remove(option)
            }
        } else {
            selectedOptions.insert(option)
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
