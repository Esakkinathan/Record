//
//  Untitled.swift
//  record
//
//  Created by Esakkinathan B on 08/02/26.
//

class ListMedicalPresenter: ListMedicalPresenterProtocol {
    var title: String {
        "Medical Check-Up"
    }
    
        
    weak var view: ListMedicalViewDelegate?
    let router: ListMedicalRouterProtocol
    
    let addUseCase: AddMedicalUseCase
    let updateUseCase: UpdateMedicalUseCase
    let deleteUseCase: DeleteMedicalUseCase
    let fetchUseCase: FetchMedicalUseCase
    let updateNotesUseCase: UpdateMedicalNotesUseCase
    
    var medicalList: [Medical] = []
    var filteredMedical: [Medical] = []
    var isSearching = false
    var currentSort: DocumentSortOption?
    var visibleMedicals: [Medical] = []
    
    init(view: ListMedicalViewDelegate? = nil,
         router: ListMedicalRouterProtocol,
         addUseCase: AddMedicalUseCase,
         updateUseCase: UpdateMedicalUseCase,
         deleteUseCase: DeleteMedicalUseCase,
         fetchUseCase: FetchMedicalUseCase,
         updateNotesUseCase: UpdateMedicalNotesUseCase,) {
        self.view = view
        self.router = router
        self.addUseCase = addUseCase
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.fetchUseCase = fetchUseCase
        self.updateNotesUseCase = updateNotesUseCase
        
        loadMedical()
    }
    
    func viewDidLoad() {
        //
    }

    func currentMedical() -> [Medical]{
        return medicalList
    }
    
    func numberOfRows() -> Int {
        return currentMedical().count
    }

}

extension ListMedicalPresenter {
    func didSelectSortField(_ field: DocumentSortField) {
        //
    }
}

extension ListMedicalPresenter {
    
    func medical(at index: Int) -> Medical {
        return currentMedical()[index]
    }
    
    func addMedical(_ medical: Medical) {
        addUseCase.execute(medical: medical)
        loadMedical()
        view?.reloadData()
    }

    func updateMedical(medical: Medical) {
        updateUseCase.execute(medical: medical)
        loadMedical()
        view?.reloadData()
    }
    
    func deleteMedical(at index: Int) {
        let medical = currentMedical()[index]
        deleteUseCase.execute(id: medical.id)
        loadMedical()
        view?.reloadData()
    }
    
        
    func loadMedical() {
        medicalList = fetchUseCase.execute()
        //applySort()
    }
    
    func updateNotes(text: String?, id: Int) {
        updateNotesUseCase.execute(text: text,id: id)
        loadMedical()
        view?.reloadData()
    }
    
}

extension ListMedicalPresenter {
    func search(text: String?) {
        //
    }
}

extension ListMedicalPresenter {
    func didSelectedRow(at index: Int) {
        let medical = medical(at: index)
        router.openDetailMedicalVC(medical: medical, onUpdate: { [weak self] updatedMedical in
            self?.updateMedical(medical: updatedMedical)},
            onUpdateNotes: { [weak self] text, id in
            self?.updateNotes(text: text, id: id)
        })
    }
    
    func gotoAddMedicalScreen() {
        router.openAddMedicalVC(mode: .add) { [weak self] newMedical in
            self?.addMedical(newMedical)
        }
    }

}
