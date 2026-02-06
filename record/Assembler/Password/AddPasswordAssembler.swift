//
//  AddPasswordAssembler.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

import UIKit

class AddPasswordAssembler {
    static func makeAddPasswordScreen(mode: PasswordFormMode) -> AddPasswordViewController {
        let vc = AddPasswordViewController()
        let router = AddPasswordRouter(viewController: vc)
        let presenter = AddPasswordPresenter(view: vc, router: router, mode: mode)
        vc.presenter = presenter
        return vc
        
    }
}
