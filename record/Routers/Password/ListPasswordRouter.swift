//
//  ListDocumentRounter.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

class ListPasswordRouter: ListPasswordRouterProtocol {
    
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
}
