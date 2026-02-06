//
//  Document.swift
//  record
//
//  Created by Esakkinathan B on 21/01/26.
//
import UIKit

class Document {
    private let id: Int
    var name: String
    var number: String
    var expiryDate: Date?
    var file: String?
    var type: DocumentCategory
    init(id: Int, name: String, number: String, expiryDate: Date? = nil, file: String?, type: DocumentCategory) {
        self.id = id
        self.name = name
        self.number = number
        self.expiryDate = expiryDate
        self.file = file
        self.type = type
    }
}


enum DocumentCategory: String, CaseIterable {
    case Default
    case Custom
    static func getList() -> [String] {
        var list: [String] = []
        for i in allCases {
            list.append("\(i)")
        }
        return list
    }
    var sectionIndex: Int {
        DocumentCategory.allCases.firstIndex(of: self) ?? 0
    }
}

enum DefaultDocument: String, CaseIterable {
    case adhar = "Adhar Card"
    case pan = "Pan Card"
    case voterId = "Voter Id Card"
    case passport = "PassPort"
    case drivingLicense = "Driving License"
    
    static func valueOf(value: String) -> DefaultDocument {
        switch value {
        case adhar.rawValue:
            return adhar
        case pan.rawValue:
            return pan
        case voterId.rawValue:
            return voterId
        case passport.rawValue:
            return passport
        case drivingLicense.rawValue:
            return drivingLicense
        default:
            return adhar
        }
    }
    
}

enum DocumentAction {
    case add
    case edit
}
