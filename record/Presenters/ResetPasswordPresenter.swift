//
//  ResetPasswordPresenter.swift
//  record
//
//  Created by Esakkinathan B on 02/03/26.
//
import Foundation

class ResetPasswordPresenter: MasterPasswordPresenterProtocol {
    
    var keyChain: KeychainManager
    weak var view: MasterPasswordViewDelegate?
    private let maxPinLength = 6
    private var enteredPin: String = ""
    var flow: PinFlow
    let resetUseCase: ResetPasswordUseCaseProtocol
    init(view: MasterPasswordViewDelegate? = nil, resetUseCase: ResetPasswordUseCaseProtocol) {
        self.keyChain = KeychainManager.shared
        self.view = view
        self.resetUseCase = resetUseCase
        flow = .createFirst
        view?.showInfo("Reset Pin")
    }
    
    func didTapNumber(_ number: Int) {
        guard enteredPin.count < maxPinLength else { return }
        enteredPin.append(String(number))
        view?.updateDots(count: enteredPin.count)

        if enteredPin.count == maxPinLength {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                self?.handlePin()
            }
        }

    }
    
    func viewWillAppear() {
        flow = .createFirst
    }
    
    func handlePin() {
        switch flow {
        case .verify(_):
            print("")
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
        //keyChain.savePin(enteredPin)
            view?.showLoading()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                resetUseCase.execute(newPin: enteredPin)
                view?.stopLoading()
                view?.showToastVC(message: "Pin reseted successfully", type: .success) { [weak self] in
                    self?.view?.exit()
                }
                
            }
        } else {
            view?.showToastVC(message: "PINs do not match. Try again.", type: .error, completion: nil)
            flow = .createFirst
            resetPin()
            view?.showInfo("Create new PIN")
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
    
    func resetPin() {
        enteredPin = ""
        view?.clearPin()
    }

    func didClickClear() {
        resetPin()
    }
    
}
