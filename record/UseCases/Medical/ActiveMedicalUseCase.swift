//
//  ActiveMedicalUseCase.swift
//  record
//
//  Created by Esakkinathan B on 18/02/26.
//
import Foundation
struct DashBoardData {
    var row1: SectionViewModel
    var row2: SectionViewModel
}

class ActiveMedicalUseCase {
    
    func activeMedicals(medicals: [Medical]) -> [Medical] {
        let today = Calendar.current.startOfDay(for: Date())
        
        return medicals.filter { medical in
            let start = Calendar.current.startOfDay(for: medical.startDate)
            let end = Calendar.current.startOfDay(for: medical.endDate)
            
            return start <= today && end >= today
        }

    }
    
    func execute(medical: [Medical]) -> DashBoardData {
        
        let active = activeMedicals(medicals: medical)
        let sections = ActiveMedicalItemsUseCase().execute()
        
        
        var summary: [InfoRowModel] = []
        for act in active {
            summary.append(.init(title: act.title, summary: remainingText(for: act), style: .normal))
        }
        if summary.isEmpty {
            summary.append(.init(title: "No Active Treatements", summary: "", style: .success))
        }
        return .init(row1: sections, row2: .init(title: "Active Treatements", rows: summary))
    }
    func remainingText(for medical: Medical) -> String {
        let end = medical.endDate
        let today = Calendar.current.startOfDay(for: Date())
        let endDay = Calendar.current.startOfDay(for: end)
        
        let days = Calendar.current.dateComponents([.day], from: today, to: endDay).day ?? 0
        
        if days < 0 {
            return "Completed"
        }
        
        if days == 0 {
            return "Ends Today"
        }
        
        // If originally weekly treatment, show in weeks when possible
        if medical.durationType == .week {
            let weeks = days / 7
            if weeks == 1 {
                return "1 week left"
            }
            if weeks > 1 {
                return "\(weeks) weeks left"
            }
        }
        
        // If monthly treatment and large duration
        if medical.durationType == .month && days >= 30 {
            let months = days / 30
            if months == 1 {
                return "1 month remaining"
            }
            return "\(months) months remaining"
        }
        
        // Default fallback
        if days == 1 {
            return "1 day left"
        }
        
        return "\(days) days left"
    }

}
