//
//  MissedScheduleCell.swift
//  record
//
//  Created by Esakkinathan B on 09/03/26.
//
import UIKit

class MissedScheduleCell: UITableViewCell {

    static let identifier = "MissedScheduleCell"

    private let tableView = UITableView()

    private var items: [(String,String)] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.add(tableView)

        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .secondarySystemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(data: [(String,String)]) {
        items = data
        tableView.reloadData()
    }
}

extension MissedScheduleCell: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .secondarySystemBackground
        let item = items[indexPath.row]
        cell.textLabel?.text = "\(item.0)  -  \(item.1)"

        return cell
    }
}
