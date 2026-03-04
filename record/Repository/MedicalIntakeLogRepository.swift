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
    
    func add(log: MedicineIntakeLog) {
        let columns: [String: Any?] = [
            MedicineIntakeLog.medicineIdC: log.medicineId,
            MedicineIntakeLog.dateC: log.date,
            MedicineIntakeLog.scheduleC: log.schedule.rawValue,
            MedicineIntakeLog.takenC: log.taken,
        ]
        
        db.insertInto(tableName: MedicineIntakeLog.databaseTableName, values: columns)

    }
    func update(log: MedicineIntakeLog) {
        db.updateInto(data: log)
    }

    func fetch(medicalId: Int,date: Date) -> [MedicineIntakeLog] {
        return db.fetchLog(medicalId: medicalId, date: date)
    }
    func fetch(medicalId: Int) -> [MedicineIntakeLog] {
        return db.fetchLog(medicalId: medicalId)
    }

}
