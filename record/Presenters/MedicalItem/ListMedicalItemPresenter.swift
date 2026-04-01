//
//  ListMedicalItemPresenter.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
import UIKit

struct MedicalItemCellViewModel {
    let id: Int
    let text1: String
    let text2: String
    let text3: String
    let canShowToggle: Bool
    let toggled: Bool
    let schedules: [MedicalSchedule]
    let takenSchedule: Set<MedicalSchedule>
    let enabledSchedules: Set<MedicalSchedule>
}

class ListMedicalItemPresenter: ListMedicalItemPresenterProtocol {
    var endDate: Date? {
        medical.endDate
    }
    var isEmpty: Bool {
        visibleItems.isEmpty
    }
    var canAdd: Bool {
        medical.status
    }
    weak var view: ListMedicalItemViewDelegate?
    
    let router: ListMedicalItemRouterProtocol
    
    let kind: MedicalKind
    
    var title: String {
        kind.rawValue
    }
    var selectedDate: Date
    
    var selectedSchedule: MedicalSchedule?
    
    let addUseCase: AddMedicineUseCaseProtocol
    let updateUseCase: UpdateMedicineUseCaseProtocol
    let deleteUseCase: DeleteMedicineUseCaseProtocol
    let fetchUseCase: FetchMedicineUseCaseProtocol
    
    let addLogUseCase: AddLogUseCaseProtocol
    let updateLogUseCase: UpdateLogUseCaseProtocol
    let fetchLogUseCase: FetchLogUseCaseProtocol
    
    
    var medicalItems: [Medicine] = []
    var visibleItems: [Medicine] = []
    
    var logs: [MedicineIntakeLog] = []
    var medical: Medical
    var startDate: Date {medical.date }
    //var endDate: Date {medical.endDate}
    
    var canEdit: Bool {
        return selectedSchedule == nil
    }
    init(view: ListMedicalItemViewDelegate? = nil, router: ListMedicalItemRouterProtocol, kind: MedicalKind, addUseCase: AddMedicineUseCaseProtocol, updateUseCase: UpdateMedicineUseCaseProtocol, deleteUseCase: DeleteMedicineUseCaseProtocol, fetchUseCase: FetchMedicineUseCaseProtocol, medical: Medical, addLogUseCase: AddLogUseCaseProtocol, updateLogUseCase: UpdateLogUseCaseProtocol, fetchLogUseCase: FetchLogUseCaseProtocol) {
        self.view = view
        self.router = router
        self.kind = kind
        self.addUseCase = addUseCase
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.fetchUseCase = fetchUseCase
        self.medical = medical
        self.addLogUseCase = addLogUseCase
        self.updateLogUseCase = updateLogUseCase
        self.fetchLogUseCase = fetchLogUseCase
        self.selectedDate = medical.status ? Date().start : medical.endDate?.start ?? Date().start
    }
    
    func changeSelectedDate(_ date: Date) {
        selectedDate = date
        reLoadDataAndView()
    }
    
    func didSelectCategory(_ text: String) {
        selectedSchedule = MedicalSchedule(rawValue: text)
        buildVisibleItems()
        view?.reloadData()
    }

    func viewDidLoad() {
        loadMedicalItems()
        loadLogs()
        buildVisibleItems()
        view?.reloadData()
    }
}

extension ListMedicalItemPresenter {
    
    func numberOfRows() -> Int {
        return visibleItems.count
    }
    
    func medicalItem(at index: Int) ->  Medicine {
        return visibleItems[index]
    }
    
    func medicalItemViewModel(at index: Int) -> MedicalItemCellViewModel {
        return makeViewModel(medicine: medicalItem(at: index))
    }
    
    func loadMedicalItems() {
        medicalItems = fetchUseCase.execute(id: medical.id, kind: kind)
    }
    
    func loadLogs() {
        var temp: [MedicineIntakeLog] = []
        let date = Calendar.current.startOfDay(for: selectedDate)
        for item in self.medicalItems {
            temp += fetchLogUseCase.execute(medicalId: item.id, date: date)
        }
        logs = temp
    }
    
    func reloadItems() {
        loadMedicalItems()
        loadLogs()
        buildVisibleItems()
        view?.reloadData()
    }
    
    func reLoadDataAndView() {
        loadLogs()
        buildVisibleItems()
        view?.reloadData()
    }
    
    func addMedicalItem(_ medicine: Medicine) {
        addUseCase.execute(medicine: medicine, medicalId: medical.id)
        reloadItems()
    }
    
    func updateMedicalItem(_ medicine: Medicine) {
        updateUseCase.execute(medicine: medicine)
        reloadItems()
    }
    
    func deleteMedicalItem(at index: Int) {
        let medicalItem = medicalItem(at: index)
        deleteUseCase.execute(id: medicalItem.id)
        reloadItems()
        view?.showToastVC(message: "Data deleted successfully", type: .success)
    }
//    func canEdit(schedule: MedicalSchedule, for date: Date) -> Bool {
//        let calendar = Calendar.current
//        
//        let selectedDay = calendar.startOfDay(for: date)
//        let today = calendar.startOfDay(for: Date())
//        
//        if selectedDay != today {
//            return true
//        }
//        
//        let currentHour = calendar.component(.hour, from: Date())
//        
//        switch schedule {
//        case .morning:
//            return currentHour >= 7 
//        case .afternoon:
//            return currentHour >= 12
//        case .evening:
//            return currentHour >= 16
//        case .night:
//            return currentHour >= 19
//        }
//    }
    
    
    func canEdit(schedule: MedicalSchedule, for date: Date) -> Bool {
        let calendar = Calendar.current
        
        let selectedDay = calendar.startOfDay(for: date)
        let today       = calendar.startOfDay(for: Date())
        
        if selectedDay != today {
            return true
        }
        
        let currentHour = calendar.component(.hour, from: Date())
        let currentMin = calendar.component(.minute, from: Date())
        
        return currentHour >= SettingsManager.shared.scheduleTime(for: schedule).hour && currentMin >= SettingsManager.shared.scheduleTime(for: schedule).minute
        
    }
    
    func updateEndDate(at index: Int) {
        let medicine = medicalItem(at: index)
        let date = selectedDate.end
        medicine.setStatus(value: false, date: date)
        updateUseCase.execute(medicineId: medicine.id, value: false , date: date)
        reloadItems()
    }
    
    func editMedicalItem(at index: Int) {
        let medicalItem = medicalItem(at: index)
        router.openAddMedicalItemVC(mode: .edit(medicalItem), medical: medical, kind: medicalItem.kind, startDate: selectedDate.start) { [weak self] updatedMedicalItem in
            self?.updateMedicalItem(updatedMedicalItem as! Medicine)
        }

    }
    
    func gotoAddMedicalItemScreen() {
        router.openAddMedicalItemVC(mode: .add, medical: medical, kind: kind, startDate: selectedDate.start) { [weak self] medicalItem in
            self?.addMedicalItem(medicalItem as! Medicine)
            self?.view?.showToastVC(message: "Data added successfully", type: .success)
        }
    }
}


extension ListMedicalItemPresenter {
    
    func isTaken(medicine: Medicine, schedule: MedicalSchedule?) -> Bool {
        return logs.first {
            $0.medicineId == medicine.id &&
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate) &&
            $0.schedule == schedule
        }?.taken ?? false
    }
    
    func makeViewModel(medicine: Medicine) -> MedicalItemCellViewModel {
        let enabled = Set(medicine.shedule.filter {
            canEdit(schedule: $0, for: selectedDate)
        })
        let takenState = isTaken(medicine: medicine, schedule: selectedSchedule)
        guard let schedule = selectedSchedule else {
            return .init(id: medicine.id, text1: medicine.name, text2: medicine.instruction.value, text3: medicine.dosage, canShowToggle: true, toggled: takenState, schedules: medicine.shedule, takenSchedule: selectedSchedule == nil ? getTakenScheduleForMedicine(medicine: medicine): Set(), enabledSchedules: enabled)

        }
        return .init(id: medicine.id, text1: medicine.name, text2: medicine.instruction.value, text3: medicine.dosage, canShowToggle: canEdit(schedule: schedule, for: selectedDate), toggled: takenState, schedules: medicine.shedule, takenSchedule: selectedSchedule == nil ? getTakenScheduleForMedicine(medicine: medicine): Set(), enabledSchedules: enabled)
    }
    
    func getTakenScheduleForMedicine(medicine: Medicine) -> Set<MedicalSchedule> {
        return Set(logs.compactMap { log -> MedicalSchedule? in
            guard log.medicineId == medicine.id && log.taken else { return nil }
            return log.schedule
        })
    }
    
    private func isItemActiveOnSelectedDate(_ item: Medicine) -> Bool {

        let calendar = Calendar.current
        let selected = calendar.startOfDay(for: selectedDate)
        let start = calendar.startOfDay(for: item.startDate)
        guard let endDate = item.endDate else {
            return selected >= start
        }
        let end = calendar.startOfDay(for: endDate)
        print(start.toString(), end.toString(), selected.toString())
        return selected >= start &&  selected <= end
    }

    private func buildVisibleItems() {

        var filtered = medicalItems.filter { isItemActiveOnSelectedDate($0) }

        if let selectedSchedule {
            filtered = filtered.filter { $0.shedule.contains(selectedSchedule) }
        }

        filtered.sort { $0.name < $1.name }

        visibleItems = filtered

    }
    
    func markAsTaken(at index: Int, value: Bool) {
        let medicine = medicalItem(at: index)
        let calendar = Calendar.current
        let selected = selectedDate.start
        
        let todayLogs = logs.filter {
            $0.medicineId == medicine.id &&
            calendar.isDate($0.date, inSameDayAs: selected)
        }
        
        
        let newValue = value
        
        for schedule in medicine.shedule {
            
            guard canEdit(schedule: schedule, for: selected) else {
                continue
            }

            
            let log = todayLogs.first { $0.schedule == schedule }
            
            if let existing = log {
                let updated = MedicineIntakeLog(
                    id: existing.id,
                    medicineId: medicine.id,
                    date: selected,
                    schedule: schedule,
                    taken: newValue
                )
                
                updateLogUseCase.execute(log: updated)
                
            } else {
                let newLog = MedicineIntakeLog(
                    id: 0,
                    medicineId: medicine.id,
                    date: selected,
                    schedule: schedule,
                    taken: newValue
                )
                
                addLogUseCase.execute(log: newLog)
            }
        }
        
        loadLogs()
        buildVisibleItems()
        
        let message = newValue
            ? "\(medicine.name) marked as taken"
            : "\(medicine.name) marked as not taken"
        
        view?.showToastVC(message: message, type: newValue ? .success : .error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.view?.reloadData()
        }
    }
    
    func changeLogStatus(at index: Int, logStatus: LogStatus) {
        print("presenter executing")
        itemToggledAt(index, value: logStatus.taken, schedule: logStatus.schedule)
    }
    
    func itemToggledAt(_ index: Int, value: Bool) {
        itemToggledAt(index, value: value, schedule: selectedSchedule)
    }
    
    func itemToggledAt(_ index: Int, value: Bool, schedule: MedicalSchedule?) {
        guard let schedule else {return}
        guard canEdit(schedule: schedule, for: selectedDate) else {
            view?.showToastVC(message: "Cannot edit future schedule", type: .error)
            return
        }

        let item = medicalItem(at: index)
        let calendar = Calendar.current
        let selected = selectedDate.start

        let log = logs.first { log in
            let sameItem = log.medicineId == item.id
            let sameDay = calendar.isDate(log.date, inSameDayAs: selected)
            let sameSchedule = log.schedule == schedule

            return sameItem && sameDay && sameSchedule
        }
        
        if let existing = log {
            let updated = MedicineIntakeLog(
                id: existing.id,
                medicineId: item.id,
                date: selected,
                schedule: schedule,
                taken: value
            )

            updateLogUseCase.execute(log: updated)

        } else {
            let newLog = MedicineIntakeLog(
                id: 0,
                medicineId: item.id,
                date: selected,
                schedule: schedule,
                taken: value
            )

            addLogUseCase.execute(log: newLog)

        }
        loadLogs()
        buildVisibleItems()
        view?.reloadData()
    }
    
    func didSelectRow(at index: Int) {
        let medicine = medicalItem(at: index)
        router.openDetailMedicalItemVc(medicalItem: medicine, medical: medical, date: selectedDate)
        
    }
}
