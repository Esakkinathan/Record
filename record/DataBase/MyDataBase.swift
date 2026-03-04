//
//  DataBase.swift
//  record
//
//  Created by Esakkinathan B on 29/01/26.
//
import VTDB
import SQLCipher
import UIKit

typealias TableColumnType = Database.ColumnType
typealias TableColumnName = String
typealias TableColumnValue = Any?
typealias ConflictResolution = Database.ConflictResolution
typealias Container = VTDB.Container

class DatabaseAdapter: DatabaseProtocol {
    static let collatioName = "recordsDB"
    var database: VTDatabase
    var databaseName: String
    static let shared: DatabaseAdapter = {
            do {
                return try DatabaseAdapter()
            } catch {
                fatalError("Failed to initialize DatabaseAdapter: \(error)")
            }
        }()
    static func getPath() -> String {
        let cwd =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
        return (cwd as NSString).appendingPathComponent("records.sqlite")
    }

    private init() throws {
        var configuration = Configuration()
        configuration.foreignKeysEnabled = true
        do {
            let key = "recordApp"
            try configuration.setKey(.passphrase(key))
        } catch {
            print(error.localizedDescription)
        }
        
        configuration.trace = {
            print("q: \($0)") // To trace all queries
        }
        database = try DatabaseQueue(
            path: DatabaseAdapter.getPath(),
            configuration: configuration
        )
        databaseName = DatabaseAdapter.getPath()

        registerCollation()
        createTable()
    }
    
    func dropTable(table name: String) {
        let sql = "DROP TABLE \(name) ;"
        do {
            try database.write { db in
                try db.execute(sql)
            }

        } catch {
            print(error)
        }

    }
    func createTable() {
 //       dropTable(table: Document.databaseTableName)
 //       dropTable(table: "MedicalItem")
//        dropTable(table: Password.databaseTableName)
//        dropTable(table: Medical.databaseTableName)
//        dropTable(table: Medicine.databaseTableName)
//        dropTable(table: MedicineIntakeLog.databaseTableName)
//        dropTable(table: Bill.databaseTableName)
//        dropTable(table: Utility.databaseTableName)
//        dropTable(table: UtilityAccount.databaseTableName)
        //let key = "createTable"
//        let value: Bool = UserDefaults.standard.bool(forKey: key)
//        guard !value else { return }
//        
//        UserDefaults.standard.set(true, forKey: key)
        
        let docuementColumns: [String: TableColumnType] = [
            Document.idC: .int,
            Document.nameC: .string,
            Document.numberC: .string,
            Document.createdAtC: .date,
            Document.expiryDateC: .date,
            Document.fileC: .blob,
            Document.notesC: .text,
            Document.lastModifiedC: .date,
            Document.isRestrictedC: .bool
        ]
        
        create(table: Document.databaseTableName, columnDefinitions: docuementColumns, primaryKey: [Document.idC], uniqueKeys:[[Document.idC,Document.numberC]])
        
        let passwordColumns: [String: TableColumnType] = [
            Password.idC: .int,
            Password.titleC: .string,
            Password.usernameC: .string,
            Password.passwordC: .string,
            Password.notesC: .text,
            Password.createdAtC: .date,
            Password.lastModifiedC: .date,
            Password.isFavoriteC: .bool,
            Password.lastCopiedDateC: .date,
            Password.urlC: .blob
        ]
        
        create(table: Password.databaseTableName, columnDefinitions: passwordColumns, primaryKey: [Document.idC], uniqueKeys:[[Password.idC,Password.titleC]])
        
        let medicalColumns: [String: TableColumnType] = [
            Medical.idC: .int,
            Medical.titleC: .string,
            Medical.typeC: .string,
            Medical.hospitalC: .string,
            Medical.doctorC: .string,
            Medical.dateC: .date,
            Medical.createdAtC: .date,
            Medical.lastModifiedC: .date,
            Medical.notesC: .text,
            Medical.receiptC: .blob,
            Medical.endDateC: .date,
            Medical.statusC: .bool,
            
        ]
        
        create(table: Medical.databaseTableName, columnDefinitions: medicalColumns, primaryKey: [Medical.idC])
        
        let medicalItemSql = """
                CREATE TABLE IF NOT EXISTS \(Medicine.databaseTableName) (
                \(Medicine.idC) INTEGER PRIMARY KEY AUTOINCREMENT,
                \(Medicine.medicalC) INTEGER NOT NULL,
                \(Medicine.kindC) TEXT NOT NULL,
                \(Medicine.nameC) TEXT NOT NULL,
                \(Medicine.instructionC) TEXT NOT NULL,
                \(Medicine.dosageC) TEXT NOT NULL,
                \(Medicine.startDateC) TEXT NOT NULL,
                \(Medicine.endDateC) TEXT,
                \(Medicine.sheduleC) TEXT NOT NULL,
                \(Medicine.statusC) INTEGER NOT NULL,

                FOREIGN KEY (\(Medicine.medicalC))
                REFERENCES \(Medical.databaseTableName)(\(Medical.idC))
                ON DELETE CASCADE
                ON UPDATE CASCADE
                );
            """
        let medicalLogSql = """
                CREATE TABLE IF NOT EXISTS \(MedicineIntakeLog.databaseTableName) (
                \(MedicineIntakeLog.idC) INTEGER PRIMARY KEY AUTOINCREMENT,
                \(MedicineIntakeLog.medicineIdC) INTEGER NOT NULL,
                \(MedicineIntakeLog.dateC) TEXT NOT NULL,
                \(MedicineIntakeLog.scheduleC) TEXT NOT NULL,
                \(MedicineIntakeLog.takenC) INTEGER NOT NULL,
            
                FOREIGN KEY (\(MedicineIntakeLog.medicineIdC))
                REFERENCES \(Medicine.databaseTableName)(\(Medicine.idC))
                ON DELETE CASCADE
                ON UPDATE CASCADE
                );
            """
        let remainderSql = """
                CREATE TABLE IF NOT EXISTS \(Remainder.databaseTableName) (
                \(Remainder.idC) INTEGER PRIMARY KEY AUTOINCREMENT,
                \(Remainder.documentIdC) INTEGER NOT NULL,
                \(Remainder.dateC) TEXT NOT NULL,
            
                FOREIGN KEY (\(Remainder.documentIdC))
                REFERENCES \(Document.databaseTableName)(\(Document.idC))
                ON DELETE CASCADE
                ON UPDATE CASCADE
                );
            """

        do {
            try database.writeInTransaction { db in
                try db.execute(medicalItemSql)
                try db.execute(medicalLogSql)
                try db.execute(remainderSql)
                return .commit
            }

        } catch {
            print(error)
        }

    }
    
    func registerCollation() {
        do {
            try database.create(collation: DatabaseAdapter.collatioName) {l, h in
                let lhs = l.folding(options: [.diacriticInsensitive], locale: nil)
                let rhs = h.folding(options: [.diacriticInsensitive], locale: nil)
                return lhs.uppercased().compare(rhs.uppercased())
            }
        } catch {
            print(error)
        }
    }
    
    

    public func create(table name: String, columnDefinitions: [String: TableColumnType], primaryKey: [String]) {
        create(table: name, columnDefinitions: columnDefinitions, primaryKey: primaryKey, uniqueKeys: [])
    }
    
    public func create(table name: String, columnDefinitions: [String: TableColumnType], primaryKey: [String], uniqueKeys: [[String]]) {
        do {
            try database.write { db in
                try db.create(table: name, ifNotExists: true, mapColumn: false) { t in
                    for (column, type) in columnDefinitions {
                        if let type = Database.ColumnType(rawValue: type.rawValue) {
                            t.column(column, type)
                        } else {
                            t.column(column, .text)
                        }
                    }
                    if !primaryKey.isEmpty {
                        t.primaryKey(primaryKey)
                    }
                    uniqueKeys.forEach { t.uniqueKey($0) }
                }
            }
        } catch { print(error) }
    }
    
    public func insertInto(tableName: String, values: [TableColumnName: TableColumnValue]) {
        insertInto(tableName: tableName, values: values, conflictResolution: .replace)
    }
    
    public func insertInto(tableName: String, values: [TableColumnName: TableColumnValue], conflictResolution: ConflictResolution) {
        let dbConflictResolution = dbConflictResolution(conflictResolution)
        do {
            try database.write { db in
                try db.insert(intoTable: tableName, values: values, onConflict: dbConflictResolution)
            }
        } catch {
            print(error)
        }
    }
    private func dbConflictResolution(_ conflictResolution: ConflictResolution) -> Database.ConflictResolution {
        switch conflictResolution {
        case .replace:
            return Database.ConflictResolution.replace
        case .rollback:
            return Database.ConflictResolution.rollback
        case .abort:
            return Database.ConflictResolution.abort
        case .fail:
            return Database.ConflictResolution.fail
        case .ignore:
            return Database.ConflictResolution.ignore
        }
    }
    
    func insertInto(data: Persistable) throws {
        try database.writeInTransaction { db in
            try data.insert(db)
            
            return .commit
        }
    }
        
    func updateInto(data: Persistable) {
        do {
            try database.writeInTransaction { db in
                try data.save(db)
                return .commit
            }
        } catch {
            print("error")
        }
    }
    
    func delete(table name: String, id: Int) {
        do {
            try database.writeInTransaction { db in
                let query = "DELETE FROM \(name) WHERE id = \(id);"
                try db.execute(query)
                return .commit
            }
        } catch {
            print(error)
        }
    }
    
    func updateNotes(table name: String, id: Int, text: String?, date : Date) {
        do {
            try database.writeInTransaction { db in
                let sql = "UPDATE \(name) SET notes = ?, lastModified = ? WHERE id = ?"
                try db.execute(sql, [text,date,id])
                return .commit
            }
        } catch {
            print(error)
        }
    }
    func toggle(table name: String, column: String,id: Int, value: Bool,lastModified: Date) {
        do {
            try database.writeInTransaction { db in
                let sql = "UPDATE \(name) SET \(column) = ?, lastModified = ? WHERE id = ?"
                try db.execute(sql, [value,lastModified,id])
                return .commit
            }
        } catch {
            print(error)
        }
    }
    
    func fetchDistinctValues(table name: String, column col: String) -> [String] {
        var data: [String] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT \(col) FROM \(name)  WHERE \(col) IS NOT NULL ; ")
                for row in rows {
                    let value: String = row[col]
                    data.append(value)
                }
            }
        } catch {
            print(error)
        }
        return data
    }
}

extension DatabaseAdapter: DocumentDatabaseProtocol {
    func fetchDocuments() -> [Document] {
        var document: [Document] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(Document.databaseTableName)")
                for row in rows {
                    let id: Int = row[Document.idC]
                    let name: String = row[Document.nameC]
                    let number: String = row[Document.numberC]
                    let createdAt: Date = row[Document.createdAtC]
                    let expiryDate: Date? = row[Document.expiryDateC]
                    let file: String? = row[Document.fileC]
                    let notes: String? = row[Document.notesC]
                    let lastModified: Date = row[Document.lastModifiedC]
                    let isRestricted: Bool = row[Document.isRestrictedC]
                    document.append(Document(id: id, name: name, number: number,createdAt: createdAt,expiryDate: expiryDate,file: file,notes: notes,lastModified: lastModified, isRestricted: isRestricted))
                }
            }
        } catch {
            print(error)
        }
        return document
    }
}
protocol RemainderDatabaseProtocol: DatabaseProtocol {
    func fetchRemainderByDocumentId(_ id: Int) -> [Remainder]
    func insertandGetRemainderId(table name: String, values: [TableColumnName: TableColumnValue] ) -> Int
}

extension DatabaseAdapter: RemainderDatabaseProtocol {
    func fetchRemainderByDocumentId(_ id: Int) -> [Remainder] {
        var remainders: [Remainder] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(Remainder.databaseTableName) WHERE \(Remainder.documentIdC) = ? ; ", parameters: [id])
                for row in rows {
                    let id: Int = row[Remainder.idC]
                    let documentId: Int = row[Remainder.documentIdC]
                    let date: Date = row[Remainder.dateC]
                    remainders.append(Remainder(id: id, documentId: documentId, date: date))
                }
            }
        } catch {
            print(error)
        }
        return remainders
        
    }
    
    func insertandGetRemainderId(table name: String, values: [TableColumnName: TableColumnValue] ) -> Int {
        let dbConflictResolution = dbConflictResolution(.replace)
        var lastInsertId: Int = 0
        do {
            try database.write { db in
                try db.insert(intoTable: name, values: values, onConflict: dbConflictResolution)
                
                lastInsertId = Int(db.lastInsertedRowID)
                print("lastinsertedId",lastInsertId)
            }
        } catch {
            print(error)
        }
        return lastInsertId

    }

}
extension DatabaseAdapter: PasswordDatabaseProtocol {
    func fetchPasswords() -> [Password] {
        var passwords: [Password] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(Password.databaseTableName)")
                for row in rows {
                    let id: Int = row[Password.idC]
                    let title: String = row[Password.titleC]
                    let username: String = row[Password.usernameC]
                    let passwordText: String = row[Password.passwordC]
                    let notes: String? = row[Password.notesC]
                    let createdAt: Date = row[Password.createdAtC]
                    let lastModified: Date = row[Password.lastModifiedC]
                    let isFavorite: Bool = row[Password.isFavoriteC]
                    let lastCopied: Date? = row[Password.lastCopiedDateC]
                    let url: String? = row[Password.urlC]
                    passwords.append(Password(id: id, title: title, username: username, password: passwordText, notes: notes, createdAt: createdAt, lastModified: lastModified, isFavorite: isFavorite, url: url, lastCopiedDate: lastCopied))
                }
            }
        } catch {
            print(error)
        }
        return passwords
    }
}

extension DatabaseAdapter: MasterPasswordDatabaseProtocol {
    func deleteAll(table name: String) {
        do {
            try database.writeInTransaction { db in
                let sql = "DELETE FROM \(name);"
                try db.execute(sql)
                return .commit
            }
        } catch {
            print(error)
        }
    }
    func fetchPassword(table name: String) -> String? {
        var password: String?
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(MasterPasswordRepository.tableName)")
                for row in rows {
                    password = row[Password.passwordC]
                }
            }
        } catch {
            print(error)
        }
        return password
    }
}

extension DatabaseAdapter: MedicalDatabaseProtocol {
    func fetchMedical() -> [Medical] {
        var medicals: [Medical] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(Medical.databaseTableName)")
                for row in rows {
                    let id: Int = row[Medical.idC]
                    let title: String = row[Medical.titleC]
                    let type: MedicalType = MedicalType(rawValue: row[Medical.typeC]) ?? .checkup
                    let hospital: String? = row[Medical.hospitalC]
                    let doctor: String? = row[Medical.doctorC]
                    let date: Date = row[Medical.dateC]
                    let createdAt: Date = row[Medical.createdAtC]
                    let lastModified: Date = row[Medical.lastModifiedC]
                    let notes: String? = row[Medical.notesC]
                    let receipt: String? = row[Medical.receiptC]
                    let endDate: Date? = row[Medical.endDateC]
                    let status: Bool = row[Medical.statusC]
                    medicals.append(Medical(id: id, title: title, type: type,hospital: hospital, doctor: doctor,date: date,createdAt: createdAt, lastModified: lastModified,status: status, notes: notes, receipt: receipt, endDate: endDate))
                }
            }
        } catch {
            print(error)
        }
        return medicals
    }
    func setStaus(table name: String, column: String,id: Int, value: Bool,endDate: Date?) {
        do {
            try database.writeInTransaction { db in
                let sql = "UPDATE \(name) SET \(column) = ?, \(Medical.endDateC) = ? WHERE id = ?"
                try db.execute(sql, [value,endDate,id])
                return .commit
            }
        } catch {
            print(error)
        }
    }

    func fetchActiveMedical() -> [Medical] {
        var medicals: [Medical] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(Medical.databaseTableName) WHERE \(Medical.statusC) = ? ",parameters: [true])
                for row in rows {
                    let id: Int = row[Medical.idC]
                    let title: String = row[Medical.titleC]
                    let type: MedicalType = MedicalType(rawValue: row[Medical.typeC]) ?? .checkup
                    let hospital: String? = row[Medical.hospitalC]
                    let doctor: String? = row[Medical.doctorC]
                    let date: Date = row[Medical.dateC]
                    let createdAt: Date = row[Medical.createdAtC]
                    let lastModified: Date = row[Medical.lastModifiedC]
                    let notes: String? = row[Medical.notesC]
                    let receipt: String? = row[Medical.receiptC]
                    let endDate: Date? = row[Medical.endDateC]
                    let status: Bool = row[Medical.statusC]
                    medicals.append(Medical(id: id, title: title, type: type,hospital: hospital, doctor: doctor,date: date,createdAt: createdAt, lastModified: lastModified,status: status, notes: notes, receipt: receipt, endDate: endDate))
                }
            }
        } catch {
            print(error)
        }
        return medicals
    }
    
}

extension DatabaseAdapter: MedicineDatabaseProtocol {
    
    func fetchActiveMedicines(_ medicalId: Int) -> [Medicine] {
        var medicalItems: [Medicine] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(Medicine.databaseTableName) WHERE \(Medicine.medicalC) = ? ;",parameters: [medicalId])
                for row in rows {
                    let id: Int = row[Medicine.idC]
                    let medical: Int = row[Medicine.medicalC]
                    let kind: MedicalKind = MedicalKind(rawValue: row[Medicine.kindC]) ?? MedicalKind.tablet
                    let name: String = row[Medicine.nameC]
                    let instruction: String = row[Medicine.instructionC]
                    let medicalInstruction = MedicalInstruction.valueOf(instruction)
                    let dosage: String = row[Medicine.dosageC]
                    let startDate: Date = row[Medicine.startDateC]
                    let endDate: Date? = row[Medicine.endDateC]
                    let schedule: String = row[Medicine.sheduleC]
                    let status: Bool = row[Medicine.statusC]
                    let medicalShcedule: [MedicalSchedule] = .from(dbValue: schedule)
                    medicalItems.append(Medicine(id: id, medical: medical, kind: kind, name: name, instruction: medicalInstruction, dosage: dosage, startDate: startDate,shedule: medicalShcedule,endDate: endDate, status: status))
                }
            }
        } catch {
            print(error)
        }
        return medicalItems

    }
    
    func fetchActiveMedicines() -> [Medicine] {
        var medicalItems: [Medicine] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(Medicine.databaseTableName) WHERE  \(Medicine.statusC)  = ? ;",parameters: [true])
                for row in rows {
                    let id: Int = row[Medicine.idC]
                    let medical: Int = row[Medicine.medicalC]
                    let kind: MedicalKind = MedicalKind(rawValue: row[Medicine.kindC]) ?? MedicalKind.tablet
                    let name: String = row[Medicine.nameC]
                    let instruction: String = row[Medicine.instructionC]
                    let medicalInstruction = MedicalInstruction.valueOf(instruction)
                    let dosage: String = row[Medicine.dosageC]
                    let startDate: Date = row[Medicine.startDateC]
                    let endDate: Date? = row[Medicine.endDateC]
                    let schedule: String = row[Medicine.sheduleC]
                    let status: Bool = row[Medicine.statusC]
                    let medicalShcedule: [MedicalSchedule] = .from(dbValue: schedule)
                    medicalItems.append(Medicine(id: id, medical: medical, kind: kind, name: name, instruction: medicalInstruction, dosage: dosage, startDate: startDate,shedule: medicalShcedule,endDate: endDate, status: status))
                }
            }
        } catch {
            print(error)
        }
        return medicalItems

    }
    
    
    func fetchMedicinesById(_ id: Int, kind: MedicalKind) -> [Medicine] {
        var medicalItems: [Medicine] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(Medicine.databaseTableName) WHERE \(Medicine.medicalC) = ? AND \(Medicine.kindC) = ? ",parameters: [id, kind.rawValue])
                for row in rows {
                    let id: Int = row[Medicine.idC]
                    let medical: Int = row[Medicine.medicalC]
                    let kind: MedicalKind = MedicalKind(rawValue: row[Medicine.kindC]) ?? MedicalKind.tablet
                    let name: String = row[Medicine.nameC]
                    let instruction: String = row[Medicine.instructionC]
                    let medicalInstruction = MedicalInstruction.valueOf(instruction)
                    let dosage: String = row[Medicine.dosageC]
                    let startDate: Date = row[Medicine.startDateC]
                    let endDate: Date? = row[Medicine.endDateC]
                    let schedule: String = row[Medicine.sheduleC]
                    let status: Bool = row[Medicine.statusC]
                    let medicalShcedule: [MedicalSchedule] = .from(dbValue: schedule)
                    medicalItems.append(Medicine(id: id, medical: medical, kind: kind, name: name, instruction: medicalInstruction, dosage: dosage, startDate: startDate,shedule: medicalShcedule,endDate: endDate, status: status))
                }
            }
        } catch {
            print(error)
        }
        return medicalItems
    }
}

extension DatabaseAdapter: MedicalIntakeLogDatabase {
    func fetchLog(medicalId: Int,date: Date) -> [MedicineIntakeLog] {
        var logs: [MedicineIntakeLog] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(MedicineIntakeLog.databaseTableName) WHERE \(MedicineIntakeLog.medicineIdC) = ? AND \(MedicineIntakeLog.dateC) = ? ",parameters: [medicalId, date])
                //
                for row in rows {
                    let id: Int = row[MedicineIntakeLog.idC]
                    let medicineId: Int = row[MedicineIntakeLog.medicineIdC]
                    let date: Date = row[MedicineIntakeLog.dateC]
                    let schedule: String = row[MedicineIntakeLog.scheduleC]
                    let medicalSchedule: MedicalSchedule = MedicalSchedule(rawValue: schedule) ?? .morning
                    let taken: Bool = row[MedicineIntakeLog.takenC]
                    
                    logs.append(MedicineIntakeLog(id: id, medicineId: medicineId, date: date, schedule: medicalSchedule, taken: taken))
                }
            }
        } catch {
            print(error)
        }
        return logs

    }
    func fetchLog(medicalId: Int) -> [MedicineIntakeLog] {
        var logs: [MedicineIntakeLog] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(MedicineIntakeLog.databaseTableName) WHERE \(MedicineIntakeLog.medicineIdC) = ? ; ",parameters: [medicalId])
                
                for row in rows {
                    let id: Int = row[MedicineIntakeLog.idC]
                    let medicineId: Int = row[MedicineIntakeLog.medicineIdC]
                    let date: Date = row[MedicineIntakeLog.dateC]
                    let schedule: String = row[MedicineIntakeLog.scheduleC]
                    let medicalSchedule: MedicalSchedule = MedicalSchedule(rawValue: schedule) ?? .morning
                    let taken: Bool = row[MedicineIntakeLog.takenC]
                    
                    logs.append(MedicineIntakeLog(id: id, medicineId: medicineId, date: date, schedule: medicalSchedule, taken: taken))
                }
            }
        } catch {
            print(error)
        }
        return logs

    }
 
}


extension DatabaseAdapter: UserDatebaseProtocol {
    func updatePassword(userId: Int, newHash: String) {
        do {
            try database.writeInTransaction { db in
                let sql = "UPDATE \(User.databaseTableName) SET password = ? WHERE id = ?"
                try db.execute(sql, [newHash, userId])
                return .commit
            }
        } catch {
            print(error)
        }

    }
    func getUserByEmail(_ email: String) -> User? {
        var user: User?
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(User.databaseTableName) WHERE \(User.emailC) = ? ",parameters: [email])
                
                for row in rows {
                    let id: Int = row[User.idC]
                    let email: String = row[User.emailC]
                    let name: String = row[User.nameC]
                    let password: String = row[User.passwordC]
                    user = User(id: id, email: email, name: name, password: password)
                }
            }
        } catch {
            print(error)
        }
        return user

        
    }
    func getUserById(_ id: Int) -> User? {
        var user: User?
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(User.databaseTableName) WHERE \(User.idC) = ? ",parameters: [id])
                
                for row in rows {
                    let id: Int = row[User.idC]
                    let email: String = row[User.emailC]
                    let name: String = row[User.nameC]
                    let password: String = row[User.passwordC]
                    user = User(id: id, email: email, name: name, password: password)
                }
            }
        } catch {
            print(error)
        }
        return user

        
    }
}

extension DatabaseAdapter: LoginDatebaseProtocol {
    
    func getLoginSession() -> LoginSession? {
        var session: LoginSession?
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(LoginSession.databaseTableName)")
                
                for row in rows {
                    let id: Int = row[LoginSession.userIdC]
                    let date: Date = row[LoginSession.lastLoginC]
                    session = LoginSession(userId: id, lastLogin: date)
                }
            }
        } catch {
            print(error)
        }
        return session

    }
}
/*

extension DatabaseAdapter: UtilityDatabaseProtocol {
    func fetchUtility() -> [Utility] {
        var utilities: [Utility] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(Utility.databaseTableName)")
                for row in rows {
                    let id: Int = row[Utility.idC]
                    let name: String = row[Utility.nameC]
                    utilities.append(Utility(id: id, name: name))
                }
            }
        } catch {
            print(error)
        }
        return utilities

    }
}

extension DatabaseAdapter: UtilityAccountDatabaseProtocol {
    
    func createUtilityAccountTable() {
        let sql = """
                CREATE TABLE IF NOT EXISTS \(UtilityAccount.databaseTableName) (
                \(UtilityAccount.idC) INTEGER PRIMARY KEY AUTOINCREMENT,
                \(UtilityAccount.utilityIdC) INTEGER NOT NULL,
                \(UtilityAccount.titleC) TEXT NOT NULL,
                \(UtilityAccount.accountNumberC) TEXT NOT NULL,
                \(UtilityAccount.providerC) TEXT NOT NULL,
                \(UtilityAccount.createdAtC) TEXT NOT NULL,
                \(UtilityAccount.lastModifiedC) TEXT NOT NULL,
                \(UtilityAccount.notesC) TEXT,

                FOREIGN KEY (\(UtilityAccount.utilityIdC))
                REFERENCES \(Utility.databaseTableName)(\(Utility.idC))
                ON DELETE CASCADE
                ON UPDATE CASCADE
                );
            """
        do {
            try database.writeInTransaction { db in
                try db.execute(sql)
                return .commit
            }

        } catch {
            print(error)
        }
    }
    
    func fetchUtilityAccounts(utilityId: Int) -> [UtilityAccount] {
        var utilityAccounts: [UtilityAccount] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(UtilityAccount.databaseTableName) WHERE \(UtilityAccount.utilityIdC) = ? ",parameters: [utilityId])
                
                for row in rows {
                    let id: Int = row[UtilityAccount.idC]
                    let utilityId: Int = row[UtilityAccount.utilityIdC]
                    let title: String = row[UtilityAccount.titleC]
                    let accountNumber: String = row[UtilityAccount.accountNumberC]
                    let providerC: String = row[UtilityAccount.providerC]
                    let createdAtC: Date = row[UtilityAccount.createdAtC]
                    let lastModifiedC: Date = row[UtilityAccount.lastModifiedC]
                    let notes: String? = row[UtilityAccount.notesC]
                    
                    utilityAccounts.append(UtilityAccount(id: id, utilityId: utilityId, title: title, accountNumber: accountNumber, provider: providerC, createdAt: createdAtC,lastModified: lastModifiedC, notes:   notes))
                }
            }
        } catch {
            print(error)
        }
        return utilityAccounts
    }
}

extension DatabaseAdapter: BillDatabaseProtocol {
    func createBillTable() {
        let sql = """
                CREATE TABLE IF NOT EXISTS \(Bill.databaseTableName) (
                \(Bill.idC) INTEGER PRIMARY KEY AUTOINCREMENT,
                \(Bill.utilityAccountIdC) INTEGER NOT NULL,
                \(Bill.billTypeC) TEXT NOT NULL,
                \(Bill.amountC) TEXT NOT NULL,
                \(Bill.dueDateC) TEXT,
                \(Bill.paidDateC) TEXT,
                \(Bill.createdAtC) TEXT NOT NULL,
                \(Bill.lastModifiedC) TEXT NOT NULL,
                \(Bill.notesC) TEXT,
                
                FOREIGN KEY (\(Bill.utilityAccountIdC))
                REFERENCES \(UtilityAccount.databaseTableName)(\(UtilityAccount.idC))
                ON DELETE CASCADE
                ON UPDATE CASCADE
                );
            """
        do {
            try database.writeInTransaction { db in
                try db.execute(sql)
                return .commit
            }

        } catch {
            print(error)
        }

    }
    
    func fetchBillByUtilityAccountId(utilityAccoundId: Int, billType: BillType) -> [Bill] {
        var bills: [Bill] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(Bill.databaseTableName) WHERE \(Bill.utilityAccountIdC) = ? AND \(Bill.billTypeC) = ? ",parameters: [utilityAccoundId, billType.rawValue])
                
                for row in rows {
                    let id: Int = row[Bill.idC]
                    let utilityId: Int = row[Bill.utilityAccountIdC]
                    let type: String = row[Bill.billTypeC]
                    let billType: BillType = BillType(rawValue: type) ?? .ongoing
                    let amount: Double = row[Bill.amountC]
                    let dueDate: Date? = row[Bill.dueDateC]
                    let paidDate: Date? = row[Bill.paidDateC]
                    let createdAtC: Date = row[Bill.createdAtC]
                    let lastModifiedC: Date = row[Bill.lastModifiedC]
                    let notes: String? = row[Bill.notesC]
                    
                    bills.append(Bill(id: id, utilityAccountId: utilityId, amount: amount, billType: billType,dueDate: dueDate, paidDate: paidDate, createdAt: createdAtC, lastModified: lastModifiedC, notes: notes))
                }
            }
        } catch {
            print(error)
        }
        return bills

    }
    
    func markAsPaid(billId: Int, paidDate: Date) {
        do {
            try database.writeInTransaction { db in
                let sql = "UPDATE \(Bill.databaseTableName) SET \(Bill.paidDateC) = ? , \(Bill.billTypeC) = ? WHERE id = ?"
                try db.execute(sql, [paidDate,BillType.completed.rawValue,billId])
                return .commit
            }
        } catch {
            print(error)
        }

    }
    
}
*/
