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
    var logStatus: [LogStatus] { get }
    var selectedDate: Date { get }
    func numberOfSection() -> Int
    func numberOfSectionRows(at section: Int) -> Int
    func section(at indexPath: IndexPath) -> DetailMedicalRow
    func getTitle(for section: Int) -> String?
    func viewDidLoad()
    var status: Bool { get }
    func setStatus(value: Bool)
    func editButtonClicked()
    func changeLogStatus(_ logStatus: LogStatus)
}

protocol DetailMedicalItemViewDelegate: AnyObject {
    func showToastVC(message: String, type: ToastType)
    func reloadData()
    func updateMedicine(_ medicine: Persistable)
}
