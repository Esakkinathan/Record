//
//  FormField.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//
import UIKit


protocol FormCell {
    var identifier: String { get }
    func register(tableView: UITableView)
    func dequeue(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
}
