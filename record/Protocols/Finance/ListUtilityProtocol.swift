//
//  ListUtilityProtocol.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//
import VTDB

protocol ListUtilityPresenterProtocol {
    var title: String { get }
    func numberOfRows() -> Int
    func utility(at index: Int) -> Utility
    func deleteUtility(at index: Int)
    func editUtility(at index: Int)
    func gotoAddUtilityScreen()
    func viewDidLoad()
    func didSelectedRow(at index: Int)
}


protocol ListUtilityViewDelegate: AnyObject {
    func reloadData()
}

protocol ListUtilityRouterProtocol {
    func openListUtilityAccountVC(utility: Utility)
    func openAddUtilityVC(mode: UtilityFormMode, onChange: ((Persistable) -> Void)?)
}
