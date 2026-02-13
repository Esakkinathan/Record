//
//  ListUtilityAccountPresenter.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//

class ListUtilityAccountPresenter: ListUtilityAccountPresenterProtocol {
    
    var title: String {
        utility.name
    }
    
    weak var view: ListUtilityAccountViewDelegate?
    
    let addUseCase: AddUtilityAccountUseCaseProtocol
    let updateUseCase: UpdateUtilityAccountUseCaseProtocol
    let deleteUseCase: DeleteUtilityAccountUseCaseProtocol
    let fetchUseCase: FetchUtilityAccountUseCaseProtocol
    let updateNotesUseCase: UpdateUtilityAccountNotesUseCaseProtocol
    let router: ListUtilityAccountRouterProtocol
    let utility: Utility
    var utilityAccounts: [UtilityAccount] = []

    init(view: ListUtilityAccountViewDelegate? = nil, addUseCase: AddUtilityAccountUseCaseProtocol, updateUseCase: UpdateUtilityAccountUseCaseProtocol, deleteUseCase: DeleteUtilityAccountUseCaseProtocol, updateNotesUseCase: UpdateUtilityAccountNotesUseCaseProtocol, fetchUseCase: FetchUtilityAccountUseCaseProtocol, router: ListUtilityAccountRouterProtocol, utility: Utility) {
        self.view = view
        self.addUseCase = addUseCase
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.fetchUseCase = fetchUseCase
        self.updateNotesUseCase = updateNotesUseCase
        self.router = router
        self.utility = utility
    }
    
    func viewDidLoad() {
        loadUtilityAccounts()
    }
    
    func loadUtilityAccounts() {
        utilityAccounts = fetchUseCase.execute(utilityId: utility.id)
    }
    
    func numberOfRows() -> Int {
        return utilityAccounts.count
    }

    func reloadDataAndView() {
        loadUtilityAccounts()
        view?.reloadData()
    }
    
    func utilityAccount(at index: Int) -> UtilityAccount {
        return utilityAccounts[index]
    }
    
    func addUtilityAccount(utilityAccount: UtilityAccount) {
        addUseCase.execute(utilityAccount: utilityAccount)
        reloadDataAndView()
    }

    func updateUtilityAccount(utilityAccount: UtilityAccount) {
        updateUseCase.execute(utilityAccount: utilityAccount)
        reloadDataAndView()
    }
    func updateNotes(text: String?, id: Int) {
        updateNotesUseCase.execute(text: text, id: id)
    }
    func deleteUtilityAccount(at index: Int) {
        let utilityAccount = utilityAccount(at: index)
        deleteUseCase.execute(id: utilityAccount.id)
        reloadDataAndView()
    }
    
    
    func editUtilityAccount(at index: Int) {
        let utilityAccount = utilityAccount(at: index)
        router.openAddUtilityAccountVC(mode: .edit(utilityAccount), utility: utility) { [weak self] persistable in
            self?.updateUtilityAccount(utilityAccount: persistable as! UtilityAccount)
        }

    }
    
    func gotoAddUtilityAccountScreen() {
        router.openAddUtilityAccountVC(mode: .add, utility: utility){ [weak self] persistable in
            self?.addUtilityAccount(utilityAccount: persistable as! UtilityAccount)
        }

    }
    func didSelectedRow(at index: Int) {
        let utilityAccount = utilityAccount(at: index)
        router.openDetailUtilityAccountVC(utilityAccount: utilityAccount, utility: utility,
                                          onUpdate: { [weak self] updatedUtilityAccount in
            self?.updateUtilityAccount(utilityAccount: updatedUtilityAccount)
        }) { [weak self] text, id in
            self?.updateNotes(text: text, id: id)
        }
    }
}
