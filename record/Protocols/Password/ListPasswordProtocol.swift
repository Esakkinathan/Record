//
//  ListPasswordProtocol.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//
import VTDB

protocol ListPasswordProtocol {
    var isFavoriteSelected: Bool {get}
    var currentSort: PasswordSortOption { get }
    func numberOfPasswords() -> Int
    func password(at index: Int) -> Password
    func didSelectedRow(at index: Int)
    func gotoAddPasswordScreen()
    func toggleFavorite(_ password: Password)
    func exitClicked()
    func viewDidLoad()
    func exitPassoword()
    func extendSession()
    func didSelectSortField(_ field: PasswordSortField)
    func didSelectedFavourite()
    func search(text: String?)
    func deletePassword(index: Int)
}

protocol ListPasswordViewDelegate: AnyObject {
    func reloadData()
    func reloadCellAt(_ indexRow: Int)
    func updateTimer(_ time: String)
    func showExitPrompt(expired: Bool)
    func dismiss()
    func refreshSortMenu()
}

protocol ListPasswordRouterProtocol {
    func openAddPasswordVC(mode: PasswordFormMode, onAdd: @escaping (Persistable) -> Void)
    func openDetailPasswordVC(password: Password,onUpdate: @escaping (Persistable) -> Void, onUpdateNotes: @escaping (String?,Int) -> Void)
}
