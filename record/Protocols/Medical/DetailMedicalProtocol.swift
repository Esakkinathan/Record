//
//  DetailMedicalProtocol.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//

import UIKit

import VTDB

protocol DetailMedicalPresenterProtocol {
    var title: String { get }
    func editButtonClicked()
    func updateNotes(text: String?)
    func numberOfSection() -> Int
    func numberOfSectionRows(at section: Int) -> Int
    func section(at indexPath: IndexPath) -> DetailMedicalRow
    func getTitle(for section: Int) -> String?
    func toggleNotesEditing(_ editing: Bool)
    var isNotesEditing: Bool {get}
    func viewDidLoad()
    
    func didSelectRowAt(indexPath: IndexPath)
    

}
protocol DetailMedicalViewDelegate: AnyObject {
    func reloadData()
    func updateMedicalNotes(text: String?, id: Int)
    func updateMedicalRecord(_ medical: Persistable)
    func reloadSection(at section: Int)
}

protocol DetailMedicalRouterProtocol {
    func openEditMedicalVC(mode: MedicalFormMode, onEdit: @escaping ((Persistable) -> Void))
    func openListMedicalItemVC(kind: MedicalKind, medical: Medical)
}

enum DetailMedicalRow {
    case info(DetailMedicalTextSectionRow)
    case notes(text: String?, isEditable: Bool)
    case medicalItem(MedicalKind)
}

struct DetailMedicalSection {
    let title: String?
    let rows: [DetailMedicalRow]
}

struct DetailMedicalTextSectionRow {
    var title: String
    var value: String
    
}
