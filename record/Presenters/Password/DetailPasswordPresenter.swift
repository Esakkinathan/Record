//
//  DetailPasswordViewController.swift
//  record
//
//  Created by Esakkinathan B on 04/02/26.
//

import UIKit

class DetailPasswordPresenter: DetailPasswordPresenterProtocol {
    
    var title: String {
        return password.title
    }
    var password: Password
    weak var view: DetailPasswordViewDelegate?
    let router: DetailPasswordRouterProtocol
    var sections: [DetailPasswordSection] = []
    
    var isNotesEditing: Bool = false
    
    init(password: Password, view: DetailPasswordViewDelegate? = nil, router: DetailPasswordRouterProtocol) {
        self.password = password
        self.view = view
        self.router = router
        
        buildSection()
    }
    
    func updatePassword(_ password: Password) {
        self.password.update(title: password.title, username: password.username, password: password.password)
        buildSection()
        view?.reloadData()
    }

    
    
    func editButtonClicked() {
        router.openEditPasswordVC(mode: .edit(password)) { [weak self] updatedPassword in
            guard let self = self else { return }
            updatePassword(updatedPassword as! Password)
            view?.updatePassword(updatedPassword)
        }
    }

    func updateNotes(text: String?) {
        if password.notes == nil && text == nil {
            return
        }
        password.notes = text
        buildSection()
        view?.reloadData()
    }

    
    
    func numberOfSection() -> Int {
        return sections.count
    }
    
    func numberOfSectionRows(at section: Int) -> Int {
        return sections[section].rows.count
    }

    func buildSection() {
        sections = []
        
        let infoRows: [DetailPasswordRow] = [
            .info(.init(title: "Title", value: password.title, type: .text)),
            .info(.init(title: "Username", value: password.username, type: .copyLabel)),
            .info(.init(title: "Password", value: password.password, type: .copyLabel)),
            .info(.init(title: "Created At", value: password.createdAt.toString(), type: .text))
        ]
        
        sections.append(.init(title: "Info", rows: infoRows ))
            
        sections.append(.init(title: "Notes", rows: [.notes(text: password.notes, isEditable: isNotesEditing)]))
    }
    
    func section(at indexPath: IndexPath) -> DetailPasswordRow {
        return sections[indexPath.section].rows[indexPath.row]
    }
    
    
    func toggleNotesEditing(_ editing: Bool) {
        isNotesEditing = editing

        if !editing {
            view?.updatePasswordNotes(
                text: password.notes,
                id: password.id
            )
        }

        buildSection()
        view?.reloadData()
    }
    func getTitle(for section: Int) -> String? {
        let title = sections[section].title
        if title == "Notes" {
            return nil
        }
        return title

    }
}
