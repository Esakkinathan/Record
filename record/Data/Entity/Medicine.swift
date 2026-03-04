//
//  MedicalItem.swift
//  record
//
//  Created by Esakkinathan B on 02/03/26.
//

import VTDB

enum MedicalItemFormMode: FormMode {
    case add
    case edit(Medicine)
    
    var navigationTitle: String {
        switch self {
        case .add: return "Add Medical Item"
        case .edit: return "Edit Medical Item"
        }
    }

}

enum MedicalKind: String, CaseIterable, Hashable {
    case tablet = "Tablet"
    case syrup = "Syrup"
    case injection = "Injection"
    case topical = "Cream"
    
    var image: String {
        switch self {
        case .tablet:
            "pill.circle"
        case .syrup:
            "cross.vial"
        case .injection:
            "syringe"
        case .topical:
            "bandage.fill"
        }
    }
}

enum MedicalInstruction {
    
    case beforeFood
    case afterFood
    case custom(String)
    
    static func getList() -> [String] {
        return ["Before Food","After Food"]
    }
    static func valueOf(_ value: String) -> MedicalInstruction {
        switch value {
        case "Before Food": return .beforeFood
        case "After Food": return .afterFood
        default: return .custom(value)
        }
    }
    var value: String {
        switch self {
        case .beforeFood:
            "Before Food"
        case .afterFood:
            "After Food"
        case .custom(let string):
            string
        }
    }
}
extension Array where Element == MedicalSchedule {

    var dbValue: String {
        self.map { $0.rawValue }.joined(separator: ",")
    }

    static func from(dbValue: String) -> [MedicalSchedule] {
        dbValue
            .split(separator: ",")
            .compactMap { MedicalSchedule(rawValue: String($0)) }
    }
}

enum MedicalSchedule: String, CaseIterable, Hashable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case night = "Night"
    static func getList() -> [String] {
        var list: [String] = []
        for ind in allCases {
            list.append(ind.rawValue)
        }
        return list
    }
    static func getImage() -> [String] {
        return ["sunrise.fill","sun.max.fill","sunset.fill","moon"]
    }
}

enum DurationType: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    static func getList() -> [String] {
        var list: [String] = []
        for type in allCases {
            list.append(type.rawValue)
        }
        return list
    }
    static let count = 3
    static func valueOf(input: String) -> DurationType {
        switch input {
        case "Day": return .day
        case "Week": return .week
        case "Month": return .month
        default: return .day
        }
    }
    
}

class Medicine: Persistable {
    
    
    func encode(to container: inout VTDB.Container) {
        container[Medicine.idC] = id
        container[Medicine.medicalC] = medical
        container[Medicine.kindC] = kind.rawValue
        container[Medicine.nameC] = name
        container[Medicine.instructionC] = instruction.value
        container[Medicine.dosageC] = dosage
        container[Medicine.startDateC] = startDate
        container[Medicine.sheduleC] = shedule.dbValue
    }
    
    static var databaseTableName: String {
        "Medicine"
    }
    
    //    var isActive: Bool {
    //        let today = Date()
    //        return today >= startDate &&
    //               (endDate == nil || today <= endDate!)
    //    }
    static let idC = "id"
    static let medicalC = "medical"
    static let kindC = "kind"
    static let nameC = "name"
    static let instructionC = "instruction"
    static let dosageC = "dosage"
    static let sheduleC = "schedule"
    static let startDateC = "startDate"
    static let endDateC = "endDate"
    static let statusC = "status"
    let id: Int
    let medical: Int
    var kind: MedicalKind
    var name: String
    var instruction: MedicalInstruction
    var dosage: String
    var shedule: [MedicalSchedule]
    var startDate: Date
    var status: Bool
    var endDate: Date?
    
    init(id: Int, medical: Int,kind: MedicalKind, name: String, instruction: MedicalInstruction, dosage: String, startDate: Date = Date(),shedule: [MedicalSchedule], endDate: Date? = nil,status: Bool = true) {
        self.id = id
        self.medical = medical
        self.kind = kind
        self.name = name
        self.instruction = instruction
        self.dosage = dosage
        self.startDate = startDate
        self.endDate = endDate
        self.shedule = shedule
        self.status = status
    }
    
    func update(kind: MedicalKind, name: String, instruction: MedicalInstruction, dosage: String, shedule: [MedicalSchedule], startDate: Date) {
        self.kind = kind
        self.name = name
        self.instruction = instruction
        self.dosage = dosage
        self.shedule = shedule
        self.startDate = startDate
    }
    
    func setStatus(value: Bool, date: Date?) {
        self.status = value
        self.endDate = date
    }
    
}

