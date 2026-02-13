//
//  DetailUtilityAccountPresenter.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//

import Foundation
import UIKit

class DetailUtilityAccountPresenter: DetailUtilityAccountPresenterProtocol {
    var title: String {
        return utilityAccount.title
    }
    var utilityAccount: UtilityAccount
    weak var view: DetailUtilityAccountViewDelegate?
    let router: DetailUtilityAccountRouterProtocol
    var sections: [DetailUtilityAccountSection] = []
    var utility: Utility
    var isNotesEditing: Bool = false
        
    init(utilityAccount: UtilityAccount, utility: Utility,view: DetailUtilityAccountViewDelegate? = nil, router: DetailUtilityAccountRouterProtocol) {
        self.utilityAccount = utilityAccount
        self.view = view
        self.router = router
        self.utility = utility
    }

}

extension DetailUtilityAccountPresenter {
    
    func viewDidLoad() {
        buildSection()
    }
    
    func buildSection() {
        sections = []
        let infoRows: [DetailUtilityAccountRow] = [
            .info(.init(title: "Titile", value: utilityAccount.title)),
            .info(.init(title: "Provider", value: utilityAccount.provider)),
            .info(.init(title: "Account Number", value: utilityAccount.accountNumber))
        ]
        let billRow: [DetailUtilityAccountRow] =  [
            .bill(.ongoing),
            .bill(.completed)
        ]
        sections.append(.init(title: "Info", rows: infoRows))
        sections.append(.init(title: "Notes", rows: [.notes(text: utilityAccount.notes, isEditable: isNotesEditing)]))
        sections.append(.init(title: "Bill", rows: billRow))
    }

}

extension DetailUtilityAccountPresenter {
    
    func updateUtilityAccount(_ utilityAccount: UtilityAccount) {
        self.utilityAccount.update(title: utilityAccount.title, accountNumber: utilityAccount.accountNumber, provider: utilityAccount.provider)
        buildSection()
        view?.reloadData()
    }
    
    func editButtonClicked() {
        router.openEditUtilityAccountVC(mode: .edit(utilityAccount), utility: utility) { [weak self] updatedUtilityAccount in
            guard let self = self else { return }
            let utilityAcc = updatedUtilityAccount as! UtilityAccount
            updateUtilityAccount(utilityAcc)
            view?.updateUtilityAccountRecord(utilityAcc)
        }
    }

}

extension DetailUtilityAccountPresenter {
    func updateNotes(text: String?) {
        if utilityAccount.notes == nil && text == nil {
            return
        }
        utilityAccount.notes = text
        buildSection()
        view?.reloadData()
    }
    
    func toggleNotesEditing(_ editing: Bool) {
        isNotesEditing = editing

        if !editing {
            view?.updateUtilityAccountNotes(
                text: utilityAccount.notes,
                id: utilityAccount.id
            )
        }

        buildSection()
        view?.reloadData()
    }


}

extension DetailUtilityAccountPresenter {
    func numberOfSection() -> Int {
        return sections.count
    }
    
    func numberOfSectionRows(at section: Int) -> Int {
        return sections[section].rows.count
    }

    func section(at indexPath: IndexPath) -> DetailUtilityAccountRow {
        return sections[indexPath.section].rows[indexPath.row]
        
    }
    
    func getTitle(for section: Int) -> String? {
        let title = sections[section].title
        if title == "Notes" {
            return nil
        }
        return title
    }
}

extension DetailUtilityAccountPresenter {
    
    func didSelectRowAt(indexPath: IndexPath) {
        if indexPath.section == 2 {
            let type = BillType.allCases[indexPath.row]
            router.openListBillVC(type: type, utilityAccount: utilityAccount)
        }
    }
        
}

