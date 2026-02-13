//
//  UtilityAccount.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//

import VTDB

class UtilityAccount: Persistable {
    func encode(to container: inout VTDB.Container) {
        container[UtilityAccount.idC] = id
        container[UtilityAccount.utilityIdC] = utilityId
        container[UtilityAccount.titleC] = title
        container[UtilityAccount.accountNumberC] = accountNumber
        container[UtilityAccount.providerC] = provider
        container[UtilityAccount.createdAtC] = createdAt
        container[UtilityAccount.lastModifiedC] = lastModified
        container[UtilityAccount.notesC] = notes
        
    }
    
    static var databaseTableName: String {
        "UtilityAccount"
    }
    
    
    static let idC = "id"
    static let utilityIdC = "utilityId"
    static let titleC = "title"
    static let accountNumberC =  "accountNumber"
    static let providerC = "provider"
    static let createdAtC = "createdAt"
    static let lastModifiedC = "lastModified"
    static let notesC = "notes"
    
    
    let id: Int
    let utilityId: Int
    var title: String
    var accountNumber: String
    var provider: String
    let createdAt: Date
    var lastModified: Date
    var notes: String?
    
    init(id: Int, utilityId: Int, title: String,accountNumber: String, provider: String, createdAt: Date = Date(), lastModified: Date = Date(), notes: String? = nil) {
        self.id = id
        self.utilityId = utilityId
        self.title = title
        self.accountNumber = accountNumber
        self.provider = provider
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.notes = notes
    }
    
    func updateNotes(notes: String?, lastModified: Date = Date()) {
        self.notes = notes
        self.lastModified = lastModified
    }
    
    func update(title: String,accountNumber: String, provider: String, lastModified: Date = Date()) {
        self.title = title
        self.accountNumber = accountNumber
        self.provider = provider
        self.lastModified = lastModified
    }
    
}

enum UtilityAccountFormMode {
    case add
    case edit(UtilityAccount)
    
    var navigationTitle: String {
        switch self {
        case .add: return "Add Utility Account"
        case .edit: return "Edit Utility Account"
        }
    }

}
