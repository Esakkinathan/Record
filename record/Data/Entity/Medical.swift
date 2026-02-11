//
//  Medical.swift
//  record
//
//  Created by Esakkinathan B on 07/02/26.
//
import Foundation
import VTDB

enum MedicalType: String, CaseIterable {
    case checkup = "Check Up"
    case longTerm = "Long Term"
    case vaccination = "Vaccination"
    case treatement = "Treatement"
    case emergency = "Emergency"
    
    static var defaultValue: MedicalType {
        return .checkup
    }
    
    static func getList() -> [String] {
        var list: [String] = []
        for type in MedicalType.allCases {
            list.append(type.rawValue)
        }
        return list
    }
}

class Medical: Persistable {
    
    static let idC = "id"
    static let titleC =  "title"
    static let typeC =  "type"
    static let hospitalC = "hospital"
    static let doctorC = "doctor"
    static let dateC =  "date"
    static let createdAtC =  "createdAt"
    static let lastModifiedC = "lastModified"
    static let notesC = "notes"

    
    func encode(to container: inout VTDB.Container) {
        container[Medical.idC] = id
        container[Medical.typeC] = type.rawValue
        container[Medical.hospitalC] = hospital
        container[Medical.doctorC] = doctor
        container[Medical.dateC] = date
        container[Medical.createdAtC] = createdAt
        container[Medical.lastModifiedC] = lastModified
        container[Medical.notesC] = notes
    }
    
    static var databaseTableName: String {
        "Medical"
    }
    
    let id: Int
    var title: String
    var type: MedicalType
    var hospital: String?
    var doctor: String?
    var date: Date?
    let createdAt: Date
    var lastModified: Date
    var notes: String?
    
    init(id: Int, title: String, type: MedicalType, hospital: String? = nil, doctor: String? = nil,date: Date? = nil, createdAt: Date = Date(), lastModified: Date = Date() ,notes: String? = nil) {
        self.id = id
        self.title = title
        self.type = type
        self.hospital = hospital
        self.doctor = doctor
        self.date = date
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.notes = notes
    }
    
    func update(title: String, type: MedicalType, hospital: String? = nil, doctor: String? = nil,date: Date? = nil) {
        self.title = title
        self.type = type
        self.hospital = hospital
        self.doctor = doctor
        self.date = date
        self.lastModified = Date()
    }
}

enum MedicalKind: String, CaseIterable {
    case tablet = "Tablet"
    case syrup = "Syrup"
    case injection = "Injection"
    case topical = "Ointment"
    
    
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

enum MedicalSchedule: String, CaseIterable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case night = "Night"
}

enum DurationType: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    
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

class MedicalItem: Persistable {
    
    
    func encode(to container: inout VTDB.Container) {
        container[MedicalItem.idC] = id
        container[MedicalItem.medicalC] = medical
        container[MedicalItem.kindC] = kind.rawValue
        container[MedicalItem.nameC] = name
        container[MedicalItem.instructionC] = instruction.value
        container[MedicalItem.dosageC] = dosage
        container[MedicalItem.sheduleC] = shedule.dbValue
        container[MedicalItem.durationC] = duration
        container[MedicalItem.durationTypeC] = durationType.rawValue
    }
    
    static var databaseTableName: String {
        "MedicalItem"
    }
    
    
    static let idC = "id"
    static let medicalC = "medical"
    static let kindC = "kind"
    static let nameC = "name"
    static let instructionC = "instruction"
    static let dosageC = "dosage"
    static let sheduleC = "schedule"
    static let durationC = "duration"
    static let durationTypeC = "durationType"

    
    let id: Int
    let medical: Int
    var kind: MedicalKind
    var name: String
    var instruction: MedicalInstruction
    var dosage: String
    var shedule: [MedicalSchedule]
    var duration: Int
    var durationType: DurationType
    
    init(id: Int, medical: Int,kind: MedicalKind, name: String, instruction: MedicalInstruction, dosage: String, shedule: [MedicalSchedule], duration: Int, durationType: DurationType) {
        self.id = id
        self.medical = medical
        self.kind = kind
        self.name = name
        self.instruction = instruction
        self.dosage = dosage
        self.shedule = shedule
        self.duration = duration
        self.durationType = durationType
    }
    
    func update(kind: MedicalKind, name: String, instruction: MedicalInstruction, dosage: String, shedule: [MedicalSchedule], duration: Int, durationType: DurationType) {
        self.kind = kind
        self.name = name
        self.instruction = instruction
        self.dosage = dosage
        self.shedule = shedule
        self.duration = duration
        self.durationType = durationType
    }

}


enum MedicalFormMode: FormMode {
    case add
    case edit(Medical)
    
    var navigationTitle: String {
        switch self {
        case .add: return "Add Medical CheckUp"
        case .edit: return "Edit Medical CheckUp"
        }
    }

}
enum MedicalItemFormMode: FormMode {
    case add
    case edit(MedicalItem)
    
    var navigationTitle: String {
        switch self {
        case .add: return "Add Medical Item"
        case .edit: return "Edit Medical Item"
        }
    }

}
