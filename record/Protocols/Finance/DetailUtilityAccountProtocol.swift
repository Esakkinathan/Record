//
//  DetailUtilityAccountProtocol.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//

import Foundation
import VTDB
protocol DetailUtilityAccountPresenterProtocol {
    var title: String { get }
    func editButtonClicked()
    func updateNotes(text: String?)
    func numberOfSection() -> Int
    func numberOfSectionRows(at section: Int) -> Int
    func section(at indexPath: IndexPath) -> DetailUtilityAccountRow
    func getTitle(for section: Int) -> String?
    func toggleNotesEditing(_ editing: Bool)
    var isNotesEditing: Bool {get}
    func viewDidLoad()
    
    func didSelectRowAt(indexPath: IndexPath)

}

protocol DetailUtilityAccountViewDelegate: AnyObject {
    func reloadData()
    func updateUtilityAccountNotes(text: String?, id: Int)
    func updateUtilityAccountRecord(_ UtilityAccount: UtilityAccount)
    func reloadSection(at section: Int)

}

protocol DetailUtilityAccountRouterProtocol {
    func openListBillVC(type: BillType, utilityAccount: UtilityAccount)
    func openEditUtilityAccountVC(mode: UtilityAccountFormMode, utility: Utility,onEdit: @escaping (Persistable) -> Void)
}

enum DetailUtilityAccountRow {
    case info(DetailUtilityAccountTextSectionRow)
    case notes(text: String?, isEditable: Bool)
    case bill(BillType)
}

struct DetailUtilityAccountSection {
    let title: String?
    let rows: [DetailUtilityAccountRow]
}

struct DetailUtilityAccountTextSectionRow {
    var title: String
    var value: String
}
