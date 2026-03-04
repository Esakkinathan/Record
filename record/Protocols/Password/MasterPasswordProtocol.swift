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
    func didClickClear()
    func viewWillAppear()

}

protocol MasterPasswordViewDelegate: AnyObject {
    func updateDots(count: Int)
    func showInfo(_ message: String)
    func clearPin()
    func dismiss()
    func showToastVC(message: String, type: ToastType, completion: (() -> Void)? ) 
    func showLoading()
    func stopLoading()
    func exit()

}

protocol MasterPasswordRouterProtocol {
    func openListPasswordVC()
}
