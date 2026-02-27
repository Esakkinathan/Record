//
//  Remainder.swift
//  record
//
//  Created by Esakkinathan B on 24/02/26.
//
import Foundation
import VTDB
class Remainder: Persistable {
    
    static var databaseTableName: String {
        return "Remainder"
    }
    
    func getContainer() -> VTDB.Container {
        return [
            Remainder.idC: id,
            Remainder.documentIdC: documentId,
            Remainder.dateC: date
        ]
    }
    
    
    func encode(to container: inout VTDB.Container) {
        container = getContainer()
    }
    
    var isExpired: Bool {
        return date < Date()
    }
    
    var statusText: String {
        isExpired ? "Expired" : "Active"
    }
    
    static let idC = "id"
    static let documentIdC = "documentId"
    static let dateC = "date"
    var id: Int
    let documentId: Int
    let date: Date
    
    init(id: Int, documentId: Int, date: Date) {
        self.id = id
        self.documentId = documentId
        self.date = date
    }
}
enum ReminderOffset: CaseIterable {
    case oneMonth
    case threeWeeks
    case twoWeeks
    case oneWeek
    case fiveDays
    case twoDays
    case oneDay
    case custom
    
    var title: String {
        switch self {
        case .oneMonth: return "1 Month Before"
        case .threeWeeks: return "3 Weeks Before"
        case .twoWeeks: return "2 Weeks Before"
        case .oneWeek: return "1 Week Before"
        case .fiveDays: return "5 Days Before"
        case .twoDays: return "2 Days Before"
        case .oneDay: return "1 Day Before"
        case .custom: return "Custom"
        }
    }
    func date(expiryDate: Date) -> Date? {
        let calendar = Calendar.current
        
        switch self {
        case .oneMonth:
            return calendar.date(byAdding: .month, value: -1, to: expiryDate)
        case .threeWeeks:
            return calendar.date(byAdding: .day, value: -21, to: expiryDate)
        case .twoWeeks:
            return calendar.date(byAdding: .day, value: -14, to: expiryDate)
        case .oneWeek:
            return calendar.date(byAdding: .day, value: -7, to: expiryDate)
        case .fiveDays:
            return calendar.date(byAdding: .day, value: -5, to: expiryDate)
        case .twoDays:
            return calendar.date(byAdding: .day, value: -2, to: expiryDate)
        case .oneDay:
            return calendar.date(byAdding: .day, value: -1, to: expiryDate)
        case .custom:
            return nil
        }

    }
}
