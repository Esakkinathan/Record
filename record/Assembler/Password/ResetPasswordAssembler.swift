//
//  ResetPasswordAssembler.swift
//  record
//
//  Created by Esakkinathan B on 02/03/26.
//
import UIKit
class ResetPasswordAssemble {
    static func make() -> MasterPasswordViewController{
        let vc = MasterPasswordViewController()
        let useCase = ResetPasswordUseCase(repository: PasswordRepository())
        let presenter = ResetPasswordPresenter(view: vc, resetUseCase: useCase)
        vc.presenter = presenter
        return vc
    }
}
