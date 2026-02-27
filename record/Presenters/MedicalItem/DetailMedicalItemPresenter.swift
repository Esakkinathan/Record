//
//  DetailMedicalItemPresenter.swift
//  record
//
//  Created by Esakkinathan B on 26/02/26.
//

import UIKit

class DetailMedicalItemPresenter: DetailMedicalItemPresenterProtocol {
    var title: String {
        medicalItem.name
    }
    
    var medicalItem: MedicalItem
    weak var view: DetailMedicalItemViewDelegate?
    var sections: [DetailMedicalSection] = []
    init(view: DetailMedicalItemViewDelegate? = nil, medicalItem: MedicalItem) {
        self.medicalItem = medicalItem
        self.view = view
    }
    
    func numberOfSection() -> Int {
        return sections.count
    }

    func numberOfSectionRows(at section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func buildSections() {

        sections = []
        let dashBoardData: [Medicine] = PdfExportUseCase().fetchLog(medicalItem: medicalItem)
        let takenCount = dashBoardData.count(where:{
            $0.status
        })
        let missedCount = dashBoardData.count - takenCount
        
        var infoRow: [DetailMedicalRow] = []
        
        infoRow.append(.info(.init(title: "Name", value: medicalItem.name)))
        infoRow.append(.info(.init(title: "Type", value: medicalItem.kind.rawValue)))
        infoRow.append(.info(.init(title: "Instruction", value: medicalItem.instruction.value)))
        infoRow.append(.info(.init(title: "Dosage", value: medicalItem.dosage)))
        infoRow.append(.info(.init(title: "Schedules", value: medicalItem.shedule.dbValue)))
        infoRow.append(.info(.init(title: "Start Date", value: medicalItem.startDate.toString())))
        infoRow.append(.info(.init(title: "End Date", value: medicalItem.endDate.toString())))
        
        sections.append(.init(title: "Info", rows: infoRow))
        
        let chartSegment: [ChartSegment] = [
            .init(label: "Taken", value: takenCount, color: UIColor(red: 0.26, green: 0.78, blue: 0.68, alpha: 1)),
            .init(label: "Missed", value: missedCount, color: UIColor(red: 0.93, green: 0.04, blue: 0.47, alpha: 1)),
        ]
        let chartRow: [DetailMedicalRow] = [.dashBoard(chartSegment)]
        sections.append(.init(title: "Logs", rows: chartRow))
        var missedRow: [DetailMedicalRow] = []
        for data in dashBoardData {
            guard !data.status else {continue}
            missedRow.append(.info(.init(title: data.date.toString(), value: data.schedule.rawValue)))
        }
        sections.append(.init(title: "Missed Schedule", rows: missedRow))
    }
    
    func section(at indexPath: IndexPath) -> DetailMedicalRow {
        return sections[indexPath.section].rows[indexPath.row]
    }
    
    func getTitle(for section: Int) -> String? {
        return sections[section].title
    }
    
    func viewDidLoad() {
        buildSections()
    }
    
    
}
