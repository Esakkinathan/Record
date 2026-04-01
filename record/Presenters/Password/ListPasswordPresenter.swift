//
//  ListPasswordPresenter.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

import Foundation

class ListPasswordPresenter: ListPasswordProtocol {
    weak var view: ListPasswordViewDelegate?
    let router: ListPasswordRouterProtocol
    
    let addUseCase: AddPasswordUseCase
    let updateUseCase: UpdatePasswordUseCase
    let deleteUseCase: DeletePasswordUseCase
    let fetchUseCase: FetchPasswordUseCase
    let updateNotesUseCase: UpdatePasswordNotesUseCase
    let toggleFavouriteUseCase: ToggleFavouriteUseCase
    var total: Int {
        return currentPassword().count
    }
    var isSelectionMode = false
    var selectedIndexes: Set<Int> = []

    var currentSort: PasswordSortOption
    var passwordList: [Password] = []
    var filteredRecords: [Password] = []
    var visibleRecords: [Password] = []
    var isSearching = false
    var isEmpty: Bool {
        return currentPassword().isEmpty
    }
    
    //var uiTimer: Timer?
    var autoExitTimer: Timer?
    //var remainingTime: Int = AppConstantData.passwordSession
    var sessionManager = PasswordSessionManager.shared
    var isFavoriteSelected = false
    
    init(view: ListPasswordViewDelegate? = nil, router: ListPasswordRouterProtocol, addUseCase: AddPasswordUseCase, updateUseCase: UpdatePasswordUseCase, deleteUseCase: DeletePasswordUseCase, fetchUseCase: FetchPasswordUseCase, updateNotesUseCase: UpdatePasswordNotesUseCase, toggleFavouriteUseCase: ToggleFavouriteUseCase) {
        self.view = view
        self.router = router
        self.addUseCase = addUseCase
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.fetchUseCase = fetchUseCase
        self.updateNotesUseCase = updateNotesUseCase
        self.toggleFavouriteUseCase =  toggleFavouriteUseCase
        currentSort = PasswordSortStore.load()
        
    }
    
    
    func toggleFavoritePassword(_ password: Password) {
        password.toggleFavorite()
        toggleFavouriteUseCase.execute(password)
        loadPasswords()
        didSelectedFavourite(reset: false)
        //view?.reloadData()
    }
    func toggleFavorite(_ password: Password) {
        toggleFavoritePassword(password)
        loadPasswords()
        didSelectedFavourite(reset: false)
        //view?.reloadData()
    }
    
    
    func numberOfPasswords() -> Int {
        return currentPassword().count
    }
    
    
    func password(at index: Int) -> Password {
        return currentPassword()[index]
    }
    
    func didSelectedRow(at index: Int) {
        let password = password(at: index)
        router.openDetailPasswordVC(password: password)
    }
}

extension ListPasswordPresenter {
    func addPassword(_ password: Password) {
        addUseCase.execute(password: password)
        loadPasswords()
    }
    
    func updatePassword(_ password: Password) {
        updateUseCase.execute(password: password)
        loadPasswords()

    }
    func deletePassword(index: Int) {
        let record = password(at: index)
        deleteUseCase.execute(id: record.id)
        loadPasswords()
        view?.showToastVC(message: "Data deleted successfully", type: .success)

    }
    
    func updateNotes(text: String?,id: Int) {
        updateNotesUseCase.execute(text: text, id: id)
        loadPasswords()

    }
        
    func loadPasswords() {
        self.passwordList = fetchUseCase.execute()
        applySort()
    }

    
}

extension ListPasswordPresenter {
    func exitClicked() {
        view?.showExitPrompt(expired: false)
        startAutoExitTimer()
    }
    
    func configureSession() {
        sessionManager.onTickUpdate = { [weak self] timeString in
            self?.view?.updateTimer(timeString)
        }

    }
    
    func startAutoExitTimer() {
        autoExitTimer?.invalidate()
        autoExitTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(AppConstantData.autoExitTime), repeats: false) { [weak self] _ in
            self?.exitPassoword()
        }
    }
    
    func stopAutoExitTimer() {
        autoExitTimer?.invalidate()
        autoExitTimer = nil
    }
//    func stopUITimer() {
//        uiTimer?.invalidate()
//        uiTimer = nil
//    }
    
    func viewDidLoad() {
        configureSession()
//        startUITimer()

    }
    func viewWillAppear() {
        loadPasswords()
    }
    
//    func startUITimer() {
//        remainingTime = Int(AppConstantData.passwordSession)
//        uiTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {  [weak self] _ in
//            self?.isExpired()
//        }
//    }
    
//    func isExpired() {
//        guard remainingTime > 0 else { return }
//        remainingTime -= 1
//        let min = remainingTime / 60
//        let sec = remainingTime % 60
//        view?.updateTimer(String(format: "%02d:%02d", min, sec))
//    }

    func exitPassoword() {
        stopAutoExitTimer()
        sessionManager.logout()
        view?.dismiss()
    }
    
    func extendSession() {
        stopAutoExitTimer()
        sessionManager.extendSession()
        //startUITimer()
    }

}
extension ListPasswordPresenter {
    func gotoAddPasswordScreen() {
        router.openAddPasswordVC(mode: .add) { [weak self] newPassword in
            self?.addPassword(newPassword as! Password)
            self?.view?.showToastVC(message: "Data added successfully", type: .success)
        }
    }

}

extension ListPasswordPresenter {
    func currentPassword() -> [Password] {
        return isSearching ?  filteredRecords : visibleRecords
    }
    
    func search(text: String?) {
        guard let text, !text.isEmpty else {
            isSearching = false
            filteredRecords = []
            view?.reloadData()
            return
        }
        
        isSearching = true
        let value = text.prepareSearchWord()
        filteredRecords = visibleRecords.filter {
            $0.title.filterForSearch(value) ||
            $0.username.filterForSearch(value)
        }
        view?.reloadData()
    }


}
extension ListPasswordPresenter {
    func didSelectSortField(_ field: PasswordSortField) {
        if currentSort.field == field {
            currentSort = PasswordSortOption(
                field: field,
                direction: currentSort.direction == .ascending ? .descending : .ascending
            )
        } else {
            currentSort = PasswordSortOption(field: field, direction: .ascending)
        }

        PasswordSortStore.save(currentSort)
        applySort()
    }
    func deleteClicked(at index: Int) {
        view?.showAlertOnDelete(at: index)
    }


    func didSelectedFavourite(reset: Bool = true) {
        if reset {
            isFavoriteSelected.toggle()
        }
        
        if isFavoriteSelected {
            visibleRecords = visibleRecords.filter { $0.isFavorite}
            view?.refreshSortMenu()
            view?.reloadData()
        } else {
            applySort(reset: true)
        }
    }

    func applySort(reset: Bool =  false) {
        isFavoriteSelected = false
        
        visibleRecords = passwordList
        
        visibleRecords.sort(by: { (lhs: Password, rhs: Password) -> Bool in
            switch currentSort.field {
                
            case .title:
                if currentSort.direction == .ascending {
                    return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
                } else {
                    return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedDescending
                }
                
            case .createdAt:
                if currentSort.direction == .ascending {
                    return lhs.createdAt > rhs.createdAt
                } else {
                    return lhs.createdAt < rhs.createdAt
                }
                
            case .updatedAt:
                if currentSort.direction == .ascending {
                    return lhs.lastModified > rhs.lastModified
                } else {
                    return lhs.lastModified < rhs.lastModified
                }
            }

        })

        view?.refreshSortMenu()
        view?.reloadData()

    }

}

extension ListPasswordPresenter {
    func toggleSelection(at index: Int) {
        let passwordId = password(at: index).id
        if selectedIndexes.contains(passwordId) {
            selectedIndexes.remove(passwordId)
        } else {
            selectedIndexes.insert(passwordId)
        }
    }
    func clearSelection() {
        selectedIndexes.removeAll()
        //isSelectionMode = false
    }
    func deletePassword(_ password: Password) {
        deleteUseCase.execute(id: password.id)
    }
    func deleteMultiple() {
        let passwords = selectedPasswords()
        if passwords.isEmpty {
            view?.showToastVC(message: "No passwords selected", type: .error)
            return
        }
        view?.showAlertOnDelete(passwords)
    }
    
    func selectedPasswords() -> [Password] {
        return visibleRecords.filter { selectedIndexes.contains($0.id) }
    }
    
    func updateFavouriteForSelected(lock: Bool) {
        let passwords = selectedPasswords()
        for password in passwords {
            if lock && !password.isFavorite {
                self.toggleFavoritePassword(password)
            } else if !lock && password.isFavorite {
                self.toggleFavoritePassword(password)
            }
        }
        loadPasswords()
        view?.exitSelectionMode()
    }
    
    func selectionState() -> SelectionRestrictionState {
        let docs = selectedPasswords()
        
        guard !docs.isEmpty else { return .none }
        
        let lockedCount = docs.filter { $0.isFavorite }.count
        
        if lockedCount == docs.count {
            return .allLocked
        } else if lockedCount == 0 {
            return .allUnlocked
        } else {
            return .mixed
        }
    }





}
