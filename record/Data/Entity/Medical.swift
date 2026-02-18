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
    
    var image: String {
        switch self {
        case .checkup:
            "stethoscope"
        case .longTerm:
            "waveform.path.ecg"
        case .vaccination:
            "syringe.fill"
        case .treatement:
            "cross.case.fill"
        case .emergency:
            "bolt.heart.fill"
        }
    }
    
    static func getList() -> [String] {
        var list: [String] = []
        for type in MedicalType.allCases {
            list.append(type.rawValue)
        }
        return list
    }

    static func getImage() -> [String] {
        return ["stethoscope", "waveform.path.ecg", "syringe.fill", "cross.case.fill", "bolt.heart.fill"]
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
    static let durationC = "duration"
    static let durationTypeC = "durationType"

    
    func encode(to container: inout VTDB.Container) {
        container[Medical.idC] = id
        container[Medical.typeC] = type.rawValue
        container[Medical.durationC] = duration
        container[Medical.durationTypeC] = durationType.rawValue
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
    var duration: Int
    var durationType: DurationType
    var hospital: String?
    var doctor: String?
    var date: Date?
    let createdAt: Date
    var lastModified: Date
    var notes: String?
    
    

    init(id: Int, title: String, type: MedicalType, duration: Int, durationType: DurationType,hospital: String? = nil, doctor: String? = nil,date: Date? = nil, createdAt: Date = Date(), lastModified: Date = Date() ,notes: String? = nil, ) {
        self.id = id
        self.title = title
        self.type = type
        self.duration = duration
        self.durationType = durationType
        self.hospital = hospital
        self.doctor = doctor
        self.date = date
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.notes = notes
    }
    
    func update(title: String, type: MedicalType, duration: Int, durationType: DurationType,hospital: String? = nil, doctor: String? = nil,date: Date? = nil) {
        self.title = title
        self.type = type
        self.hospital = hospital
        self.doctor = doctor
        self.date = date
        self.duration = duration
        self.durationType = durationType
        self.lastModified = Date()
    }
}

extension Medical {
    var startDate: Date {
        date ?? createdAt
    }

    var endDate: Date {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)

        switch durationType {
        case .day:
            return calendar.date(byAdding: .day, value: duration - 1, to: start)!
            
        case .week:
            return calendar.date(byAdding: .day, value: (duration * 7) - 1, to: start)!
            
        case .month:
            let added = calendar.date(byAdding: .month, value: duration, to: start)!
            return calendar.date(byAdding: .day, value: -1, to: added)!
        }
    }
    var durationText: String {
        return "\(duration) \(durationType.rawValue)"
    }

}

enum MedicalSortField: String, Codable {
    case title = "Title"
    case createdAt = "Created At"
    case updatedAt = "Recent"
}



struct MedicalSortOption: Codable, Equatable  {
    let field: MedicalSortField
    let direction: SortDirection
}


enum MedicalSortStore {
    private static let key = "Medical_sort_option"

    static func load() -> MedicalSortOption {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let option = try? JSONDecoder().decode(MedicalSortOption.self, from: data)
        else {
            return MedicalSortOption(field: .title, direction: .ascending)
        }
        return option
    }

    static func save(_ option: MedicalSortOption) {
        let data = try? JSONEncoder().encode(option)
        UserDefaults.standard.set(data, forKey: key)
    }
}


enum MedicalKind: String, CaseIterable {
    case tablet = "Tablet"
    case syrup = "Syrup"
    case injection = "Injection"
    case topical = "Ointment"
    
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

class MedicalItem: Persistable {
    
    
    func encode(to container: inout VTDB.Container) {
        container[MedicalItem.idC] = id
        container[MedicalItem.medicalC] = medical
        container[MedicalItem.kindC] = kind.rawValue
        container[MedicalItem.nameC] = name
        container[MedicalItem.instructionC] = instruction.value
        container[MedicalItem.dosageC] = dosage
        container[MedicalItem.startDateC] = startDate
        container[MedicalItem.sheduleC] = shedule.dbValue
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
    static let startDateC = "startDate"
    static let endDateC = "endDate"
    
    let id: Int
    let medical: Int
    var kind: MedicalKind
    var name: String
    var instruction: MedicalInstruction
    var dosage: String
    var shedule: [MedicalSchedule]
    var startDate: Date
    var endDate: Date?
    
    init(id: Int, medical: Int,kind: MedicalKind, name: String, instruction: MedicalInstruction, dosage: String, startDate: Date = Date(),shedule: [MedicalSchedule], endDate: Date? = nil) {
        self.id = id
        self.medical = medical
        self.kind = kind
        self.name = name
        self.instruction = instruction
        self.dosage = dosage
        self.startDate = startDate
        self.endDate = endDate
        self.shedule = shedule
    }
    
    func update(kind: MedicalKind, name: String, instruction: MedicalInstruction, dosage: String, shedule: [MedicalSchedule], startDate: Date) {
        self.kind = kind
        self.name = name
        self.instruction = instruction
        self.dosage = dosage
        self.shedule = shedule
        self.startDate = startDate
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
enum BillFormMode {
    case add
    case edit(Bill)
    
    func title(type: BillType) -> String {
        switch type {
        case .ongoing:
            switch self {
            case .add:
                return "Add \(BillType.ongoing.rawValue) Bill"
            case .edit(_):
                return "Edit \(BillType.ongoing.rawValue) Bill"
            }
        case .completed:
            switch self {
            case .add:
                return "Add \(BillType.completed.rawValue) Bill"
            case .edit(_):
                return "Edit \(BillType.completed.rawValue) Bill"
            }

        }
    }

}

