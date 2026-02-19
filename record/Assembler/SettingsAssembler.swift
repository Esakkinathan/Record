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
        let presenter = SettingsPresenter(view: vc)
        vc.presenter = presenter
        return vc
    }
}
