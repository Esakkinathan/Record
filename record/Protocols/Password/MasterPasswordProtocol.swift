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
    func didClickClear()

}

protocol MasterPasswordViewDelegate: AnyObject {
    func updateDots(count: Int)
    func showError(_ message: String)
    func clearPin()
    func dismiss()

}

protocol MasterPasswordRouterProtocol {
    func openListPasswordVC()
}
