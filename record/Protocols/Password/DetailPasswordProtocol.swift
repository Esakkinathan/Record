//
//  DetailPasswordProtocol.swift
//  record
//
//  Created by Esakkinathan B on 04/02/26.
//
import UIKit
import VTDB
protocol DetailPasswordPresenterProtocol {
    var title: String { get }
    func editButtonClicked()
    func updateNotes(text: String?)
    func numberOfSection() -> Int
    func numberOfSectionRows(at section: Int) -> Int
    func section(at indexPath: IndexPath) -> DetailPasswordRow
    func getTitle(for section: Int) -> String?
    func toggleNotesEditing(_ editing: Bool)
    var isNotesEditing: Bool {get}
    func updateLastCopiedDate()

}

protocol DetailPasswordViewDelegate: AnyObject {
    func reloadData()
    func updatePasswordNotes(text: String?, id: Int)
    func updatePassword(_ password: Persistable)
}

protocol DetailPasswordRouterProtocol {
    func openEditPasswordVC(mode: PasswordFormMode, onEdit: @escaping ((Persistable) -> Void))
}
enum DetailPasswordRow {
    case info(DetailPasswordTextSectionRow)
    case notes(text: String?, isEditable: Bool)
}

struct DetailPasswordSection {
    let title: String?
    let rows: [DetailPasswordRow]
}


enum DetailPasswordTextSection: CaseIterable {
    case text
    case copyLabel
    case passwordLabel
}

struct DetailPasswordTextSectionRow {
    var title: String
    var value: String
    var date: Date?
    var type: DetailPasswordTextSection
}
