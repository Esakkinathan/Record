//
//  AddMedicalRouter.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//

class AddMedicalRouter: AddMedicalRouterProtocol {
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }

    func openSelectVC(options: [String], selected: String, addExtra: Bool, onSelect: @escaping (String) -> Void) {
        let vc = SelectionViewController(options: options,selectedOption: selected, addExtra: addExtra)
        vc.onValueSelected = onSelect
        viewController?.push(vc)
    }

}
