//
//  MasterPasswordProtocol.swift
//  record
//
//  Created by Esakkinathan B on 06/02/26.
//

protocol MasterPasswordPresenterProtocol {
    func didTapNumber(_ number: Int)
    func didTapDelete()
    func didTapExit()
    func resetPin()

}

protocol MasterPasswordViewDelegate: AnyObject {
    func updateDots(count: Int)
    func showInfo(_ message: String)
    func clearPin()
    func dismiss()
    func showToastVC(message: String, type: ToastType)

}

protocol MasterPasswordRouterProtocol {
    func openListPasswordVC()
}
