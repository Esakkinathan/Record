//
//  Untitled.swift
//  record
//
//  Created by Esakkinathan B on 08/02/26.
//


struct ActiveTreatement {
    let title: String
    let summary: String
}

import Foundation
class ListMedicalPresenter: ListMedicalPresenterProtocol {
    func dateChangedForOverview(date: Date? = nil) {
        if let date = date {
            dashBoardSelectedDate = date
        }
        print("at presenter \(dashBoardSelectedDate.toString())")

        let data = ActiveMedicalUseCase().execute(date: dashBoardSelectedDate)
        view?.showOverviewSummary(data: data, date: dashBoardSelectedDate)
    }
    
    var total: Int {
        return allMedicals.count
    }
    var title: String {
        "Health Record"
    }
    var isSelectionMode = false
    var selectedIndexes: Set<Int> = []

    var dashBoardSelectedDate: Date = Date()
    weak var view: ListMedicalViewDelegate?
    let router: ListMedicalRouterProtocol
    
    let addUseCase: AddMedicalUseCaseProtocol
    let updateUseCase: UpdateMedicalUseCaseProtocol
    let deleteUseCase: DeleteMedicalUseCaseProtocol
    let fetchUseCase: FetchMedicalUseCaseProtocol
    let updateNotesUseCase: UpdateMedicalNotesUseCaseProtocol

    var searchText: String?
    var currentSort: MedicalSortOption
    
    var allMedicals: [Medical] = []
//    var categoryFiltered: [Medical] = []
//    var searchFiltered: [Medical] = []
//    var finalMedicals: [Medical] = []
    
    private var limit = 20
    private var offset = 0
    private var isLoading = false
    private var hasMoreData = true

    var isEmpty: Bool {
        allMedicals.isEmpty
    }
    var isSearching: Bool = false 

    var selectedType: MedicalType?
    
    init(view: ListMedicalViewDelegate? = nil,
         router: ListMedicalRouterProtocol,
         addUseCase: AddMedicalUseCaseProtocol,
         updateUseCase: UpdateMedicalUseCaseProtocol,
         deleteUseCase: DeleteMedicalUseCaseProtocol,
         fetchUseCase: FetchMedicalUseCaseProtocol,
         updateNotesUseCase: UpdateMedicalNotesUseCase,) {
        self.view = view
        self.router = router
        self.addUseCase = addUseCase
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.fetchUseCase = fetchUseCase
        self.updateNotesUseCase = updateNotesUseCase
        currentSort = MedicalSortStore.load()
        
    }
    
    func viewDidLoad() {
        loadMedical()
    }
    
//    func getActiveSummary() -> DashboardViewModel {
//        let summary = ActiveMedicalUseCase().execute()
//        return summary
//    }
    
    func numberOfRows() -> Int {
        return allMedicals.count
    }
    
}

extension ListMedicalPresenter {
    
    func medical(at index: Int) -> Medical {
        return allMedicals[index]
    }
    
    func addMedical(_ medical: Medical) {
        addUseCase.execute(medical: medical)
        loadMedical()
    }

    func updateMedical(medical: Medical) {
        updateUseCase.execute(medical: medical)
        loadMedical()
    }
    
    func deleteMedical(at index: Int) {
        let medical = medical(at: index)
        deleteUseCase.execute(id: medical.id)
        if let receipt = medical.receipt {
            AppFileManager().removeFile(name: receipt, type: .medicalReciept)
        }
        NotificationManager.shared.syncMedicalNotifications()
        loadMedical()
        view?.reloadSumary()
        view?.showToastVC(message: "Data deleted successfully", type: .success)
    }
    
        
//    func loadMedical() {
//        allMedicals = fetchUseCase.execute()
//        rebuildList()
//    }
    
    func loadMedical(reset: Bool = true) {
        if reset {
            offset = 0
            hasMoreData = true
            allMedicals.removeAll()
        }
        guard !isLoading, hasMoreData else { return }
        isLoading = true
        let result = fetchUseCase.fetchMedical(limit: limit, offset: offset, sort: currentSort, category: selectedType, searchText: searchText)

        if result.count < limit {
            hasMoreData = false
        }
        allMedicals.append(contentsOf: result)
        offset += result.count
        isLoading = false
        view?.refreshSortMenu()
        view?.reloadData()
    }
    
    func updateNotes(text: String?, id: Int) {
        updateNotesUseCase.execute(text: text,id: id)
        loadMedical()
    }
    
    func deleteClicked(at index: Int) {
        view?.showAlertOnDelete(at: index)
    }
    
}

extension ListMedicalPresenter {
    func search(text: String?) {
        searchText = text
        isSearching = !(text?.isEmpty ?? true)
        loadMedical(reset: true)
    }
}

extension ListMedicalPresenter {
    
    func updateSortLogic(_ field: MedicalSortField) {
        if currentSort.field == field {
            currentSort = MedicalSortOption(field: field, direction: currentSort.direction == .ascending ? .descending : .ascending)
        } else {
            currentSort = MedicalSortOption(field: field, direction: .ascending)
        }
        MedicalSortStore.save(currentSort)
    }
    func didSelectSortField(_ field: MedicalSortField) {
        updateSortLogic(field)
        loadMedical(reset: true)
    }
    
    func didSelectCategory(_ text: String) {
        selectedType = MedicalType(rawValue: text)
        loadMedical(reset: true)
    }
    
}

extension ListMedicalPresenter {
    func didSelectedRow(at index: Int) {
        let medical = medical(at: index)
        router.openDetailMedicalVC(medical: medical)
    }
    
    func gotoAddMedicalScreen() {
        router.openAddMedicalVC(mode: .add) { [weak self] newMedical in
            self?.addMedical(newMedical as! Medical)
            self?.view?.showToastVC(message: "Data added successfully", type: .success)
        }
    }

}
extension ListMedicalPresenter {
    func toggleSelection(at index: Int) {
        let medicalId = medical(at: index).id
        if selectedIndexes.contains(medicalId) {
            selectedIndexes.remove(medicalId)
        } else {
            selectedIndexes.insert(medicalId)
        }
    }
    
    func clearSelection() {
        selectedIndexes.removeAll()
        //isSelectionMode = false
    }
    func deleteMedical(_ medical: Medical) {
        deleteUseCase.execute(id: medical.id)
    }
    func deleteMultiple() {
        if selectedIndexes.isEmpty {
            view?.showToastVC(message: "No records selected", type: .error)
            return
        }
        let medicals = selectedMedicals()
        if medicals.isEmpty {
            view?.showToastVC(message: "No records selected", type: .error)
            return
        }
        view?.showAlertOnDelete(medicals)
        
        //medicals.forEach { self.deleteMedical($0) }
        //self.clearSelection()
    }

    func selectedMedicals() -> [Medical] {
        return allMedicals.filter { selectedIndexes.contains($0.id) }
    }


}
/*
 var sortComparator: (Medical, Medical) -> Bool {
     return { lhs, rhs in
         switch self.currentSort.field {
         case .title:
             return self.currentSort.direction == .ascending
             ? lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
             : lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedDescending
             
         case .createdAt:
             return self.currentSort.direction == .ascending
             ? lhs.date > rhs.date
             : lhs.date < rhs.date
             
         case .updatedAt:
             return self.currentSort.direction == .ascending
             ? lhs.lastModified > rhs.lastModified
             : lhs.lastModified < rhs.lastModified
         }
     }
 }

 func rebuildList() {
     if let type = selectedType {
         categoryFiltered = allMedicals.filter { $0.type == type }
     } else {
         categoryFiltered = allMedicals
     }
     
     
     if let text = searchText, !text.isEmpty {
         isSearching = true
         let value = text.prepareSearchWord()
         searchFiltered = categoryFiltered.filter {
             $0.title.filterForSearch(value) ||
             $0.type.rawValue.filterForSearch(value)
         }
     } else {
         isSearching = false
         searchFiltered = categoryFiltered
     }
     
     finalMedicals = searchFiltered.sorted(by: sortComparator)
     
     view?.refreshSortMenu()
     view?.reloadData()
 }

 */
