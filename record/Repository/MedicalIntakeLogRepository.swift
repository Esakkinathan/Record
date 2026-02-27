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
    func fetch(medicalId: Int) -> [MedicalIntakeLog] {
        return db.fetchLog(medicalId: medicalId)
    }

}
