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
        
    var title: String {
        "Health Records"
    }
    
        
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
    var categoryFiltered: [Medical] = []
    var searchFiltered: [Medical] = []
    var finalMedicals: [Medical] = []
    
    var isEmpty: Bool {
        finalMedicals.isEmpty
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
    
    func getActiveSummary() -> DashBoardData {
        let summary = ActiveMedicalUseCase().execute(medical: allMedicals)
        return summary
    }

    func currentMedical() -> [Medical]{
        return finalMedicals
    }
    
    func numberOfRows() -> Int {
        return currentMedical().count
    }
    
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


}

extension ListMedicalPresenter {
    
    func medical(at index: Int) -> Medical {
        return currentMedical()[index]
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
        let medical = currentMedical()[index]
        deleteUseCase.execute(id: medical.id)
        loadMedical()
    }
    
        
    func loadMedical() {
        allMedicals = fetchUseCase.execute()
        rebuildList()

    }
    
    func updateNotes(text: String?, id: Int) {
        updateNotesUseCase.execute(text: text,id: id)
        loadMedical()
    }
    
}

extension ListMedicalPresenter {
    func search(text: String?) {
        searchText = text
        rebuildList()
    }
}

extension ListMedicalPresenter {
    
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

    
    func didSelectSortField(_ field: MedicalSortField) {
        if currentSort.field == field {
            currentSort = MedicalSortOption(field: field, direction: currentSort.direction == .ascending ? .descending : .ascending)
        } else {
            currentSort = MedicalSortOption(field: field, direction: .ascending)
        }
        MedicalSortStore.save(currentSort)
        rebuildList()
    }
    
    func didSelectCategory(_ text: String) {
        selectedType = MedicalType(rawValue: text)
        rebuildList()
    }
    
}

extension ListMedicalPresenter {
    func didSelectedRow(at index: Int) {
        let medical = medical(at: index)
        router.openDetailMedicalVC(medical: medical, onUpdate: { [weak self] updatedMedical in
            self?.updateMedical(medical: updatedMedical as! Medical)},
            onUpdateNotes: { [weak self] text, id in
            self?.updateNotes(text: text, id: id)
        })
    }
    
    func gotoAddMedicalScreen() {
        router.openAddMedicalVC(mode: .add) { [weak self] newMedical in
            self?.addMedical(newMedical as! Medical)
        }
    }

}
