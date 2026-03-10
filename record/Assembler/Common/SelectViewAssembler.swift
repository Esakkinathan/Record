//
//  SelectViewAssembler.swift
//  record
//
//  Created by Esakkinathan B on 21/02/26.
//
import UIKit

class SelectViewAssembler {
    static func make(options: [String], selectedOption: String, addExtra: Bool = true, validator: [ValidationRules]) -> SelectionViewController {
        let vc = SelectionViewController()
        let presenter = SelectionPresenter(view: vc, options: options, selectedOption: selectedOption, addExtra: addExtra, validators: validator)
        vc.presenter = presenter
        return vc
    }
}
