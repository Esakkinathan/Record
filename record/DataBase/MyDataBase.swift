//
//  DataBase.swift
//  record
//
//  Created by Esakkinathan B on 29/01/26.
//


protocol DatabaseProtocol {
    func create(table name: String, columnDefinitions: [String: TableColumnType], primaryKey: [String])
    func create(table name: String, columnDefinitions: [String: TableColumnType], primaryKey: [String], uniqueKeys: [[String]])
    func insertInto(tableName: String, values: [TableColumnName: TableColumnValue])
    func updateInto(data: Persistable)
    func delete(table name: String, id: Int)
    func updateNotes(table name: String, id: Int, text: String?, date : Date)
}

protocol DocumentDatabaseProtocol: DatabaseProtocol {
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
}


protocol MedicalItemDatabaseProtocol: DatabaseProtocol {
    func createTable()
    func fetchMedialItemById(_ id: Int, kind: MedicalKind) -> [MedicalItem]
}
import VTDB
import SQLCipher


typealias TableColumnType = Database.ColumnType
typealias TableColumnName = String
typealias TableColumnValue = Any?
typealias ConflictResolution = Database.ConflictResolution

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
    private init() throws {
        var configuration = Configuration()
        configuration.foreignKeysEnabled = true
        configuration.trace = {
            print("q: \($0)") // To trace all queries
        }
        database = try DatabaseQueue(
            path: DatabaseAdapter.getPath(),
            configuration: configuration
        )
        databaseName = DatabaseAdapter.getPath()

        registerCollation()
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
    
    static func getPath() -> String {
        let cwd =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
        return (cwd as NSString).appendingPathComponent("record.sqlite")
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
                try data.update(db)
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
    func toggle(table name: String, id: Int, value: Bool,lastModified: Date) {
        do {
            try database.writeInTransaction { db in
                let sql = "UPDATE \(name) SET isFavorite = ?, lastModified = ? WHERE id = ?"
                try db.execute(sql, [value,lastModified,id])
                return .commit
            }
        } catch {
            print(error)
        }
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
                    document.append(Document(id: id, name: name, number: number,createdAt: createdAt,expiryDate: expiryDate,file: file,notes: notes,lastModified: lastModified))
                }
            }
        } catch {
            print(error)
        }
        return document
        
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
                    passwords.append(Password(id: id, title: title, username: username, password: passwordText, notes: notes, createdAt: createdAt, lastModified: lastModified, isFavorite: isFavorite))
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
                    let date: Date? = row[Medical.dateC]
                    let createdAt: Date = row[Medical.createdAtC]
                    let lastModified: Date = row[Medical.lastModifiedC]
                    let notes: String? = row[Medical.notesC]
                    medicals.append(Medical(id: id, title: title, type: type, hospital: hospital, doctor: doctor,date: date,createdAt: createdAt, lastModified: lastModified,notes: notes))
                }
            }
        } catch {
            print(error)
        }
        return medicals
    }
    
}

extension DatabaseAdapter: MedicalItemDatabaseProtocol {
    
    func createTable() {
        
//        do {
//            try database.writeInTransaction { db in
//                let sql = "DROP TABLE \(MedicalItem.databaseTableName);"
//                try db.execute(sql)
//                return .commit
//            }
//        } catch {
//            print(error)
//        }

        let sql = """
                CREATE TABLE IF NOT EXISTS \(MedicalItem.databaseTableName) (
                \(MedicalItem.idC) INTEGER PRIMARY KEY AUTOINCREMENT,
                \(MedicalItem.medicalC) INTEGER NOT NULL,
                \(MedicalItem.kindC) TEXT NOT NULL,
                \(MedicalItem.nameC) TEXT NOT NULL,
                \(MedicalItem.instructionC) TEXT NOT NULL,
                \(MedicalItem.dosageC) TEXT NOT NULL,
                \(MedicalItem.sheduleC) TEXT NOT NULL,
                \(MedicalItem.durationC) INTEGER NOT NULL,
                \(MedicalItem.durationTypeC) TEXT NOT NULL,

                FOREIGN KEY (\(MedicalItem.medicalC))
                REFERENCES \(Medical.databaseTableName)(\(Medical.idC))
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

    func fetchMedialItemById(_ id: Int, kind: MedicalKind) -> [MedicalItem] {
        var medicalItems: [MedicalItem] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(MedicalItem.databaseTableName) WHERE \(MedicalItem.medicalC) = ? AND \(MedicalItem.kindC) = ? ",parameters: [id, kind.rawValue])
                for row in rows {
                    let id: Int = row[MedicalItem.idC]
                    let medical: Int = row[MedicalItem.medicalC]
                    let kind: MedicalKind = MedicalKind(rawValue: row[MedicalItem.kindC]) ?? MedicalKind.tablet
                    let name: String = row[MedicalItem.nameC]
                    let instruction: String = row[MedicalItem.instructionC]
                    let medicalInstruction = MedicalInstruction.valueOf(instruction)
                    let dosage: String = row[MedicalItem.dosageC]
                    let schedule: String = row[MedicalItem.sheduleC]
                    let medicalScedule: [MedicalSchedule] = .from(dbValue: schedule)
                    let duration: Int = row[MedicalItem.durationC]
                    let durationType: String = row[MedicalItem.durationTypeC]
                    let medicalDurationType = DurationType.valueOf(input: durationType)
                    medicalItems.append(MedicalItem(id: id, medical: medical, kind: kind, name: name, instruction: medicalInstruction, dosage: dosage, shedule: medicalScedule, duration: duration, durationType: medicalDurationType))
                }
            }
        } catch {
            print(error)
        }
        return medicalItems
    }

}
