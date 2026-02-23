//
//  ListMedicalProtocol.swift
//  record
//
//  Created by Esakkinathan B on 08/02/26.
//
import VTDB
protocol ListMedicalPresenterProtocol {
    var title: String { get }
    var currentSort: MedicalSortOption { get }
    func numberOfRows() -> Int
    func medical(at index: Int) -> Medical
    func addMedical(_ medical: Medical)
    func updateMedical(medical: Medical)
    func deleteMedical(at index: Int)
    func didSelectedRow(at index: Int)
    func gotoAddMedicalScreen()
    func search(text: String?)
    func didSelectSortField(_ field: MedicalSortField)
    func viewDidLoad()
    func didSelectCategory(_ text: String)
    func getActiveSummary() -> DashBoardData
    var isEmpty: Bool { get }
    var isSearching: Bool { get }

}

protocol ListMedicalViewDelegate: AnyObject {
    func reloadData()
    func refreshSortMenu()
}
protocol ListMedicalRouterProtocol {
    func openAddMedicalVC(mode: MedicalFormMode, onAdd: @escaping (Persistable) -> Void)
    func openDetailMedicalVC(medical: Medical,onUpdate: @escaping (Persistable) -> Void, onUpdateNotes: @escaping (String?,Int) -> Void)
}
