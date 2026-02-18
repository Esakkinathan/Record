//
//  MedicalIntakeLog.swift
//  record
//
//  Created by Esakkinathan B on 17/02/26.
//

import Foundation
import VTDB

final class MedicalIntakeLog: Persistable {

    static let idC = "id"
    static let medicalItemIdC = "medicalItemId"
    static let dateC = "date"
    static let scheduleC = "schedule"
    static let takenC = "taken"

    static var databaseTableName: String { "MedicalIntakeLog" }

    let id: Int
    let medicalItemId: Int
    let date: Date
    let schedule: MedicalSchedule
    var taken: Bool

    init(id: Int,
         medicalItemId: Int,
         date: Date,
         schedule: MedicalSchedule,
         taken: Bool) {

        self.id = id
        self.medicalItemId = medicalItemId
        self.date = date
        self.schedule = schedule
        self.taken = taken
    }

    func encode(to container: inout VTDB.Container) {
        container[Self.idC] = id
        container[Self.medicalItemIdC] = medicalItemId
        container[Self.dateC] = date
        container[Self.scheduleC] = schedule.rawValue
        container[Self.takenC] = taken
    }
}
