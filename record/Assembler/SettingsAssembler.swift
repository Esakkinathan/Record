//
//  SettingsAssembler.swift
//  record
//
//  Created by Esakkinathan B on 19/02/26.
//
import UIKit

class SettingsAssembler {
    static func make() -> SettingsViewController {
        let vc = SettingsViewController()
        let router = SettingsPasswordRouter(viewController: vc)
        let presenter = SettingsPresenter(view: vc,router: router)
        vc.presenter = presenter
        return vc
    }
}
