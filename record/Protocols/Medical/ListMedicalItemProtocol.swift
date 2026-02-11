//
//  ListMedicalitemProtocol.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
import UIKit

protocol ListMedicalItemPresenterProtocol {
    var title: String { get }
    func numberOfRows() -> Int
    func medicalItem(at index: Int) -> MedicalItem
    func deleteMedicalItem(at index: Int)
    func editMedicalItem(at index: Int)
    func gotoAddMedicalItemScreen()
    func viewDidLoad()
}

protocol ListMedicalItemViewDelegate: AnyObject {
    func reloadData()
}

protocol ListMedicalItemRouterProtocol {
    func openAddMedicalItemVC(mode: MedicalItemFormMode, medicalId: Int, kind: MedicalKind,onAdd: @escaping (MedicalItem) -> Void)
    func openEditMedicalItemVC(mode: MedicalItemFormMode, medicalId: Int, kind: MedicalKind, onEdit: @escaping (MedicalItem) -> Void)

}
