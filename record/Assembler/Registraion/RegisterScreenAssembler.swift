//
//  RegisterScreenAssembler.swift
//  record
//
//  Created by Esakkinathan B on 17/02/26.
//
import UIKit

class RegisterScreenAssembler {
    static func make() -> RegistrationFormViewController{
        let vc = RegistrationFormViewController()
        let router = RegistrationRouter()
        
        let repo = UserRepository()
        let getUserUseCase = GetUserUseCase(repository: repo)

        let presenter = RegistrationPresenter(view: vc, router: router, getUseCase: getUserUseCase)
        vc.presenter = presenter
        return vc
    }
}
