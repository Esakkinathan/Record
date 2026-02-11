//
//  AddMedicalItemAssembler.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
import UIKit
class AddMedicalItemAssembler {
    static func make(mode: MedicalItemFormMode, medicalId: Int, kind: MedicalKind) -> AddMedicalItemViewController {
        let vc = AddMedicalItemViewController()
        let router = AddMedicalItemRouter(viewController: vc)
        let presenter = AddMedicalItemPresenter(view: vc, router: router, mode: mode,medicalId: medicalId, kind: kind)
        vc.presenter = presenter
        return vc
    }
}
