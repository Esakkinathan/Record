//
//  DetailMedicalPresenter.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//

import UIKit

class DetailMedicalPresenter: DetailMedicalPresenterProtocol {
    
    
    var title: String {
        return medical.title
    }
    var medical: Medical
    weak var view: DetailMedicalViewDelegate?
    let router: DetailMedicalRouterProtocol
    var sections: [DetailMedicalSection] = []
    
    var isNotesEditing: Bool = false
        
    init(medical: Medical, view: DetailMedicalViewDelegate? = nil, router: DetailMedicalRouterProtocol) {
        self.medical = medical
        self.view = view
        self.router = router
    }
}


extension DetailMedicalPresenter {
    
    func viewDidLoad() {
        //loadMedicalItems()
        buildSection()
    }
    
    func buildSection() {
        sections = []
        if let receipt = medical.receipt {
            sections.append(.init(title: "Reciept Preview", rows: [.image(path: receipt)]))
        }
        var infoRows: [DetailMedicalRow] = [
            .info(.init(title: "Title", value: medical.title)),
            .info(.init(title: "Type", value: medical.type.rawValue)),
        ]
        if let hospital = medical.hospital {
            infoRows.append(.info(.init(title: "Hospital", value: hospital)))
        }
        if let doctor = medical.doctor {
            infoRows.append(.info(.init(title: "Doctor", value: doctor)))
        }
        infoRows.append(.info(.init(title: "Diagoned at", value: medical.date.toString())))
        infoRows.append(.info(.init(title: "Duration", value: medical.durationText)))
        
        var itemRow: [DetailMedicalRow] = []
        for kind in MedicalKind.allCases {
            itemRow.append(.medicalItem(kind))
        }
        sections.append(.init(title: "Info", rows: infoRows))
        sections.append(.init(title: "Notes", rows: [.notes(text: medical.notes, isEditable: isNotesEditing)]))
        sections.append(.init(title: "Medical Items", rows: itemRow))
    }

}
 

extension DetailMedicalPresenter {
    
    func updateMedical() {
//        self.medical.update(title: medical.title, type: medical.type,hospital: medical.hospital, doctor: medical.doctor, date: medical.date)
        buildSection()
        view?.reloadData()
    }
    
    func editButtonClicked() {
        router.openEditMedicalVC(mode: .edit(medical)) { [weak self] updatedMedical in
            guard let self = self else { return }
            updateMedical()
            view?.updateMedicalRecord(updatedMedical)
        }
    }

}

extension DetailMedicalPresenter {
    func updateNotes(text: String?) {
        if medical.notes == nil && text == nil {
            return
        }
        medical.notes = text
        buildSection()
        view?.reloadData()
    }
    
    func toggleNotesEditing(_ editing: Bool) {
        isNotesEditing = editing

        if !editing {
            view?.updateMedicalNotes(
                text: medical.notes,
                id: medical.id
            )
        }

        buildSection()
        view?.reloadData()
    }


}

extension DetailMedicalPresenter {
    func numberOfSection() -> Int {
        return sections.count
    }
    
    func numberOfSectionRows(at section: Int) -> Int {
        return sections[section].rows.count
    }

    func section(at indexPath: IndexPath) -> DetailMedicalRow {
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

extension DetailMedicalPresenter {
    
    func didSelectRowAt(indexPath: IndexPath) {
        let index = sections.endIndex - 1
        print(index)
        if index == indexPath.section {
            let kind = MedicalKind.allCases[indexPath.row]
            
            router.openListMedicalItemVC(kind: kind, medical: medical)
        }
    }
    func viewDocument() {
        if let filePath = medical.receipt {
            router.openDocumentViewer(filePath: filePath)
            view?.configureToOpenDocument(previewUrl: URL(filePath: filePath))
        }
        
    }
}

