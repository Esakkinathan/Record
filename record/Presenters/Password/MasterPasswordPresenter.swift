//
//  MasterPasswordPresenter.swift
//  record
//
//  Created by Esakkinathan B on 06/02/26.
//

class MasterPasswordPresenter: MasterPasswordPresenterProtocol {
    
    weak var view: MasterPasswordViewDelegate?
    
    private let maxPinLength = 6
    private var enteredPin: String = ""

    private var storedPin: String? = "123456"
    let router: MasterPasswordRouterProtocol
    var useCase: MasterPasswordUseCase
    
    init(view: MasterPasswordViewDelegate? = nil, router: MasterPasswordRouterProtocol, useCase: MasterPasswordUseCase) {
        self.view = view
        self.router = router
        self.useCase = useCase
        setUpPassword()
    }
    
    func setUpPassword() {
        storedPin = useCase.fetch()
        guard let pin = storedPin else { return }
    }
    
    func didTapNumber(_ number: Int) {
        guard enteredPin.count < maxPinLength else { return }
        enteredPin.append(String(number))
        view?.updateDots(count: enteredPin.count)

        if enteredPin.count == maxPinLength {
            validatePin()
        }

    }
    
    func didTapDelete() {
        guard !enteredPin.isEmpty else { return }
        enteredPin.removeLast()
        view?.updateDots(count: enteredPin.count)

    }
    
    func didTapExit() {
        view?.dismiss()
    }
    func validatePin() {
        if enteredPin == storedPin {
            PasswordSessionManager.shared.authenticate()
            openListPasswordScreen()
        } else {
            view?.showError("Incorrect PIN")
            enteredPin = ""
            view?.clearPin()
        }
    }
    func openListPasswordScreen() {
        router.openListPasswordVC()
    }
    func didClickClear() {
        enteredPin = ""
        view?.clearPin()
    }
}
