//
//  MedicalIntakeLog.swift
//  record
//
//  Created by Esakkinathan B on 17/02/26.
//

import Foundation
import VTDB

final class MedicineIntakeLog: Persistable {

    static let idC = "id"
    static let medicineIdC = "medicineId"
    static let dateC = "date"
    static let scheduleC = "schedule"
    static let takenC = "taken"

    static var databaseTableName: String { "MedicalIntakeLog" }

    let id: Int
    let medicineId: Int
    let date: Date
    let schedule: MedicalSchedule
    var taken: Bool

    init(id: Int,
         medicineId: Int,
         date: Date,
         schedule: MedicalSchedule,
         taken: Bool) {

        self.id = id
        self.medicineId = medicineId
        self.date = date
        self.schedule = schedule
        self.taken = taken
    }

    func encode(to container: inout VTDB.Container) {
        container[MedicineIntakeLog.idC] = id
        container[MedicineIntakeLog.medicineIdC] = medicineId
        container[MedicineIntakeLog.dateC] = date
        container[MedicineIntakeLog.scheduleC] = schedule.rawValue
        container[MedicineIntakeLog.takenC] = taken
    }
}
