//
//  ListPasswordProtocol.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

protocol ListPasswordProtocol {
    func numberOfPasswords() -> Int
    func password(at index: Int) -> Password
    func didSelectedRow(at index: Int)
    func gotoAddPasswordScreen()
    func toggleFavorite(_ password: Password)
    func exitClicked()
    func viewDidLoad()
    func exitPassoword()
    func extendSession()
}

protocol ListPasswordViewDelegate: AnyObject {
    func reloadData()
    func reloadCellAt(_ indexRow: Int)
    func updateTimer(_ time: String)
    func showExitPrompt(expired: Bool)
    func dismiss()
}

protocol ListPasswordRouterProtocol {
    func openAddPasswordVC(mode: PasswordFormMode, onAdd: @escaping (Password) -> Void)
    func openDetailPasswordVC(password: Password,onUpdate: @escaping (Password) -> Void, onUpdateNotes: @escaping (String?,Int) -> Void)
}
