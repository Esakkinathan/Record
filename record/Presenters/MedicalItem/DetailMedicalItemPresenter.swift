//
//  DetailMedicalItemPresenter.swift
//  record
//
//  Created by Esakkinathan B on 26/02/26.
//

import UIKit

class DetailMedicalItemPresenter: DetailMedicalItemPresenterProtocol {
    
    var title: String {
        medicalItem.name
    }
    
    var medicalItem: Medicine
    weak var view: DetailMedicalItemViewDelegate?
    var sections: [DetailMedicalSection] = []
    var updateUseCase: UpdateMedicineUseCaseProtocol
    let router: DetailMedicineRouterProtocol
    let medical: Medical
    init(view: DetailMedicalItemViewDelegate? = nil, medicalItem: Medicine, router: DetailMedicineRouterProtocol, updateUseCase: UpdateMedicineUseCaseProtocol, medical: Medical) {
        self.medicalItem = medicalItem
        self.view = view
        self.updateUseCase = updateUseCase
        self.router = router
        self.medical = medical
    }
    var status: Bool {
        medicalItem.status
    }

    func numberOfSection() -> Int {
        return sections.count
    }

    func numberOfSectionRows(at section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func buildSections() {

        sections = []
        let dashBoardData: [MedicineLog] = PdfExportUseCase().fetchLog(medicine: medicalItem)
        let takenCount = dashBoardData.count(where:{
            $0.status
        })
        let missedCount = dashBoardData.count - takenCount
        
        var infoRow: [DetailMedicalRow] = []
        
        infoRow.append(.info(.init(title: "Name", value: medicalItem.name)))
        infoRow.append(.info(.init(title: "Type", value: medicalItem.kind.rawValue)))
        infoRow.append(.info(.init(title: "Instruction", value: medicalItem.instruction.value)))
        infoRow.append(.info(.init(title: "Dosage", value: medicalItem.dosage)))
        infoRow.append(.info(.init(title: "Schedules", value: medicalItem.shedule.dbValue)))
        infoRow.append(.info(.init(title: "Start Date", value: medicalItem.startDate.toString())))
        infoRow.append(.info(.init(title: "Status", value: "")))
        if let endDate = medicalItem.endDate {
            infoRow.append(.info(.init(title: "End Date", value: endDate.toString())))
        }
        
        sections.append(.init(title: "Info", rows: infoRow))
        
        let chartSegment: [ChartSegment] = [
            .init(label: "Taken", value: takenCount, color: UIColor(red: 0.26, green: 0.78, blue: 0.68, alpha: 1)),
            .init(label: "Missed", value: missedCount, color: UIColor(red: 0.93, green: 0.04, blue: 0.47, alpha: 1)),
        ]
        let chartRow: [DetailMedicalRow] = [.dashBoard(chartSegment)]
        sections.append(.init(title: "Logs", rows: chartRow))
        var missedRow: [DetailMedicalRow] = [.missed(dashBoardData)]
        sections.append(.init(title: "Missed Schedule", rows: missedRow))
    }
    
    func section(at indexPath: IndexPath) -> DetailMedicalRow {
        return sections[indexPath.section].rows[indexPath.row]
    }
    
    func getTitle(for section: Int) -> String? {
        return sections[section].title
    }
    
    func viewDidLoad() {
        buildSections()
    }
    func setStatus(value: Bool) {
        let date: Date? = value ? nil  : Date().end
        medicalItem.setStatus(value: value, date: date)
        updateUseCase.execute(medicineId: medicalItem.id, value: value, date: date)
        buildSections()
        view?.reloadData()
    }
    func updateMedicine(updated: Medicine) {
        medicalItem.update(kind: updated.kind, name: updated.name, instruction: updated.instruction, dosage: updated.dosage, shedule: updated.shedule, startDate: updated.startDate)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            updateUseCase.execute(medicine: medicalItem)
            buildSections()
            view?.reloadData()
        }

    }
    func editButtonClicked() {
        router.openEditMedicalVC(mode: .edit(medicalItem), medical: medical, kind: medicalItem.kind, startDate: medicalItem.startDate) { [weak self] updatedMedicine in
            guard let self = self else { return }
            updateMedicine(updated: updatedMedicine as! Medicine)
            //view?.showToastVC(message: "Data modified successfully", type: .success)
            //view?.updateMedicine(updatedMedicine)
        }
    }
}
