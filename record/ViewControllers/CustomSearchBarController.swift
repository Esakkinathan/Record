//
//  CustomSearchBarController.swift
//  record
//
//  Created by Esakkinathan B on 15/02/26.
//
import UIKit

class CustomSearchBarController: UIViewController {
    var searchScrollingView: UIScrollView? { nil }

    func performSearch(text: String?) { }

    private var didSetupSearchBar = false
    
    func searchDidShow() { }
    func searchDidHide() { }
    
    private let bottomSearchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search"
        sb.searchBarStyle = .minimal
        sb.alpha = 0
        return sb
    }()
    
//    let searchButton = UIBarButtonItem(
//        barButtonSystemItem: .search,
//        target: self,
//        action: #selector(openSearch)
//    )

    private var bottomConstraint: NSLayoutConstraint!
    private var isSearchVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeKeyboard()
    }
    let maxCount = 30
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !didSetupSearchBar else { return }
        didSetupSearchBar = true

        setupSearchBar()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupSearchBar() {

        bottomSearchBar.delegate = self
        bottomSearchBar.showsCancelButton = true

        view.add(bottomSearchBar)
        view.bringSubviewToFront(bottomSearchBar)

        bottomConstraint = bottomSearchBar.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: 60
        )

        NSLayoutConstraint.activate([
            bottomSearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            bottomSearchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            bottomSearchBar.heightAnchor.constraint(equalToConstant: 44),
            bottomConstraint
        ])
    }
    
    func showSearch() {
        guard !isSearchVisible else { return }
        isSearchVisible = true

        bottomConstraint.constant = -8
        UIView.animate(withDuration: 0.25) {
            self.bottomSearchBar.alpha = 1
            self.view.layoutIfNeeded()
        }
        searchDidShow()
        bottomSearchBar.becomeFirstResponder()
        
//        view.layoutIfNeeded()
//        updateScrollInsets()
    }

    func hideSearch() {
        guard isSearchVisible else { return }
        isSearchVisible = false
        
        performSearch(text: nil)
        bottomSearchBar.text = nil
        bottomSearchBar.resignFirstResponder()

        bottomConstraint.constant = 60
        searchDidHide()
        UIView.animate(withDuration: 0.25) {
            self.bottomSearchBar.alpha = 0
            self.view.layoutIfNeeded()
        }

        //view.layoutIfNeeded()
        //updateScrollInsets()
    }


}


extension CustomSearchBarController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearch()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchBar.text
        guard let searchText = text else {
            performSearch(text: nil)
            return
        }
        if searchText.count > maxCount {
            let endIndex = searchText.index(searchText.startIndex, offsetBy: maxCount, limitedBy: searchText.endIndex) ?? searchText.endIndex
            searchBar.text = String(searchText[..<endIndex])
            showToast(message: "Enter maximum of \(maxCount) characters", type: .warning)
        }
        performSearch(text: searchText.isEmpty ? nil : searchText)
    }
}

extension CustomSearchBarController {
    private func observeKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let keyboardFrame = view.convert(frame, from: nil)
        let overlap = max(0, view.bounds.maxY - keyboardFrame.origin.y)
        let safeBottom = view.safeAreaInsets.bottom
        let keyboardHeight = max(0, overlap - safeBottom)

        if isSearchVisible {
            bottomConstraint.constant = -(keyboardHeight + 8)
        }

        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)

        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.updateScrollInsets(extra: keyboardHeight) // ← moved INSIDE
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateScrollInsets(extra: CGFloat = 0) {

        guard let scroll = searchScrollingView else { return }

        let searchHeight: CGFloat = isSearchVisible ? 52 : 0
        let inset = searchHeight + extra

        scroll.contentInset.bottom = inset
        scroll.verticalScrollIndicatorInsets.bottom = inset
    }

}
