//
//  DetailMedicalAssembler.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//

import UIKit
class DetailMedicalAssembler {
    static func make(medical: Medical) ->  DetailMedicalViewController {
        let vc = DetailMedicalViewController()
        let router = DetailMedicalRouter(viewController: vc)
        let updateUseCase = UpdateMedicalUseCase(repository: MedicalRepository())
        let presenter = DetailMedicalPresenter(medical: medical, view: vc, router: router, updateUseCase: updateUseCase)
        vc.presenter = presenter
        return vc
        
    }
}
