//
//  DetailMedicalItemPresenter.swift
//  record
//
//  Created by Esakkinathan B on 26/02/26.
//
import UIKit
import VTDB
protocol DetailMedicalItemPresenterProtocol {
    var title: String { get }
    func numberOfSection() -> Int
    func numberOfSectionRows(at section: Int) -> Int
    func section(at indexPath: IndexPath) -> DetailMedicalRow
    func getTitle(for section: Int) -> String?
    func viewDidLoad()
    var status: Bool { get }
    func setStatus(value: Bool)
    func editButtonClicked()
}

protocol DetailMedicalItemViewDelegate: AnyObject {
    func reloadData()
    func updateMedicine(_ medicine: Persistable)
}
