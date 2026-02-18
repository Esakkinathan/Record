//
//  MasterPasswordPresenter.swift
//  record
//
//  Created by Esakkinathan B on 06/02/26.
//

enum PinFlow {
    case verify(existingPin: String)
    case createFirst
    case createConfirm(firstPin: String)
}


class MasterPasswordPresenter: MasterPasswordPresenterProtocol {
    
    weak var view: MasterPasswordViewDelegate?
    
    private let maxPinLength = 6
    private var enteredPin: String = ""

    let router: MasterPasswordRouterProtocol
    var useCase: MasterPasswordUseCase
    var flow: PinFlow
    init(view: MasterPasswordViewDelegate? = nil, router: MasterPasswordRouterProtocol, useCase: MasterPasswordUseCase) {
        self.view = view
        self.router = router
        self.useCase = useCase
        if let savedPin = useCase.fetch(), !savedPin.isEmpty{
            self.flow = .verify(existingPin: savedPin)
            view?.showInfo("Enter PIN")
        } else {
            self.flow = .createFirst
            view?.showInfo("Create new PIN")
        }
    }
    
    
    func didTapNumber(_ number: Int) {
        guard enteredPin.count < maxPinLength else { return }
        enteredPin.append(String(number))
        view?.updateDots(count: enteredPin.count)

        if enteredPin.count == maxPinLength {
            handlePin()
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
    
    
    func openListPasswordScreen() {
        router.openListPasswordVC()
    }
    
    func didClickClear() {
        resetPin()
    }
}

extension MasterPasswordPresenter {
    func resetPin() {
        enteredPin = ""
        view?.clearPin()
    }
    
    func validatePin(_ existingPin: String) {
        let hashed = HashManager.hash(for: enteredPin)
        if hashed == existingPin {
            resetPin()
            PasswordSessionManager.shared.authenticate()
            openListPasswordScreen()
        } else {
            view?.showToastVC(message: "Incorrect PIN", type: .error)
            resetPin()
        }
    }
    
    func handlePin() {
        switch flow {
        case .verify(let existingPin):
            validatePin(existingPin)
        case .createFirst:
            flow = .createConfirm(firstPin: enteredPin)
            resetPin()
            view?.showInfo("Enter PIN Again")
        case .createConfirm(let firstPin):
            confirmPin(firstPin)
        }
    }
    
    func confirmPin(_ firstPin: String) {
        if enteredPin == firstPin {
            useCase.add(enteredPin)
            flow = .verify(existingPin: HashManager.hash(for: enteredPin))
            resetPin()
            view?.showInfo("Enter PIN")
            PasswordSessionManager.shared.authenticate()
            
            router.openListPasswordVC()
        } else {
            view?.showToastVC(message: "PINs do not match. Try again.", type: .error)
            flow = .createFirst
            resetPin()
            view?.showInfo("Create new PIN")
        }
    }
}
