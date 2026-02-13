//
//  ListUtilityViewController.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//


class ListUtilityPresenter: ListUtilityPresenterProtocol {
    var title: String {
        "Utility"
    }
    weak var view: ListUtilityViewDelegate?
    
    let addUseCase: AddUtilityUseCaseProtocol
    let updateUseCase: UpdateUtilityUseCaseProtocol
    let deleteUseCase: DeleteUtilityUseCaseProtocol
    let fetchUseCase: FetchUtilityUseCaseProtocol

    let router: ListUtilityRouterProtocol
    
    var utilities: [Utility] = []
    
    init(view: ListUtilityViewDelegate? = nil, addUseCase: AddUtilityUseCaseProtocol, updateUseCase: UpdateUtilityUseCaseProtocol, deleteUseCase: DeleteUtilityUseCaseProtocol, fetchUseCase: FetchUtilityUseCase, router: ListUtilityRouterProtocol) {
        self.view = view
        self.addUseCase = addUseCase
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.fetchUseCase = fetchUseCase
        self.router = router
    }
    func viewDidLoad() {
        loadUtilities()
    }

    func loadUtilities() {
        utilities = fetchUseCase.execute()
    }
    
    func numberOfRows() -> Int {
        return utilities.count
    }
    
    func reLoadDataAndView() {
        loadUtilities()
        view?.reloadData()
    }
    func utility(at index: Int) -> Utility {
        return utilities[index]
    }
    
    func addUtility(utility: Utility) {
        addUseCase.execute(utility: utility)
        reLoadDataAndView()
    }
    
    func deleteUtility(at index: Int) {
        let utility = utility(at: index)
        deleteUseCase.execute(id: utility.id)
        reLoadDataAndView()
    }
    func updateUtility(utility: Utility) {
        updateUseCase.execute(utility: utility)
        reLoadDataAndView()
    }
    func editUtility(at index: Int) {
        let utility = utility(at: index)
        router.openAddUtilityVC(mode: .edit(utility)){ [weak self] persistable in
            self?.updateUtility(utility: persistable as! Utility)
        }

    }
    
    func gotoAddUtilityScreen() {
        router.openAddUtilityVC(mode: .add){ [weak self] persistable in
            self?.addUtility(utility: persistable as! Utility)
        }
    }
    
    func didSelectedRow(at index: Int) {
        let utility = utility(at: index)
        router.openListUtilityAccountVC(utility: utility)
    }
    
    
    
}
