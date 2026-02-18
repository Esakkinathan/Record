//
//  ListMedicalitemProtocol.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
import UIKit
import VTDB

protocol ListMedicalItemPresenterProtocol {
    var canEdit: Bool { get }
    var title: String { get }
    var startDate: Date {get}
    var endDate: Date {get}
    var selectedDate: Date {get}
    func numberOfRows() -> Int
    func medicalItem(at index: Int) ->  MedicalItem
    func deleteMedicalItem(at index: Int)
    func editMedicalItem(at index: Int)
    func gotoAddMedicalItemScreen()
    func viewDidLoad()
    func changeSelectedDate(_ date: Date)
    func didSelectCategory(_ text: String)
    func itemToggledAt(_ index: Int, value: Bool)
    func medicalItemViewModel(at index: Int) -> MedicalItemCellViewModel
    func updateEndDate(at index: Int)
}

protocol ListMedicalItemViewDelegate: AnyObject {
    func reloadData()
}

protocol ListMedicalItemRouterProtocol {
    func openAddMedicalItemVC(mode: MedicalItemFormMode, medicalId: Int, kind: MedicalKind, startDate: Date,onAdd: @escaping (Persistable) -> Void)
    func openEditMedicalItemVC(mode: MedicalItemFormMode, medicalId: Int, kind: MedicalKind, startDate: Date, onEdit: @escaping (Persistable) -> Void)

}
