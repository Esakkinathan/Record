//
//  DetailPasswordAssembler.swift
//  record
//
//  Created by Esakkinathan B on 04/02/26.
//

import UIKit

class DetailPasswordAssembler {
    static func makePasswordScreen(password: Password) -> DetailPasswordViewController {
        let vc = DetailPasswordViewController()
        let router = DetailPasswordRouter(viewController: vc)
        let presenter = DetailPasswordPresenter(password: password, view: vc, router: router)
        vc.presenter = presenter
        return vc
    }
}
