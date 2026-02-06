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
    var passwordList: [Password] = []
    var filteredRecords: [Password] = []
    
    var uiTimer: Timer?
    var remainingTime: Int = AppConstantData.passwordSession
    var sessionManager = PasswordSessionManager.shared
    
    
    init(view: ListPasswordViewDelegate? = nil, router: ListPasswordRouterProtocol, addUseCase: AddPasswordUseCase, updateUseCase: UpdatePasswordUseCase, deleteUseCase: DeletePasswordUseCase, fetchUseCase: FetchPasswordUseCase, updateNotesUseCase: UpdatePasswordNotesUseCase, toggleFavouriteUseCase: ToggleFavouriteUseCase) {
        self.view = view
        self.router = router
        self.addUseCase = addUseCase
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.fetchUseCase = fetchUseCase
        self.updateNotesUseCase = updateNotesUseCase
        self.toggleFavouriteUseCase =  toggleFavouriteUseCase
        loadPasswords()
    }
    
    func exitClicked() {
        view?.showExitPrompt(expired: false)
    }
    
    func configureSession() {
        sessionManager.onSessionExpired = { [weak self] in
            self?.stopUITimer()
            self?.view?.showExitPrompt(expired: true)
        }
    }
    func stopUITimer() {
        uiTimer?.invalidate()
        uiTimer = nil
    }
    
    func viewDidLoad() {
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
    
    func toggleFavorite(_ password: Password) {
        toggleFavouriteUseCase.execute(password)
    }
    
    func addPassword(_ password: Password) {
        addUseCase.execute(password: password)
        loadPasswords()
        view?.reloadData()
    }
    
    func updatePassword(_ password: Password) {
        updateUseCase.execute(password: password)
        loadPasswords()
        view?.reloadData()

    }
    
    func deletePassword(for id: Int) {
        deleteUseCase.execute(id: id)
        loadPasswords()
        view?.reloadData()

    }
    
    func updateNotes(text: String?,id: Int) {
        updateNotesUseCase.execute(text: text, id: id)
        loadPasswords()
        view?.reloadData()

    }
    
    func loadPasswords() {
        self.passwordList = fetchUseCase.execute()
    }
    
    func numberOfPasswords() -> Int {
        return passwordList.count
    }
    
    
    func password(at index: Int) -> Password {
        return passwordList[index]
    }
    
    func didSelectedRow(at index: Int) {
        let password = password(at: index)
        router.openDetailPasswordVC(password: password, onUpdate: { [weak self] updatedPassword in
            self?.updatePassword(updatedPassword)
        }, onUpdateNotes: { [weak self] text, id in
            self?.updateNotes(text: text, id: id)
            }
        )
    }

    
    func gotoAddPasswordScreen() {
        router.openAddPasswordVC(mode: .add) { [weak self] newPassword in
            self?.addPassword(newPassword)
        }
    }
    
    func exitPassoword() {
        sessionManager.logout()
        view?.dismiss()
    }
    
    func extendSession() {
        sessionManager.extendSession()
        startUITimer()
    }

}
