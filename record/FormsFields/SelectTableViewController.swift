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
    var addExtra: Bool
    init(options: [String], selectedOption: String, addExtra: Bool) {
        self.options = options
        self.selectedOption = selectedOption
        self.addExtra = addExtra
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUpContents()
    }
    func setUpNavigationBar() {
        if addExtra {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addOption))
        }
    }
    func setUpContents() {
        title = "Select Option"
        view.backgroundColor = AppColor.background
        
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
    
    func showAddOptionAlert(_ value: String = "") {
        let alert = UIAlertController(
            title: "Add new Option",
            message: "",
            preferredStyle: .alert
        )
        
        alert.addTextField {
            $0.text = value
            $0.placeholder = "Option"
            $0.returnKeyType = .done
            $0.autocorrectionType = .no
            $0.keyboardType = .alphabet
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self, weak alert] _ in
            guard let self = self, let alert = alert else { return }
            alert.textFields?[0].resignFirstResponder()
            let enteredText = alert.textFields?[0].text ?? ""
            if enteredText.isEmpty {
                showToast(message: "Add Option", type: .error)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.addOption()
                }
                return

            }
            if enteredText.count < 4 || enteredText.count > 30 {
                showToast(message: "Length Should be 4 to 30", type: .error)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showAddOptionAlert(enteredText)
                }
                return
            }
            selectedData(text: enteredText)
        })
        present(alert, animated: true)

    }
    
    @objc func addOption() {
        showAddOptionAlert()
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
    func selectedData(text: String) {
        onValueSelected?(text)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selected = options[indexPath.row]
        if selected != selectedOption {
            selectedOption = selected
            tableView.reloadData()
            selectedData(text: selected)
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
