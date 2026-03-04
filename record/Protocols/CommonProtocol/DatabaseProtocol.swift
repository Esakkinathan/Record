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
    func toggle(table name: String, column: String,id: Int, value: Bool,lastModified: Date)
    func fetchDocuments() -> [Document]
    
}

protocol PasswordDatabaseProtocol: DatabaseProtocol {
    func toggle(table name: String, column: String,id: Int, value: Bool,lastModified: Date)
    func fetchPasswords() -> [Password]
    
}

protocol MasterPasswordDatabaseProtocol: DatabaseProtocol {
    func deleteAll(table name: String)
    func fetchPassword(table name: String) -> String?
}


protocol MedicalDatabaseProtocol: DatabaseProtocol {
    var database: VTDatabase {get}
    func fetchMedical() -> [Medical]
    func fetchActiveMedical() -> [Medical]
    func setStaus(table name: String, column: String,id: Int, value: Bool,endDate: Date?)
}


protocol MedicineDatabaseProtocol: DatabaseProtocol {
    func fetchMedicinesById(_ id: Int, kind: MedicalKind) -> [Medicine]
    func fetchActiveMedicines(_ medicalId: Int) -> [Medicine]
    func fetchActiveMedicines() -> [Medicine]
    func setStaus(table name: String, column: String,id: Int, value: Bool,endDate: Date?)
}
/*

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
 */
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
    func fetchLog(medicalId: Int,date: Date) -> [MedicineIntakeLog]
    func fetchLog(medicalId: Int) -> [MedicineIntakeLog]
}
