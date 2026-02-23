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
    
    var currentSort: PasswordSortOption
    var passwordList: [Password] = []
    var filteredRecords: [Password] = []
    var visibleRecords: [Password] = []
    var isSearching = false
    var isEmpty: Bool {
        return currentPassword().isEmpty
    }
    
    var uiTimer: Timer?
    var autoExitTimer: Timer?
    var remainingTime: Int = AppConstantData.passwordSession
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
    
    
    func toggleFavorite(_ password: Password) {
        //password.isFavorite.toggle()
        toggleFavouriteUseCase.execute(password)
        loadPasswords()
    }
    
    
    func numberOfPasswords() -> Int {
        return currentPassword().count
    }
    
    
    func password(at index: Int) -> Password {
        return currentPassword()[index]
    }
    
    func didSelectedRow(at index: Int) {
        let password = password(at: index)
        router.openDetailPasswordVC(password: password, onUpdate: { [weak self] updatedPassword in
            self?.updatePassword(updatedPassword as! Password)
        }, onUpdateNotes: { [weak self] text, id in
            self?.updateNotes(text: text, id: id)
            }
        )
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
        sessionManager.onSessionExpired = { [weak self] in
            self?.stopUITimer()
            self?.view?.showExitPrompt(expired: true)
            self?.startAutoExitTimer()
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
    func stopUITimer() {
        uiTimer?.invalidate()
        uiTimer = nil
    }
    
    func viewDidLoad() {
        loadPasswords()
        configureSession()
        startUITimer()
    }
    
    func startUITimer() {
        remainingTime = Int(AppConstantData.passwordSession)
        uiTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {  [weak self] _ in
            self?.isExpired()
        }
    }
    
    func isExpired() {
        guard remainingTime > 0 else { return }
        remainingTime -= 1
        let min = remainingTime / 60
        let sec = remainingTime % 60
        view?.updateTimer(String(format: "%02d:%02d", min, sec))
    }

    func exitPassoword() {
        stopAutoExitTimer()
        sessionManager.logout()
        view?.dismiss()
    }
    
    func extendSession() {
        stopAutoExitTimer()
        sessionManager.extendSession()
        startUITimer()
    }

}
extension ListPasswordPresenter {
    func gotoAddPasswordScreen() {
        router.openAddPasswordVC(mode: .add) { [weak self] newPassword in
            self?.addPassword(newPassword as! Password)
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

    func didSelectedFavourite() {
        isFavoriteSelected.toggle()
        if isFavoriteSelected {
            visibleRecords = visibleRecords.filter { $0.isFavorite}
            view?.refreshSortMenu()
            view?.reloadData()
        } else {
            applySort()
        }
    }

    func applySort() {
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
