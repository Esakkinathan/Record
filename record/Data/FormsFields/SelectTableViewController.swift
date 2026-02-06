//
//  SelectTableViewController.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit

class SelectTableViewController: UITableViewController {
    static let identifier = "SelectCell"
    let items: [String]
    var selectedItem: String?
    var onSelect: ((String) -> Void)?

    init(options: [String], selected: String?) {
        self.items = options
        self.selectedItem = selected
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SelectTableViewController.identifier)
        tableView.backgroundColor = .systemBackground
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectTableViewController.identifier, for: indexPath)
        
        let item = items[indexPath.row]
        cell.accessoryType = (item == selectedItem) ? .checkmark : .none
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        selectedItem = item
        onSelect?(item)
        dismiss(animated: true)
    }

}
