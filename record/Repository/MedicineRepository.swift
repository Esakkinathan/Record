//
//  Medicine.swift
//  record
//
//  Created by Esakkinathan B on 02/03/26.
//

import Foundation

class MedicineRepository: MedicineRepositoryProtocol {
    
    var db: MedicineDatabaseProtocol =  DatabaseAdapter.shared
    
    init() {
    }
    
    func add(medicine: Medicine, medicalId: Int) {
        let columns: [String: Any?] = [
            Medicine.medicalC: medicalId,
            Medicine.kindC: medicine.kind.rawValue,
            Medicine.nameC: medicine.name,
            Medicine.instructionC: medicine.instruction.value,
            Medicine.dosageC: medicine.dosage,
            Medicine.startDateC: medicine.startDate,
            Medicine.sheduleC: medicine.shedule.dbValue,
            Medicine.endDateC: medicine.endDate,
            Medicine.statusC: medicine.status,
        ]
        
        db.insertInto(tableName: Medicine.databaseTableName, values: columns)
    }
    
    
    func update(medicine: Medicine) {
        db.updateInto(data: medicine)
    }
    
    func delete(id: Int) {
        db.delete(table: Medicine.databaseTableName, id: id)
    }
    
    func fetchMedicinesByMedicalId(_ id: Int, kind: MedicalKind) -> [Medicine] {
        return db.fetchMedicinesById(id, kind: kind)
    }
    
    func fetchActiveMedicines(_ medicalId: Int) -> [Medicine] {
        return db.fetchActiveMedicines(medicalId)
    }
    
    func fetchActiveMedicines() -> [Medicine] {
        return db.fetchActiveMedicines()
    }
    func setStatus(id: Int,value: Bool, date: Date?) {
        db.setStaus(table: Medicine.databaseTableName, column: Medicine.statusC, id: id, value: value, endDate: date)
    }
//    func fetchMedicines(for medicalId: Int) -> [Medicine] {
//        
//    }
}
