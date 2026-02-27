//
//  DetailMedicalPresenter.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//

import UIKit
import PDFKit

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
        let dashboardData: [MedicalKind:[MedicalItem]] = PdfExportUseCase().fetchData(medical: medical)
        
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
        infoRows.append(.info(.init(title: "Created At", value: medical.createdAt.toString())))
        infoRows.append(.info(.init(title: "Last modified", value: medical.lastModified.reminderFormatted())))
        infoRows.append(.info(.init(title: "button", value: "Export As Pdf")))
        
        var chartSegment: [ChartSegment] = []
        
        let colors: [UIColor] = [
            UIColor(red: 0.42, green: 0.39, blue: 1.00, alpha: 1),
            UIColor(red: 0.26, green: 0.78, blue: 0.68, alpha: 1),
            UIColor(red: 0.97, green: 0.60, blue: 0.12, alpha: 1),
            UIColor(red: 0.93, green: 0.04, blue: 0.47, alpha: 1),
        ]
        
        var colorIndex = 0
        for (data,value) in dashboardData {
            chartSegment.append(.init(label: data.rawValue, value: value.count, color: colors[colorIndex]))
            colorIndex += 1
        }
        let chartRow: [DetailMedicalRow] = [.dashBoard(chartSegment)]
        
        var itemRow: [DetailMedicalRow] = []
        
        for kind in MedicalKind.allCases {
            itemRow.append(.medicalItem(kind))
        }
        
        if let receipt = medical.receipt {
            sections.append(.init(title: "Reciept Preview", rows: [.image(path: receipt)]))
        }
        sections.append(.init(title: "Info", rows: infoRows))
        sections.append(.init(title: "Medicines", rows: chartRow))
        sections.append(.init(title: "Medical Items", rows: itemRow))
        sections.append(.init(title: "Notes", rows: [.notes(text: medical.notes, isEditable: isNotesEditing)]))
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
        let section = sections[indexPath.section]
        if section.title == "Medical Items" {
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
    func exportDocumentClicked() {
        view?.showLoading()
        view?.showAlertToIncludeNotes() { [weak self] value in
            guard let self = self else { return }
            let pdfData = PdfExportUseCase().generateMedicalPDF(medical: medical, includeNotes: value)
            let mergedPdf = PDFDocument(data: pdfData)
            if let receipt = medical.receipt {
                if let receiptPdf = PDFDocument(url: URL(filePath: receipt)) {
                    for i in 0..<receiptPdf.pageCount {
                        if let page = receiptPdf.page(at: i) {
                            mergedPdf?.insert(page, at: i)
                        }
                    }
                }
            }
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(medical.title)_\(medical.date.toString(format: "dd_MM_yyyy")).pdf")
            
            try? mergedPdf?.dataRepresentation()?.write(to: tempURL)
            self.view?.stopLoading()
            self.router.sharePdf(url: tempURL)
        }

    }

}

