//
//  DataBase.swift
//  record
//
//  Created by Esakkinathan B on 29/01/26.
//
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
//        dropTable(table: Document.databaseTableName)
//        dropTable(table: Password.databaseTableName)
//        dropTable(table: Medical.databaseTableName)
//        dropTable(table: MedicalItem.databaseTableName)
//        dropTable(table: MedicalIntakeLog.databaseTableName)
        
        let docuementColumns: [String: TableColumnType] = [
            Document.idC: .int,
            Document.nameC: .string,
            Document.numberC: .string,
            Document.createdAtC: .date,
            Document.expiryDateC: .date,
            Document.fileC: .blob,
            Document.notesC: .text,
            Document.lastModifiedC: .date
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
            Password.isFavoriteC: .bool
        ]
        create(table: Password.databaseTableName, columnDefinitions: passwordColumns, primaryKey: [Document.idC], uniqueKeys:[[Password.idC,Password.titleC]])
        
        let medicalColumns: [String: TableColumnType] = [
            Medical.idC: .int,
            Medical.titleC: .string,
            Medical.typeC: .string,
            Medical.durationC: .int,
            Medical.durationTypeC: .string,
            Medical.hospitalC: .string,
            Medical.doctorC: .string,
            Medical.dateC: .date,
            Medical.createdAtC: .date,
            Medical.lastModifiedC: .date,
            Medical.notesC: .text,
            Medical.receiptC: .blob,
            
        ]
        
        create(table: Medical.databaseTableName, columnDefinitions: medicalColumns, primaryKey: [Medical.idC])
        let medicalItemSql = """
                CREATE TABLE IF NOT EXISTS \(MedicalItem.databaseTableName) (
                \(MedicalItem.idC) INTEGER PRIMARY KEY AUTOINCREMENT,
                \(MedicalItem.medicalC) INTEGER NOT NULL,
                \(MedicalItem.kindC) TEXT NOT NULL,
                \(MedicalItem.nameC) TEXT NOT NULL,
                \(MedicalItem.instructionC) TEXT NOT NULL,
                \(MedicalItem.dosageC) TEXT NOT NULL,
                \(MedicalItem.startDateC) TEXT NOT NULL,
                \(MedicalItem.endDateC) TEXT NOT NULL,
                \(MedicalItem.sheduleC) TEXT NOT NULL,

                FOREIGN KEY (\(MedicalItem.medicalC))
                REFERENCES \(Medical.databaseTableName)(\(Medical.idC))
                ON DELETE CASCADE
                ON UPDATE CASCADE
                );
            """
        let medicalLogSql = """
                CREATE TABLE IF NOT EXISTS \(MedicalIntakeLog.databaseTableName) (
                \(MedicalIntakeLog.idC) INTEGER PRIMARY KEY AUTOINCREMENT,
                \(MedicalIntakeLog.medicalItemIdC) INTEGER NOT NULL,
                \(MedicalIntakeLog.dateC) TEXT NOT NULL,
                \(MedicalIntakeLog.scheduleC) TEXT NOT NULL,
                \(MedicalIntakeLog.takenC) INTEGER NOT NULL,
            
                FOREIGN KEY (\(MedicalIntakeLog.medicalItemIdC))
                REFERENCES \(MedicalItem.databaseTableName)(\(MedicalItem.idC))
                ON DELETE CASCADE
                ON UPDATE CASCADE
                );
            """

        do {
            try database.writeInTransaction { db in
                try db.execute(medicalItemSql)
                try db.execute(medicalLogSql)
                
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
                    let duration: Int = row[Medical.durationC]
                    let durationType: DurationType = DurationType(rawValue: row[Medical.durationTypeC]) ?? .day
                    let hospital: String? = row[Medical.hospitalC]
                    let doctor: String? = row[Medical.doctorC]
                    let date: Date = row[Medical.dateC]
                    let createdAt: Date = row[Medical.createdAtC]
                    let lastModified: Date = row[Medical.lastModifiedC]
                    let notes: String? = row[Medical.notesC]
                    let receipt: String? = row[Medical.receiptC]
                    medicals.append(Medical(id: id, title: title, type: type, duration: duration, durationType: durationType,hospital: hospital, doctor: doctor,date: date,createdAt: createdAt, lastModified: lastModified,notes: notes,receipt: receipt))
                }
            }
        } catch {
            print(error)
        }
        return medicals
    }
    
    func fetchMedicalByDate(date: Date) -> [Medical] {
        var medicals: [Medical] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(Medical.databaseTableName) WHERE \(Medical.dateC) <= ? ", parameters: [date])
                for row in rows {
                    let id: Int = row[Medical.idC]
                    let title: String = row[Medical.titleC]
                    let type: MedicalType = MedicalType(rawValue: row[Medical.typeC]) ?? .checkup
                    let duration: Int = row[Medical.durationC]
                    let durationType: DurationType = DurationType(rawValue: row[Medical.durationTypeC]) ?? .day
                    let hospital: String? = row[Medical.hospitalC]
                    let doctor: String? = row[Medical.doctorC]
                    let date: Date = row[Medical.dateC]
                    let createdAt: Date = row[Medical.createdAtC]
                    let lastModified: Date = row[Medical.lastModifiedC]
                    let notes: String? = row[Medical.notesC]
                    let receipt: String? = row[Medical.receiptC]
                    medicals.append(Medical(id: id, title: title, type: type, duration: duration, durationType: durationType,hospital: hospital, doctor: doctor,date: date,createdAt: createdAt, lastModified: lastModified,notes: notes, receipt: receipt))
                }
            }
        } catch {
            print(error)
        }
        return medicals
    }
    
}

extension DatabaseAdapter: MedicalItemDatabaseProtocol {
    func fetchActiveMedicalItem(_ medicalId: Int, date: Date) -> [MedicalItem] {
        var medicalItems: [MedicalItem] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(MedicalItem.databaseTableName) WHERE \(MedicalItem.medicalC) = ? AND \(MedicalItem.endDateC) >= ? ;",parameters: [medicalId, date])
                for row in rows {
                    let id: Int = row[MedicalItem.idC]
                    let medical: Int = row[MedicalItem.medicalC]
                    let kind: MedicalKind = MedicalKind(rawValue: row[MedicalItem.kindC]) ?? MedicalKind.tablet
                    let name: String = row[MedicalItem.nameC]
                    let instruction: String = row[MedicalItem.instructionC]
                    let medicalInstruction = MedicalInstruction.valueOf(instruction)
                    let dosage: String = row[MedicalItem.dosageC]
                    let startDate: Date = row[MedicalItem.startDateC]
                    let endDate: Date = row[MedicalItem.endDateC]
                    let schedule: String = row[MedicalItem.sheduleC]
                    let medicalShcedule: [MedicalSchedule] = .from(dbValue: schedule)
                    medicalItems.append(MedicalItem(id: id, medical: medical, kind: kind, name: name, instruction: medicalInstruction, dosage: dosage, startDate: startDate,shedule: medicalShcedule,endDate: endDate))
                }
            }
        } catch {
            print(error)
        }
        return medicalItems

    }
    
    func fetchMedicalItems(from date: Date, to dateTo: Date) -> [MedicalItem] {
        var medicalItems: [MedicalItem] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(MedicalItem.databaseTableName) WHERE  \(MedicalItem.endDateC)  >= ? ;",parameters: [date])
                for row in rows {
                    let id: Int = row[MedicalItem.idC]
                    let medical: Int = row[MedicalItem.medicalC]
                    let kind: MedicalKind = MedicalKind(rawValue: row[MedicalItem.kindC]) ?? MedicalKind.tablet
                    let name: String = row[MedicalItem.nameC]
                    let instruction: String = row[MedicalItem.instructionC]
                    let medicalInstruction = MedicalInstruction.valueOf(instruction)
                    let dosage: String = row[MedicalItem.dosageC]
                    let startDate: Date = row[MedicalItem.startDateC]
                    let endDate: Date = row[MedicalItem.endDateC]
                    let schedule: String = row[MedicalItem.sheduleC]
                    let medicalShcedule: [MedicalSchedule] = .from(dbValue: schedule)
                    medicalItems.append(MedicalItem(id: id, medical: medical, kind: kind, name: name, instruction: medicalInstruction, dosage: dosage, startDate: startDate,shedule: medicalShcedule,endDate: endDate))
                }
            }
        } catch {
            print(error)
        }
        return medicalItems

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
                    let startDate: Date = row[MedicalItem.startDateC]
                    let endDate: Date = row[MedicalItem.endDateC]
                    let schedule: String = row[MedicalItem.sheduleC]
                    let medicalShcedule: [MedicalSchedule] = .from(dbValue: schedule)
                    medicalItems.append(MedicalItem(id: id, medical: medical, kind: kind, name: name, instruction: medicalInstruction, dosage: dosage, startDate: startDate,shedule: medicalShcedule,endDate: endDate))
                }
            }
        } catch {
            print(error)
        }
        return medicalItems
    }
    func updateEndDate(medicalItemId: Int, date: Date) {
        let sql = "UPDATE \(MedicalItem.databaseTableName) SET \(MedicalItem.endDateC) = ? , \(MedicalItem.idC) = ? WHERE id = ?"
        do {
            try database.write { db in
                try db.execute(sql, [date,medicalItemId])
            }

        } catch {
            print(error)
        }

    }

}

extension DatabaseAdapter: MedicalIntakeLogDatabase {
    func fetchLog(medicalId: Int,date: Date) -> [MedicalIntakeLog] {
        var logs: [MedicalIntakeLog] = []
        do {
            try database.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(MedicalIntakeLog.databaseTableName) WHERE \(MedicalIntakeLog.medicalItemIdC) = ? AND \(MedicalIntakeLog.dateC) = ? ",parameters: [medicalId, date])
                
                for row in rows {
                    let id: Int = row[MedicalIntakeLog.idC]
                    let medicalItemId: Int = row[MedicalIntakeLog.medicalItemIdC]
                    let date: Date = row[MedicalIntakeLog.dateC]
                    let schedule: String = row[MedicalIntakeLog.scheduleC]
                    let medicalSchedule: MedicalSchedule = MedicalSchedule(rawValue: schedule) ?? .morning
                    let taken: Bool = row[MedicalIntakeLog.takenC]
                    
                    logs.append(MedicalIntakeLog(id: id, medicalItemId: medicalItemId, date: date, schedule: medicalSchedule, taken: taken))
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
