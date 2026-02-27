//
//  MasterPasswordAssembler.swift
//  record
//
//  Created by Esakkinathan B on 06/02/26.
//
import UIKit

class MasterPasswordAssembler {
    static func make() -> MasterPasswordViewController {
        let vc = MasterPasswordViewController()
        let router = MasterPasswordRouter(viewController: vc)
        //let repository = MasterPasswordRepository()
        //let useCase = MasterPasswordUseCase(repository: repository)
        let presenter = MasterPasswordPresenter(view: vc, router: router)
        vc.presenter = presenter
        return vc
    }
}
