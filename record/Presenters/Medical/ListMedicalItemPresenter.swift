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
}

class ListMedicalItemPresenter: ListMedicalItemPresenterProtocol {
        
    weak var view: ListMedicalItemViewDelegate?
    
    let router: ListMedicalItemRouterProtocol
    
    let kind: MedicalKind
    
    var title: String {
        kind.rawValue
    }
    var selectedDate = Date() 
    
    var selectedSchedule: MedicalSchedule?
    
    let addUseCase: AddMedicalItemUseCaseProtocol
    let updateUseCase: UpdateMedicalItemUseCaseProtocol
    let deleteUseCase: DeleteMedicalItemUseCaseProtocol
    let fetchUseCase: FetchMedicalItemUseCaseProtocol
    
    let addLogUseCase: AddLogUseCaseProtocol
    let updateLogUseCase: UpdateLogUseCaseProtocol
    let fetchLogUseCase: FetchLogUseCaseProtocol
    
    
    var medicalItems: [MedicalItem] = []
    var visibleItems: [MedicalItem] = []
    
    var logs: [MedicalIntakeLog] = []
    var medical: Medical
    var startDate: Date {medical.startDate }
    var endDate: Date {medical.endDate}
    
    var canEdit: Bool {
        return selectedSchedule == nil
    }
    init(view: ListMedicalItemViewDelegate? = nil, router: ListMedicalItemRouterProtocol, kind: MedicalKind, addUseCase: AddMedicalItemUseCaseProtocol, updateUseCase: UpdateMedicalItemUseCaseProtocol, deleteUseCase: DeleteMedicalItemUseCaseProtocol, fetchUseCase: FetchMedicalItemUseCaseProtocol, medical: Medical, addLogUseCase: AddLogUseCaseProtocol, updateLogUseCase: UpdateLogUseCaseProtocol, fetchLogUseCase: FetchLogUseCaseProtocol) {
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
    }
}

extension ListMedicalItemPresenter {
    
    func numberOfRows() -> Int {
        return visibleItems.count
    }
    
    func medicalItem(at index: Int) ->  MedicalItem {
        return visibleItems[index]
    }
    
    func medicalItemViewModel(at index: Int) -> MedicalItemCellViewModel {
        return makeViewModel(medicalItem: medicalItem(at: index))
    }
    
    func loadMedicalItems() {
        medicalItems = fetchUseCase.execute(id: medical.id, kind: kind)
    }
    
    func loadLogs() {
        var temp: [MedicalIntakeLog] = []
        print(medicalItems.count)
        let date = Calendar.current.startOfDay(for: selectedDate)
        for item in self.medicalItems {
            temp += fetchLogUseCase.execute(medicalId: item.id, date: date)
        }
        logs = temp
        for log in self.logs {
            print(log.id, log.medicalItemId, log.date.toString(), log.taken)
        }
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
    
    func addMedicalItem(_ medicalItem: MedicalItem) {
        addUseCase.execute(medicalItem: medicalItem, medicalId: medical.id)
        reloadItems()
    }
    
    func updateMedicalItem(_ medicalItem: MedicalItem) {
        updateUseCase.execute(medicalItem: medicalItem)
        reloadItems()
    }
    
    func deleteMedicalItem(at index: Int) {
        let medicalItem = medicalItem(at: index)
        deleteUseCase.execute(id: medicalItem.id)
        reloadItems()
    }
    
    func updateEndDate(at index: Int) {
        let medicalItem = medicalItem(at: index)
        updateUseCase.execute(medicalItemId: medicalItem.id, date: Calendar.current.startOfDay(for: selectedDate))
    }
    
    func editMedicalItem(at index: Int) {
        let medicalItem = medicalItem(at: index)
        router.openEditMedicalItemVC(mode: .edit(medicalItem), medicalId: medical.id, kind: medicalItem.kind, startDate: selectedDate) { [weak self] updatedMedicalItem in
            self?.updateMedicalItem(updatedMedicalItem as! MedicalItem)
        }

    }
    
    func gotoAddMedicalItemScreen() {
        router.openAddMedicalItemVC(mode: .add, medicalId: medical.id, kind: kind, startDate: selectedDate) { [weak self] medicalItem in
            self?.addMedicalItem(medicalItem as! MedicalItem)
        }

    }
}


extension ListMedicalItemPresenter {
    
    func makeViewModel(medicalItem: MedicalItem) -> MedicalItemCellViewModel {
        
        let isTaken = logs.first {
            $0.medicalItemId == medicalItem.id &&
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate) &&
            $0.schedule == selectedSchedule
        }?.taken ?? false
        return .init(id: medicalItem.id, text1: medicalItem.name, text2: medicalItem.instruction.value, text3: medicalItem.dosage, canShowToggle: selectedSchedule != nil, toggled: isTaken)
    }

    
    private func isItemActiveOnSelectedDate(_ item: MedicalItem) -> Bool {

        let calendar = Calendar.current

        let start = calendar.startOfDay(for: item.startDate)
        let end = calendar.startOfDay(for: item.endDate ?? endDate)
        let selected = calendar.startOfDay(for: selectedDate)

        return selected >= start && selected <= end
    }

    private func buildVisibleItems() {

        var filtered = medicalItems.filter { isItemActiveOnSelectedDate($0) }

        if let selectedSchedule {
            filtered = filtered.filter { $0.shedule.contains(selectedSchedule) }
        }

        filtered.sort { $0.name < $1.name }

        visibleItems = filtered

    }
    
    func itemToggledAt(_ index: Int, value: Bool) {
        guard let selectedSchedule else {return}
        let item = visibleItems[index]
        let calendar = Calendar.current
        let selected = Calendar.current.startOfDay(for: selectedDate)

        let log = logs.first { log in
            let sameItem = log.medicalItemId == item.id
            let sameDay = calendar.isDate(log.date, inSameDayAs: selected)
            let sameSchedule = log.schedule == selectedSchedule

            return sameItem && sameDay && sameSchedule
        }
        
        if let existing = log {
            let updated = MedicalIntakeLog(
                id: existing.id,
                medicalItemId: item.id,
                date: selected,
                schedule: selectedSchedule,
                taken: value
            )

            updateLogUseCase.execute(log: updated)

        } else {
            let newLog = MedicalIntakeLog(
                id: 0,
                medicalItemId: item.id,
                date: selected,
                schedule: selectedSchedule,
                taken: value
            )

            addLogUseCase.execute(log: newLog)

        }
        loadLogs()
        buildVisibleItems()
        view?.reloadData()
    }

}
