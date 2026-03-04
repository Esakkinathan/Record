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
    case chronic = "Chrnoic"
    case vaccination = "Vaccination"
    case emergency = "Emergency"
    
    static var defaultValue: MedicalType {
        return .checkup
    }
    
    var image: String {
        switch self {
        case .checkup:
            "stethoscope"
        case .chronic:
            "waveform.path.ecg"
        case .vaccination:
            "syringe.fill"
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
    static let receiptC = "receipt"
    static let endDateC = "endDate"
    static let statusC = "status"
    
    func encode(to container: inout VTDB.Container) {
        container[Medical.idC] = id
        container[Medical.typeC] = type.rawValue
        container[Medical.hospitalC] = hospital
        container[Medical.doctorC] = doctor
        container[Medical.dateC] = date
        container[Medical.createdAtC] = createdAt
        container[Medical.lastModifiedC] = lastModified
        container[Medical.receiptC] = receipt
        container[Medical.notesC] = notes
        container[Medical.endDateC] = endDate
        container[Medical.statusC] = status
    }
    
    static var databaseTableName: String {
        "Medical"
    }
    
    let id: Int
    var title: String
    var type: MedicalType
    var hospital: String?
    var doctor: String?
    var date: Date
    let createdAt: Date
    var lastModified: Date
    var notes: String?
    var receipt: String?
    var endDate: Date?
    var status: Bool

    init(id: Int, title: String, type: MedicalType,hospital: String? = nil, doctor: String? = nil,date: Date, createdAt: Date = Date(), lastModified: Date = Date(), status: Bool = true, notes: String? = nil, receipt: String? = nil, endDate: Date? = nil) {
        self.id = id
        self.title = title
        self.type = type
        self.hospital = hospital
        self.doctor = doctor
        self.date = date
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.notes = notes
        self.receipt = receipt
        self.endDate = endDate
        self.status = status
    }
    
    func update(title: String, type: MedicalType,hospital: String? = nil, doctor: String? = nil,date: Date, receipt: String? = nil) {
        self.title = title
        self.type = type
        self.hospital = hospital
        self.doctor = doctor
        self.date = date
        self.lastModified = Date()
        self.receipt = receipt
    }
    
    func setStatus(value: Bool, date: Date? = nil) {
        self.status = value
        self.endDate = date
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
/*
 
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
*/
