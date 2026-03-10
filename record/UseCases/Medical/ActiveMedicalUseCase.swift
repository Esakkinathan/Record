//
//  ActiveMedicalUseCase.swift
//  record
//
//  Created by Esakkinathan B on 18/02/26.
//
import Foundation
struct DashBoardData {
    var row1: SectionViewModel
    //var row2: SectionViewModel
}

class ActiveMedicalUseCase {
    
    func activeMedicals(medicals: [Medical]) -> [Medical] {
        
        return medicals.filter { medical in
            medical.status
        }

    }
    
    func execute() -> DashboardViewModel {
        
        //let active = activeMedicals(medicals: medical)
        let sections = ActiveMedicineUseCase().execute()
        
        
        //var summary: [InfoRowModel] = []
//        for act in active {
//            summary.append(.init(title: act.title, summary: "", style: .normal))
//        }
//        if summary.isEmpty {
//            summary.append(.init(title: "No Active Treatements", summary: "", style: .success))
//        }
        //return .init(row1: sections, row2: .init(title: "Active Treatements", rows: summary))
        return sections
    }
}
