//
//  KeyboardNotificationViewController.swift
//  record
//
//  Created by Esakkinathan B on 04/02/26.
//

import UIKit


class KeyboardNotificationViewController: UIViewController {

    var keyboardScrollableView: UIScrollView? { nil }
    var scrollToIndexPathOnKeyboardShow: IndexPath? { nil }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let scrollView = keyboardScrollableView
        else { return }

        let height = keyboardFrame.height
        scrollView.contentInset.bottom = height
        scrollView.verticalScrollIndicatorInsets.bottom = height

        if let indexPath = scrollToIndexPathOnKeyboardShow,
           let tableView = scrollView as? UITableView {
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        guard let scrollView = keyboardScrollableView else { return }
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
}
