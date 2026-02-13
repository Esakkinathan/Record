//
//  DetailUtilityAccountAssembler.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//

import UIKit
class DetailUtilityAccountAssembler {
    static func make(utilityAccount: UtilityAccount, utility: Utility) ->  DetailUtilityAccountViewController {
        let vc = DetailUtilityAccountViewController()
        let router = DetailUtilityAccountRouter(viewController: vc)
        let presenter = DetailUtilityAccountPresenter(utilityAccount: utilityAccount, utility: utility,view: vc, router: router)
        vc.presenter = presenter
        return vc
        
    }
}
