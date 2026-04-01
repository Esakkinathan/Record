//
//  DetailMedicalItemPresenter.swift
//  record
//
//  Created by Esakkinathan B on 26/02/26.
//

import UIKit

class DetailMedicalItemPresenter: DetailMedicalItemPresenterProtocol {
    var selectedDate: Date {
        date
    }
    
    
    var title: String {
        medicalItem.name
    }
    
    var medicalItem: Medicine
    weak var view: DetailMedicalItemViewDelegate?
    var sections: [DetailMedicalSection] = []
    var updateUseCase: UpdateMedicineUseCaseProtocol
    let router: DetailMedicineRouterProtocol
    let medical: Medical
    let date: Date
    var logStatus: [LogStatus] = []
    let addLogUseCase: AddLogUseCaseProtocol
    let updateLogUseCase: UpdateLogUseCaseProtocol
    let fetchLogUseCase: FetchLogUseCaseProtocol
    
    var logs: [MedicineIntakeLog] = []
    var dashBoardData: [MedicineLog]

    init(view: DetailMedicalItemViewDelegate? = nil, medicalItem: Medicine, router: DetailMedicineRouterProtocol, updateUseCase: UpdateMedicineUseCaseProtocol, medical: Medical, date: Date, addLogUseCase: AddLogUseCaseProtocol, updateLogUseCase: UpdateLogUseCaseProtocol, fetchLogUseCase: FetchLogUseCaseProtocol) {
        self.medicalItem = medicalItem
        self.view = view
        self.updateUseCase = updateUseCase
        self.router = router
        self.medical = medical
        self.date = date
        //self.logStatus = logStatus
        self.updateLogUseCase = updateLogUseCase
        self.addLogUseCase = addLogUseCase
        self.fetchLogUseCase = fetchLogUseCase
        dashBoardData = PdfExportUseCase().fetchLog(medicine: medicalItem)
        
    }
    var status: Bool {
        medicalItem.status
    }

    func numberOfSection() -> Int {
        return sections.count
    }
    
    func loadLogStatus() {
        var logsStatus: [LogStatus] = []
        for schedule in medicalItem.shedule {
            logsStatus.append(.init(schedule: schedule, taken: isTaken(schedule: schedule)))
        }
        logStatus = logsStatus
    }
    func isTaken(schedule: MedicalSchedule) -> Bool {
        return logs.first {
            $0.schedule == schedule
        }?.taken ?? false
    }
    func numberOfSectionRows(at section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func buildSections() {

        sections = []
        let takenCount = dashBoardData.count(where:{
            $0.status
        })
        let missedCount = dashBoardData.count - takenCount
        
        var infoRow: [DetailMedicalRow] = []
        
        infoRow.append(.info(.init(title: "Name", value: medicalItem.name)))
        infoRow.append(.info(.init(title: "Type", value: medicalItem.kind.rawValue)))
        infoRow.append(.info(.init(title: "Instruction", value: medicalItem.instruction.value)))
        infoRow.append(.info(.init(title: "Dosage", value: medicalItem.dosage)))
        infoRow.append(.info(.init(title: "Start Date", value: medicalItem.startDate.toString())))
        infoRow.append(.info(.init(title: "Status", value: "")))
        
        if let endDate = medicalItem.endDate {
            infoRow.append(.info(.init(title: "End Date", value: endDate.toString())))
        }
        
        sections.append(.init(title: "Info", rows: infoRow))
        sections.append(.init(title: "Medicine Schedules for \(date.toString())", rows: [.logStatus]))
        let chartSegment: [ChartSegment] = [
            .init(label: "Taken", value: takenCount, color: UIColor(red: 0.26, green: 0.78, blue: 0.68, alpha: 1)),
            .init(label: "Missed", value: missedCount, color: UIColor(red: 0.93, green: 0.04, blue: 0.47, alpha: 1)),
        ]
        let chartRow: [DetailMedicalRow] = [.dashBoard(chartSegment)]
        sections.append(.init(title: "Total Logs", rows: chartRow))
        
        let missedDashBoardData = dashBoardData.filter {
            !$0.status
        }
        
        let missedRow: [DetailMedicalRow] = [.missed(missedDashBoardData)]
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
        loadLogs()
        loadLogStatus()
    }
    
    func loadLogs() {
        logs = fetchLogUseCase.execute(medicalId: medicalItem.id, date: date)
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
            
            loadLogStatus()
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
    func changeLogStatus(_ logState: LogStatus) {
        print("presenter")
        logStatus.removeAll(where: {
            $0.schedule == logState.schedule
        })
        logStatus.append(logState)
        let log = logs.first { log in
            let sameSchedule = log.schedule == logState.schedule
            return sameSchedule
        }
        
        if let existing = log {
            let updated = MedicineIntakeLog(
                id: existing.id,
                medicineId: medicalItem.id,
                date: date,
                schedule: logState.schedule,
                taken: logState.taken
            )

            updateLogUseCase.execute(log: updated)

        } else {
            let newLog = MedicineIntakeLog(
                id: 0,
                medicineId: medicalItem.id,
                date: date,
                schedule: logState.schedule,
                taken: logState.taken
            )
            addLogUseCase.execute(log: newLog)
        }
        removeDashBoardData(logState: logState)
        loadLogs()
        loadLogStatus()
        buildSections()
        view?.reloadData()
    }
    
    func removeDashBoardData(logState: LogStatus) {
        let index = dashBoardData.firstIndex(where: {
            $0.date.start == date.start && $0.schedule == logState.schedule
        })
        
        if let index = index {
            dashBoardData.remove(at: index)
            dashBoardData.insert(.init(date: date, schedule: logState.schedule, name: medicalItem.name, status: logState.taken), at: index)
        }
        
    }
}
