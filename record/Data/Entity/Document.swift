//
//  Document.swift
//  record
//
//  Created by Esakkinathan B on 21/01/26.
//
import UIKit
import VTDB

class Document: Persistable {
    
    static let idC = "id"
    static let nameC = "name"
    static let numberC = "number"
    static let createdAtC = "createdAt"
    static let expiryDateC = "expiryDate"
    static let fileC = "file"
    static let notesC = "notes"
    static let lastModifiedC = "lastModified"
    static let isRestrictedC = "isRestricted"

    let id: Int
    var name: String
    var number: String
    var createdAt: Date
    var expiryDate: Date?
    var file: String?
    var notes: String?
    var lastModified: Date
    var isRestricted: Bool
    init(id: Int, name: String, number: String, createdAt: Date = Date(), expiryDate: Date? = nil, file: String? = nil, notes: String? = nil, lastModified: Date = Date(), isRestricted:  Bool = false) {
        self.id = id
        self.name = name
        self.number = number
        self.createdAt = createdAt
        self.expiryDate = expiryDate
        self.file = file
        self.notes = notes
        self.lastModified = lastModified
        self.isRestricted = isRestricted
    }
    
    func update(name: String, number: String,expiryDate: Date? = nil, file: String? = nil) {
        self.name = name
        self.number = number
        self.expiryDate = expiryDate
        self.file = file
        self.lastModified = Date()
    }
    func toggleFavorite() {
        isRestricted = !isRestricted
    }

    
    func updateNotes(text: String?) {
        notes = text
        lastModified = Date()
    }
    
    public func encode(to container: inout Container) {
        container[Document.idC] = id
        container[Document.nameC] = name
        container[Document.numberC] = number
        container[Document.createdAtC] = createdAt
        container[Document.expiryDateC] = expiryDate
        container[Document.lastModifiedC] = lastModified
        container[Document.fileC] = file
        container[Document.notesC] = notes
        container[Document.isRestrictedC] = isRestricted
        
    }
    
    public static var databaseTableName: String {
        return "Documents"
    }
}

enum DefaultDocument: String, CaseIterable {
    case adhar = "Adhar Card"
    case pan = "Pan Card"
    case voterId = "Voter Id Card"
    case passport = "Passport"
    case drivingLicense = "Driving License"
    case rationCard = "Ration Card"
    case birthCertificate = "Birth Certificate"
    case deathCertificate = "Death Certificate"
    case vehicleRegistrationCertificate = "Vehicle Registration Certificate"
    case incomeCertificate = "Income Certificate"
    case marriageCertificate = "Marriage Certificate"
    case nativityCertificate = "Nativity certificate"
    case communityCertificate = "Community Certificate"
    case disabilityCertificate = "Disability Certificate"
    case firstGraduateCertificate = "First Graduate Certificate"
    
    case custom
    
    static func getList() -> [String] {
        var list: [String] = []
        for doc in allCases {
            list.append(doc.rawValue)
        }
        return list
    }
    
    static var defaultValue: DefaultDocument {
        .adhar
    }
    
    static func valueOf(value: String?) -> DefaultDocument {
        guard let data = value else {return DefaultDocument.defaultValue}
        for doc in allCases {
            if doc.rawValue == data {
                return doc
            }
        }
        return .custom
    }
    var validationRules: [ValidationRules] {
        var rules: [ValidationRules] = [.required, .noSpaces]
        switch self {
        case .adhar:
            rules += [.numeric, .exactLength(12)]
        case .pan:
            rules += [.alphanumeric,.exactLength(10),.regex(#"^[A-Z]{5}\d{4}[A-Z]$"#, message: "Must be in this pattern [AAAAA0000A]")]
        case .voterId:
            rules += [.alphanumeric,.exactLength(10)]
        case .passport:
            rules += [.minLength(8),.maxLength(10),.alphanumeric]
        case .drivingLicense:
            rules += [.alphanumeric,.minLength(10),.maxValue(16)]
        case .vehicleRegistrationCertificate:
            rules += [.alphanumeric,.minLength(8),.maxLength(14), ]
        default:
            rules += [.minLength(4), .maxLength(20), .allowedCharacters(CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-/ "), message: "Invalid Character Found")]
        }
        return rules
    }
    var hasExpiryDate: Bool {
        let has: Bool
        switch self {
        case .passport, .drivingLicense, .incomeCertificate, .custom:
            has = true
        default:
            has = false
        }
        return has
    }
}
//    var documentImage: UIImage {
//        let image = UIImage
//        switch self {
//        case .adhar:
//            image = UIImage(named: <#T##String#>)
//        case .pan:
//            <#code#>
//        case .voterId:
//            <#code#>
//        case .passport:
//            <#code#>
//        case .drivingLicense:
//            <#code#>
//        }
//    }


protocol FormMode {
    var navigationTitle: String { get }
}

enum AppFormMode {
    case add
    case edit(Persistable)
    var navigationTitle: String {
        switch self {
        case .add: return "Add "
        case .edit: return "Edit "
        }
        
    }
}


enum DocumentFormMode: FormMode {
    case add
    case edit(Document)

    var navigationTitle: String {
        switch self {
        case .add: return "Add Document"
        case .edit: return "Edit Document"
        }
    }
}


enum DocumentSortField: String, Codable {
    case name = "Name"
    case createdAt = "Created At"
    case updatedAt = "Recent"
    case expiryDate = "Expiry Date"
}


enum SortDirection: String, Codable {
    case ascending
    case descending
}

struct DocumentSortOption: Codable, Equatable  {
    let field: DocumentSortField
    let direction: SortDirection
}


enum DocumentSortStore {
    private static let key = "document_sort_option"

    static func load() -> DocumentSortOption {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let option = try? JSONDecoder().decode(DocumentSortOption.self, from: data)
        else {
            return DocumentSortOption(field: .name, direction: .ascending)
        }
        return option
    }

    static func save(_ option: DocumentSortOption) {
        let data = try? JSONEncoder().encode(option)
        UserDefaults.standard.set(data, forKey: key)
    }
}
