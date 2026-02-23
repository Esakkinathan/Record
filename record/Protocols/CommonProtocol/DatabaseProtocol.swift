//
//  DatabaseProtocol.swift
//  record
//
//  Created by Esakkinathan B on 17/02/26.
//

import VTDB
import SQLCipher

protocol DatabaseProtocol {
    func create(table name: String, columnDefinitions: [String: TableColumnType], primaryKey: [String])
    func create(table name: String, columnDefinitions: [String: TableColumnType], primaryKey: [String], uniqueKeys: [[String]])
    func insertInto(tableName: String, values: [TableColumnName: TableColumnValue])
    func updateInto(data: Persistable)
    func delete(table name: String, id: Int)
    func updateNotes(table name: String, id: Int, text: String?, date : Date)
    func fetchDistinctValues(table name: String, column col: String) -> [String]
}

protocol DocumentDatabaseProtocol: DatabaseProtocol {
    var database: VTDatabase {get}
    func fetchDocuments() -> [Document]
    
}

protocol PasswordDatabaseProtocol: DatabaseProtocol {
    func toggle(table name: String, id: Int, value: Bool, lastModified: Date)
    func fetchPasswords() -> [Password]
    
}

protocol MasterPasswordDatabaseProtocol: DatabaseProtocol {
    func deleteAll(table name: String)
    func fetchPassword(table name: String) -> String?
}


protocol MedicalDatabaseProtocol: DatabaseProtocol {
    var database: VTDatabase {get}
    func fetchMedical() -> [Medical]
    func fetchMedicalByDate(date: Date) -> [Medical] 
}


protocol MedicalItemDatabaseProtocol: DatabaseProtocol {
    func fetchMedialItemById(_ id: Int, kind: MedicalKind) -> [MedicalItem]
    func fetchActiveMedicalItem(_ medicalId: Int, date: Date) -> [MedicalItem]
    func updateEndDate(medicalItemId: Int, date: Date)
    func fetchMedicalItems(from date: Date, to dateTo: Date) -> [MedicalItem]
}

protocol UtilityDatabaseProtocol: DatabaseProtocol {
    //var database: VTDatabase {get}
    func fetchUtility() -> [Utility]
}

protocol UtilityAccountDatabaseProtocol: DatabaseProtocol {
    func createUtilityAccountTable()
    func fetchUtilityAccounts(utilityId: Int) -> [UtilityAccount]
}

protocol BillDatabaseProtocol: DatabaseProtocol {
    func createBillTable()
    func markAsPaid(billId: Int, paidDate: Date)
    func fetchBillByUtilityAccountId(utilityAccoundId: Int, billType: BillType) -> [Bill]
}
protocol UserDatebaseProtocol: DatabaseProtocol {
    func updatePassword(userId: Int, newHash: String)
    func getUserByEmail(_ email: String) -> User?
    func getUserById(_ id: Int) -> User?
}

protocol LoginDatebaseProtocol: DatabaseProtocol {
    func getLoginSession() -> LoginSession?
    func deleteAll(table name: String)
}

protocol MedicalIntakeLogDatabase: DatabaseProtocol {
    var database: VTDatabase {get}
    func fetchLog(medicalId: Int,date: Date) -> [MedicalIntakeLog]
}
