//
//  ListUtilityAccountProtocol.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//
import VTDB

protocol ListUtilityAccountPresenterProtocol {
    var title: String { get }
    func numberOfRows() -> Int
    func utilityAccount(at index: Int) -> UtilityAccount
    func deleteUtilityAccount(at index: Int)
    func editUtilityAccount(at index: Int)
    func gotoAddUtilityAccountScreen()
    func viewDidLoad()
    func didSelectedRow(at index: Int)
}


protocol ListUtilityAccountViewDelegate: AnyObject {
    func reloadData()
}

protocol ListUtilityAccountRouterProtocol {
    func openAddUtilityAccountVC(mode: UtilityAccountFormMode, utility: Utility, onChange: ((Persistable) -> Void)?)
    func openDetailUtilityAccountVC(utilityAccount: UtilityAccount, utility: Utility, onUpdate: @escaping (UtilityAccount) -> Void, onUpdateNotes: @escaping (String?, Int) -> Void)}
