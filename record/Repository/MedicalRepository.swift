//
//  MedicalRepository.swift
//  record
//
//  Created by Esakkinathan B on 07/02/26.
//

import VTDB
class MedicalRepository: MedicalRepositoryProtocol {
    var db: MedicalDatabaseProtocol = DatabaseAdapter.shared
    init() {
        createTable()
    }
    static let idC = "id"
    static let titleC =  "title"
    static let typeC =  "type"
    static let hospitalC = "hospital"
    static let doctorC = "doctor"
    static let dateC =  "date"
    static let createdAtC =  "createdAt"
    static let notesC = "notes"

    func createTable() {
//        do {
//            try db.database.writeInTransaction { db in
//                let sql = "DROP TABLE \(Medical.databaseTableName);"
//                try db.execute(sql)
//                return .commit
//            }
//        } catch {
//            print(error)
//        }
        let colums: [String: TableColumnType] = [
            Medical.idC: .int,
            Medical.titleC: .string,
            Medical.typeC: .string,
            Medical.hospitalC: .string,
            Medical.doctorC: .string,
            Medical.dateC: .date,
            Medical.createdAtC: .date,
            Medical.lastModifiedC: .date,
            Medical.notesC: .text,
            
        ]
        db.create(table: Medical.databaseTableName, columnDefinitions: colums, primaryKey: [Medical.idC])
    }
    
    func add(medical: Medical) {
        let columns: [String: Any?] = [
            Medical.titleC: medical.title,
            Medical.typeC: medical.type.rawValue,
            Medical.hospitalC: medical.hospital,
            Medical.doctorC: medical.doctor,
            Medical.dateC: medical.date,
            Medical.createdAtC: medical.createdAt,
            Medical.lastModifiedC: medical.lastModified,
            Medical.notesC: medical.notes
        ]
        
        db.insertInto(tableName: Medical.databaseTableName, values: columns)
    }
    
    func update(medical: Medical) {
        db.updateInto(data: medical)
    }
    
    func updateNotes(text: String?, id: Int) {
        db.updateNotes(table: Medical.databaseTableName, id: id, text: text, date: Date())
    }

    func delete(id: Int) {
        db.delete(table: Medical.databaseTableName, id: id)
    }
    
    func fetchAll() -> [Medical] {
        return db.fetchMedical()
    }
    
}


class MedicalItemRepository: MedicalItemRepositoryProtocol {
    var db: MedicalItemDatabaseProtocol =  DatabaseAdapter.shared
    
    init() {
        //createTable()
    }
    func createTable() {

        db.createTable()
    }
    
    func add(medicalItem: MedicalItem, medicalId: Int) {
        let columns: [String: Any?] = [
            MedicalItem.medicalC: medicalId,
            MedicalItem.kindC: medicalItem.kind.rawValue,
            MedicalItem.nameC: medicalItem.name,
            MedicalItem.instructionC: medicalItem.instruction.value,
            MedicalItem.dosageC: medicalItem.dosage,
            MedicalItem.sheduleC: medicalItem.shedule.dbValue,
            MedicalItem.durationC: medicalItem.duration,
            MedicalItem.durationTypeC: medicalItem.durationType.rawValue
        ]
        
        db.insertInto(tableName: MedicalItem.databaseTableName, values: columns)
    }
    
    func update(medicalItem: MedicalItem) {
        db.updateInto(data: medicalItem)
    }
    
    func delete(id: Int) {
        db.delete(table: MedicalItem.databaseTableName, id: id)
    }
    
    func fetchByMedicalId(_ id: Int, kind: MedicalKind) -> [MedicalItem] {
        return db.fetchMedialItemById(id, kind: kind)
    }
}
