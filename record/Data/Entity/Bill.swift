//
//  Bill.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//

import VTDB

enum BillType: String, CaseIterable {
    case ongoing = "On Going"
    case completed = "Completed"
}

class Bill: Persistable {
    func encode(to container: inout VTDB.Container) {
        container[Bill.idC] = id
        container[Bill.utilityAccountIdC] = utilityAccountId
        container[Bill.amountC] = amount
        container[Bill.dueDateC] = dueDate
        container[Bill.paidDateC] = paidDate
        container[Bill.createdAtC] = createdAt
        container[Bill.lastModifiedC] = lastModified
        container[Bill.notesC] = notes
    }
    
    static var databaseTableName: String {
        "Bill"
    }
    
    static let idC = "id"
    static let utilityAccountIdC = "utilityAccountId"
    static let amountC = "amount"
    static let billTypeC = "billType"
    static let dueDateC = "dueDate"
    static let paidDateC = "paidDate"
    static let createdAtC = "createdAt"
    static let lastModifiedC = "lastModified"
    static let notesC = "notes"

    let id: Int
    let utilityAccountId: Int
    var amount: Double
    var billType: BillType
    var dueDate: Date?
    var paidDate: Date?
    let createdAt: Date
    var lastModified: Date
    var notes: String?
    
    init(id: Int, utilityAccountId: Int, amount: Double, billType: BillType, dueDate: Date? = nil, paidDate: Date? = nil, createdAt: Date = Date(), lastModified: Date = Date(), notes: String? = nil) {
        self.id = id
        self.utilityAccountId = utilityAccountId
        self.amount = amount
        self.billType = billType
        self.dueDate = dueDate
        self.paidDate = paidDate
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.notes = notes
    }
    
    func markAsPaid(paidDate: Date) {
        self.paidDate = paidDate
        self.billType = .completed
    }
    
    func update(amount: Double, dueDate: Date? = nil, paidDate: Date? = nil,notes: String? = nil) {
        self.amount = amount
        self.dueDate = dueDate
        self.paidDate = paidDate
        self.notes = notes
    }
    
}
