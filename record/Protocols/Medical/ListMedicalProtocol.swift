//
//  ListMedicalProtocol.swift
//  record
//
//  Created by Esakkinathan B on 08/02/26.
//

protocol ListMedicalPresenterProtocol {
    var title: String {get}
    func numberOfRows() -> Int
    func medical(at index: Int) -> Medical
    func addMedical(_ medical: Medical)
    func updateMedical(medical: Medical)
    func deleteMedical(at index: Int)
    func didSelectedRow(at index: Int)
    func gotoAddMedicalScreen()
    func search(text: String?)
    func didSelectSortField(_ field: DocumentSortField)
    func viewDidLoad()
}

protocol ListMedicalViewDelegate: AnyObject {
    func reloadData()
    func refreshSortMenu()
}
protocol ListMedicalRouterProtocol {
    func openAddMedicalVC(mode: MedicalFormMode, onAdd: @escaping (Medical) -> Void)
    func openDetailMedicalVC(medical: Medical,onUpdate: @escaping (Medical) -> Void, onUpdateNotes: @escaping (String?,Int) -> Void)
}
