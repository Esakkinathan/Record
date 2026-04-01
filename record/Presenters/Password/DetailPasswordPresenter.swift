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
    let updateUseCase: UpdatePasswordUseCase
    init(password: Password, view: DetailPasswordViewDelegate? = nil, router: DetailPasswordRouterProtocol, updateUseCase: UpdatePasswordUseCase) {
        self.password = password
        self.view = view
        self.router = router
        self.updateUseCase = updateUseCase
        buildSection()
    }
    
    func updatePassword(_ password: Password) {
        self.password.update(title: password.title, username: password.username, password: password.password, url: password.url)
        DispatchQueue.global().async { [weak self] in
            self?.updateUseCase.execute(password: password)
        }
        buildSection()
        view?.reloadData()
    }
    func editButtonClicked() {
        router.openEditPasswordVC(mode: .edit(password)) { [weak self] updatedPassword in
            guard let self = self else { return }
            updatePassword(updatedPassword as! Password)
            //view?.updatePassword(updatedPassword)
            view?.showToastVC(message: "Data modified successfully", type: .success)
        }
    }

    func updateNotes(text: String?) {
        if password.notes == nil && text == nil {
            return
        }
        password.notes = text
        //buildSection()
        //view?.reloadData()
    }

    func updateLastCopiedDate() {
        let date = Date()
        password.updateLastCopiedDate(date: date)
        updateUseCase.execute(id: password.id, date: date)
        buildSection()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { [weak self] in
            self?.view?.reloadData()
        }
    }
    
    func numberOfSection() -> Int {
        return sections.count
    }
    
    func numberOfSectionRows(at section: Int) -> Int {
        return sections[section].rows.count
    }

    func buildSection() {
        sections = []
        
        var infoRows: [DetailPasswordRow] = [
            .info(.init(title: "Title", value: password.title, type: .text)),
            .info(.init(title: "Username", value: password.username, type: .copyLabel)),
            .info(.init(title: "Password", value: password.password, date: password.lastCopiedDate,type: .passwordLabel)),
            .info(.init(title: "Created At", value: password.createdAt.toString(), type: .text)),
            .info(.init(title: "Last Modified", value: password.lastModified.reminderFormatted(), type: .text))
        ]
        if let url = password.url, !url.isEmpty {
            infoRows.append(.info(.init(title: "Url", value: url, type: .url)))
        }
        
        print(infoRows.count)
        sections.append(.init(title: "Info", rows: infoRows ))
            
        sections.append(.init(title: "Notes", rows: [.notes(text: password.notes, isEditable: isNotesEditing)]))
    }
    func openUrl() {
        guard let urlPath = password.url else { return }
        if let url = URL(string: urlPath) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func section(at indexPath: IndexPath) -> DetailPasswordRow {
        return sections[indexPath.section].rows[indexPath.row]
    }
    
    
    func toggleNotesEditing(_ editing: Bool) {
        isNotesEditing = editing

        if !editing {
            updateUseCase.execute(text: password.notes, id: password.id)
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
