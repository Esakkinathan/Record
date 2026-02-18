//
//  MedicalIntakeLog.swift
//  record
//
//  Created by Esakkinathan B on 18/02/26.
//
import VTDB


class MedicalIntakeLogRepository: MedicalIntakeLogRepositoryProtocol {
    var db: MedicalIntakeLogDatabase = DatabaseAdapter.shared
    
    init() {
        createTable()
    }
    func createTable() {
//        do {
//            try db.database.writeInTransaction { db in
//                let sql = "DROP TABLE \(MedicalIntakeLog.databaseTableName);"
//                try db.execute(sql)
//                return .commit
//            }
//        } catch {
//            print(error)
//        }
        db.createLogTable()
//        let columns: [String: TableColumnType] = [
//            MedicalIntakeLog.idC: .int,
//            MedicalIntakeLog.medicalItemIdC: .int,
//            MedicalIntakeLog.dateC: .date,
//            MedicalIntakeLog.scheduleC: .string,
//            MedicalIntakeLog.takenC: .bool,
//            
//        ]
//        db.create(table: MedicalIntakeLog.databaseTableName, columnDefinitions: columns, primaryKey: [MedicalIntakeLog.idC])

    }
    
    func add(log: MedicalIntakeLog) {
        let columns: [String: Any?] = [
            MedicalIntakeLog.medicalItemIdC: log.medicalItemId,
            MedicalIntakeLog.dateC: log.date,
            MedicalIntakeLog.scheduleC: log.schedule.rawValue,
            MedicalIntakeLog.takenC: log.taken,
        ]
        
        db.insertInto(tableName: MedicalIntakeLog.databaseTableName, values: columns)

    }
    func update(log: MedicalIntakeLog) {
        db.updateInto(data: log)
    }

    func fetch(medicalId: Int,date: Date) -> [MedicalIntakeLog] {
        return db.fetchLog(medicalId: medicalId, date: date)
    }
}
