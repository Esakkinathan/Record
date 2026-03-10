//
//  DetailPasswordAssembler.swift
//  record
//
//  Created by Esakkinathan B on 04/02/26.
//

import UIKit

class DetailPasswordAssembler {
    static func make(password: Password) -> DetailPasswordViewController {
        let vc = DetailPasswordViewController()
        let router = DetailPasswordRouter(viewController: vc)
        let updateUseCase = UpdatePasswordUseCase(repository: PasswordRepository())
        let presenter = DetailPasswordPresenter(password: password, view: vc, router: router, updateUseCase: updateUseCase)
        vc.presenter = presenter
        return vc
    }
}
