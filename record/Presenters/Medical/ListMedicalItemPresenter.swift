//
//  ListMedicalItemPresenter.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//

class ListMedicalItemPresenter: ListMedicalItemPresenterProtocol {
        
    weak var view: ListMedicalItemViewDelegate?
    
    let router: ListMedicalItemRouterProtocol
    
    let kind: MedicalKind
    
    var title: String {
        kind.rawValue
    }
    
    let addUseCase: AddMedicalItemUseCase
    let updateUseCase: UpdateMedicalItemUseCase
    let deleteUseCase: DeleteMedicalItemUseCase
    let fetchUseCase: FetchMedicalItemUseCase
    
    var medicalItems: [MedicalItem] = []
    
    var medical: Medical
    init(view: ListMedicalItemViewDelegate? = nil, router: ListMedicalItemRouterProtocol, kind: MedicalKind, addUseCase: AddMedicalItemUseCase, updateUseCase: UpdateMedicalItemUseCase, deleteUseCase: DeleteMedicalItemUseCase, fetchUseCase: FetchMedicalItemUseCase, medical: Medical) {
        self.view = view
        self.router = router
        self.kind = kind
        self.addUseCase = addUseCase
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.fetchUseCase = fetchUseCase
        self.medical = medical
        
    }
    
    func viewDidLoad() {
        loadMedicalItems()
    }
}

extension ListMedicalItemPresenter {
    
    func numberOfRows() -> Int {
        return medicalItems.count
    }
    
    func medicalItem(at index: Int) -> MedicalItem {
        return medicalItems[index]
    }
    
    func loadMedicalItems() {
        medicalItems = fetchUseCase.execute(id: medical.id, kind: kind)
    }
    
    func refreshMedicalInfoSection() {
        loadMedicalItems()
        view?.reloadData()
    }
    
    func addMedicalItem(_ medicalItem: MedicalItem) {
        addUseCase.execute(medicalItem: medicalItem, medicalId: medical.id)
        refreshMedicalInfoSection()
    }
    
    func updateMedicalItem(_ medicalItem: MedicalItem) {
        updateUseCase.execute(medicalItem: medicalItem)
        refreshMedicalInfoSection()
    }
    
    func deleteMedicalItem(at index: Int) {
        let medicalItem = medicalItems[index]
        deleteUseCase.execute(id: medicalItem.id)
        refreshMedicalInfoSection()
    }
    
    func editMedicalItem(at index: Int) {
        let medicalItem = medicalItems[index]
        router.openEditMedicalItemVC(mode: .edit(medicalItem), medicalId: medical.id, kind: medicalItem.kind) { [weak self] updatedMedicalItem in
            self?.updateMedicalItem(updatedMedicalItem)
        }

    }
    
    func gotoAddMedicalItemScreen() {
        router.openAddMedicalItemVC(mode: .add, medicalId: medical.id, kind: kind) { [weak self] medicalItem in
            self?.addMedicalItem(medicalItem)
        }

    }
    
    
}
