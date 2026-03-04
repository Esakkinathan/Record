//
//  MedicalRepository.swift
//  record
//
//  Created by Esakkinathan B on 07/02/26.
//

import VTDB
import Foundation
import Foundation

extension Date {
    /// Generates a random Date between two specified dates.
    /// - Parameters:
    ///   - start: The earliest possible date.
    ///   - end: The latest possible date.
    /// - Returns: A random Date within the start and end range.
    static func randomBetween(start: Date, end: Date) -> Date {
        let startInterval = start.timeIntervalSince1970
        let endInterval = end.timeIntervalSince1970

        // Ensure the start date is before the end date
        guard startInterval <= endInterval else {
            return randomBetween(start: end, end: start)
        }

        // Generate a random time interval between the start and end intervals
        let randomInterval = TimeInterval.random(in: startInterval...endInterval)

        // Create a new Date using the random interval
        return Date(timeIntervalSince1970: randomInterval)
    }
}

class MedicalRepository: MedicalRepositoryProtocol {
    var db: MedicalDatabaseProtocol = DatabaseAdapter.shared
    
    init() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let startDate = dateFormatter.date(from: "2026-01-01")!
//        let endDate = dateFormatter.date(from: "2026-02-26")!
//        
//        for _ in 0...100 {
//            add(medical: Medical(id: 1, title: PasswordGenerator.generate(options: .init(length: Int.random(in: 1...30) , includeLetters: true, includeNumbers: false, includeSymbols: false)), type: MedicalType.allCases[Int.random(in: 0..<4)], duration: Int.random(in: 1...30), durationType: DurationType.allCases[Int.random(in: 0..<3)], date: Date.randomBetween(start: startDate, end: endDate)))
//        }
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
            Medical.notesC: medical.notes,
            Medical.receiptC: medical.receipt,
            Medical.endDateC: medical.endDate,
            Medical.statusC: medical.status,
        ]
        
        db.insertInto(tableName: Medical.databaseTableName, values: columns)
    }
    func fetchDoctors() -> [String] {
        return db.fetchDistinctValues(table: Medical.databaseTableName, column: Medical.doctorC)
    }
    
    func fetchHospitals() -> [String] {
        return db.fetchDistinctValues(table: Medical.databaseTableName, column: Medical.hospitalC)
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
    
    func fetchActiveMedical() -> [Medical] {
        return db.fetchActiveMedical()
    }
    
    func setStatus(id: Int,value: Bool, date: Date?) {
        db.setStaus(table: Medical.databaseTableName, column: Medical.statusC, id: id, value: value, endDate: date)
    }
}


