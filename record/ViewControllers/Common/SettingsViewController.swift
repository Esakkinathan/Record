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
    let identifier = "SettingsViewCell"
    
    func setUpContents() {
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.register(ColorPickerCell.self, forCellReuseIdentifier: ColorPickerCell.identifier)
        tableView.register(SwitchCell.self, forCellReuseIdentifier: SwitchCell.identifier)
        tableView.register(ThemeSegmentCell.self, forCellReuseIdentifier: ThemeSegmentCell.identifier)
        tableView.register(CompresionCell.self, forCellReuseIdentifier: CompresionCell.identifier)

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
    func showToastVC(message: String, type: ToastType) {
        showToast(message: message, type: type)
    }
    func reload() {
        tableView.reloadData()
    }

}
extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        presenter.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows(section: section)
    }
    
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        return presenter.titleForSection(at: section)
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let sectionItem = presenter.sectionRowAt(indexPath)
        
        switch sectionItem {
        case .theme:
            let cell = tableView.dequeueReusableCell(withIdentifier: ThemeSegmentCell.identifier, for: indexPath) as! ThemeSegmentCell
            
            cell.configure(
                current: presenter.currentTheme,
                accent: SettingsManager.shared.accent.color
            ) { [weak self] theme in
                self?.presenter.selectTheme(theme)
            }
            
            return cell

        case .accent:
            let cell = tableView.dequeueReusableCell(withIdentifier: ColorPickerCell.identifier, for: indexPath) as! ColorPickerCell
            cell.configure(selected: presenter.currentAccent) { [weak self] accent in
                self?.presenter.selectAccent(accent)
                self?.setUpNavigation()
            }
            return cell

        case .appLock:
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.identifier, for: indexPath) as! SwitchCell
            cell.configure(
                title: "App Lock",
                isOn: presenter.isFaceIdEnabled
            ) { [weak self] isOn in
                self?.presenter.toggleFaceId(isOn){ success in
                    if !success {
                        // revert switch
                        cell.setSwitchState(!isOn)
                    }
                }
            }
            return cell

        case .systemSettings:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .default, reuseIdentifier: identifier)
            cell.textLabel?.text = "Edit app system Settings"
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            return cell

        case .resetPin:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .default, reuseIdentifier: identifier)
            cell.textLabel?.text = "Reset Pin"
//            cell.textLabel?.numberOfLines = 0
//            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            return cell

        case .compression:
            let cell = tableView.dequeueReusableCell(withIdentifier: CompresionCell.identifier, for: indexPath) as! CompresionCell
            cell.configure(text: presenter.compressionLevel.rawValue)
            cell.handler = { [weak self] level in
                self?.presenter.updateCompresseion(level:level)
            }
            return cell

        }
    }
    func setUpNavigation() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        //SettingsManager.shared.accent = accent
        let accent = SettingsManager.shared.accent
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = accent.color
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }

}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = presenter.sectionRowAt(indexPath)
        switch item {
        case .systemSettings:
            presenter.openSettings()
        case .resetPin:
            presenter.didClickedResentPin()
        default:
            break
        }        
    }
}

extension SettingsViewController: DocumentNavigationDelegate {
    func push(_ vc: UIViewController) {
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true)
    }
}
