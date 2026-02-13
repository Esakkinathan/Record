//
//  UtilityAccount.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//
import VTDB
class UtilityAccountRepository: UtilityAccountRepositoryProtocol {
        
    var db: UtilityAccountDatabaseProtocol = DatabaseAdapter.shared

    init() {
        createTable()
    }
    
    func createTable() {
//        let colums: [String: TableColumnType] = [
//            UtilityAccount.idC: .int,
//            UtilityAccount.utilityIdC: .int,
//            UtilityAccount.titleC: .string,
//            UtilityAccount.accountNumberC: .string,
//            UtilityAccount.providerC: .text,
//            UtilityAccount.createdAtC:  .date,
//            UtilityAccount.lastModifiedC: .date,
//            UtilityAccount.notesC: .string,
//        ]
        db.createUtilityAccountTable()
//        db.create(table: UtilityAccount.databaseTableName, columnDefinitions: colums, primaryKey: [Utility.idC])

    }
    
    func add(utilityAccount: UtilityAccount) {
        
        let colums: [String: Any?] = [
            UtilityAccount.idC: utilityAccount.id,
            UtilityAccount.utilityIdC: utilityAccount.utilityId,
            UtilityAccount.titleC: utilityAccount.title,
            UtilityAccount.accountNumberC: utilityAccount.accountNumber,
            UtilityAccount.providerC: utilityAccount.provider,
            UtilityAccount.createdAtC: utilityAccount.createdAt,
            UtilityAccount.lastModifiedC: utilityAccount.lastModified,
            UtilityAccount.notesC: utilityAccount.notes,
        ]
        db.insertInto(tableName: UtilityAccount.databaseTableName, values: colums)
    }
    
    func update(utilityAccount: UtilityAccount) {
        db.updateInto(data: utilityAccount)
    }
    
    func delete(id: Int) {
        db.delete(table: UtilityAccount.databaseTableName, id: id)
    }
    
    func fetchAllByUtilityId(utilityId: Int) -> [UtilityAccount] {
        return db.fetchUtilityAccounts(utilityId: utilityId)
    }
    
    func updateNotes(text: String?, id: Int) {
        db.updateNotes(table: UtilityAccount.databaseTableName, id: id, text: text, date: Date())
    }

}
