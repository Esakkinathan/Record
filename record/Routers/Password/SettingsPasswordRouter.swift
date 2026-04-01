//
//  ResetPasswordRouter.swift
//  record
//
//  Created by Esakkinathan B on 02/03/26.
//
import UIKit

class SettingsPasswordRouter: SettingsRouterProtocol {
    
    weak var viewController: DocumentNavigationDelegate?
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    func openResetPasswordScreen() {
        let vc = ResetPasswordAssemble.make()
        viewController?.push(vc)
    }
    func openRemainderScreen() {
        let vc = MedicalScheduleTimeViewController()
        viewController?.push(vc)
    }

}
