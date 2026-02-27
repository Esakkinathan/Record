//
//  SettingsViewController.swift
//  record
//
//  Created by Esakkinathan B on 19/02/26.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var presenter: SettingsPresenterProtocol!
    let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        setUpContents()
    }
    
    func setUpContents() {
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(ColorPickerCell.self, forCellReuseIdentifier: ColorPickerCell.identifier)
        tableView.register(SwitchCell.self, forCellReuseIdentifier: SwitchCell.identifier)
        tableView.register(ThemeSegmentCell.self, forCellReuseIdentifier: ThemeSegmentCell.identifier)

        view.add(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}

extension SettingsViewController: SettingsViewDelegate {
    func reload() {
        tableView.reloadData()
    }

}
extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1   // Theme + Color
        case 1: return 2   // Face ID
        default: return 0
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        switch section {
        case 0: return "Appearance"
        case 1: return "System"
        default: return nil
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ThemeSegmentCell.identifier, for: indexPath) as! ThemeSegmentCell
            
            cell.configure(
                current: presenter.currentTheme,
                accent: SettingsManager.shared.accent.color
            ) { [weak self] theme in
                self?.presenter.selectTheme(theme)
            }
            
            return cell
        }

//        if indexPath.section == 0 && indexPath.row == 1 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: ColorPickerCell.identifier, for: indexPath) as! ColorPickerCell
//            cell.configure(selected: presenter.currentAccent) { [weak self] accent in
//                self?.navigationController?.navigationBar.backgroundColor = accent.color
//                self?.presenter.selectAccent(accent)
//            }
//            return cell
//        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.identifier, for: indexPath) as! SwitchCell
            cell.configure(
                title: "Face ID",
                isOn: presenter.isFaceIdEnabled
            ) { [weak self] isOn in
                self?.presenter.toggleFaceId(isOn)
            }
            return cell
        }
        if indexPath.section == 1 && indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") ?? UITableViewCell(style: .default, reuseIdentifier: "notificationCell")
            cell.textLabel?.text = "Edit app system Settings"
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        return UITableViewCell()
    }
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 {
            presenter.openSettings()
        }
        
    }
}
