//
//  MedicalScheduleTimeViewController.swift
//  record
//
//  Created by Esakkinathan B on 19/03/26.
//

import UIKit

final class MedicalScheduleTimeViewController: UIViewController {


    private var reminders: [MedicalScheduleTime] = []


    private let tableView = UITableView(frame: .zero, style: .insetGrouped)


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Medicine Remainder"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = AppColor.background

        reminders = SettingsManager.shared.allScheduleTime()
        setupTableView()
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.backgroundColor = AppColor.background
        tableView.delegate        = self
        tableView.dataSource      = self
        tableView.register(ReminderRowCell.self, forCellReuseIdentifier: ReminderRowCell.identifier)

        view.add(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }


    private func showTimePicker(for index: Int, sourceButton: UIButton) {
        let reminder = reminders[index]

        let pickerVC = TimePickerPopoverViewController()
        pickerVC.modalPresentationStyle = .popover
        pickerVC.setTime(hour: reminder.hour, minute: reminder.minute, schedule: reminder.schedule)

        pickerVC.onDone = { [weak self] hour, minute in
            guard let self else { return }
            self.reminders[index].hour   = hour
            self.reminders[index].minute = minute
            SettingsManager.shared.saveScheduleTime(self.reminders[index])
            NotificationManager.shared.syncMedicalNotifications()
            let path = IndexPath(row: index, section: 0)
            self.tableView.reloadRows(at: [path], with: .none)
        }

        if let popover = pickerVC.popoverPresentationController {
            popover.sourceView              = sourceButton
            popover.sourceRect              = sourceButton.bounds
            popover.permittedArrowDirections = .any
            popover.delegate                = self
        }

        present(pickerVC, animated: true)
    }
}


extension MedicalScheduleTimeViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reminders.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Daily Schedule"
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "Tap the time to change it. The selected time will be used for the medicine intake."
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ReminderRowCell.identifier, for: indexPath) as! ReminderRowCell
        cell.configure(with: reminders[indexPath.row])
        cell.onTimeTapped = { [weak self] button in
            self?.showTimePicker(for: indexPath.row, sourceButton: button)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 54 }
}


extension MedicalScheduleTimeViewController: UITableViewDelegate {
}


extension MedicalScheduleTimeViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController
    ) -> UIModalPresentationStyle {
        .none
    }
}
