//
//  DetailMedicalItemAssembler.swift
//  record
//
//  Created by Esakkinathan B on 26/02/26.
//
import UIKit

class DetailMedicalItemAssembler {
    static func make(medicalItem: MedicalItem) -> DetailMedicalItemViewController {
        let vc = DetailMedicalItemViewController()
        let presenter = DetailMedicalItemPresenter(view: vc, medicalItem: medicalItem)
        vc.presenter = presenter
        return vc
    }
}
