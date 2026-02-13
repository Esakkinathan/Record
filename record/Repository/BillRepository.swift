//
//  BillRepository.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//
import VTDB

class BillRepository: BillRepositoryProtocol {
    let db: BillDatabaseProtocol = DatabaseAdapter.shared
    
    init() {
        createTable()
    }
    
    func createTable() {
        db.createBillTable()
    }
    
    func add(bill: Bill) {
        let columns: [String: Any?] = [
            Bill.utilityAccountIdC: bill.utilityAccountId,
            Bill.amountC: bill.amount,
            Bill.billTypeC: bill.billType.rawValue,
            Bill.dueDateC: bill.dueDate,
            Bill.paidDateC: bill.paidDate,
            Bill.createdAtC: bill.createdAt,
            Bill.lastModifiedC: bill.lastModified,
            Bill.notesC: bill.notes
        ]
        
        db.insertInto(tableName: Bill.databaseTableName, values: columns)
    }
    
    func update(bill: Bill) {
        db.updateInto(data: bill)
    }
    
    func updateNotes(text: String?, id: Int) {
        db.updateNotes(table: Bill.databaseTableName, id: id, text: text, date: Date())
    }

    func delete(id: Int) {
        db.delete(table: Bill.databaseTableName, id: id)
    }
    
    func fetchAll(utilityAccountId: Int, billType: BillType) -> [Bill] {
        return db.fetchBillByUtilityAccountId(utilityAccoundId: utilityAccountId, billType: billType)
    }
    
    func markAsPaid(billId: Int, paidDate: Date) {
        db.markAsPaid(billId: billId, paidDate: paidDate)
    }

}
