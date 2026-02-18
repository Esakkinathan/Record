//
//  AddMedicalItemRouter.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//

class AddMedicalItemRouter: AddMedicalItemRouterProtocol {
    
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }

    func openSelectVC(options: [String], selected: String, addExtra: Bool,onSelect: @escaping (String) -> Void) {
        let vc = SelectionViewController(options: options,selectedOption: selected, addExtra: addExtra)
        vc.onValueSelected = onSelect
        viewController?.push(vc)
    }
    func openMultiSelectVC(options: [String], selected: [String], onSelect: @escaping ([String]) -> Void) {
        let vc = MultiSelectionViewController(options: options, selectedOptions: selected)
        vc.onValuesSelected = onSelect
        viewController?.push(vc)
    }

    

}
