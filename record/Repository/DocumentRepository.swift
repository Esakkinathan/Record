//
//  DocumentRepository.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//
import Foundation

import VTDB
class DocumentRepository: DocumentRepositoryProtocol {
    
    var db: DocumentDatabaseProtocol = DatabaseAdapter.shared
    
    init() {
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "yyyy-MM-dd"
//                let startDate = dateFormatter.date(from: "2030-01-01")!
//                let endDate = dateFormatter.date(from: "2026-02-26")!
//
//        for _ in 0..<1000 {
//            let name = PasswordGenerator.generate(options: .init(length: Int.random(in: 1...30), includeLetters: true, includeNumbers: false, includeSymbols: false))
//            let number = PasswordGenerator.generate(options: .init(length: Int.random(in: 1...30), includeLetters: true, includeNumbers: false, includeSymbols: false))
//            add(document: Document(id: 1, name: name, number: number, expiryDate: Bool.random() ? Date.randomBetween(start: startDate, end: endDate) : nil, isRestricted: Bool.random()))
//        }
    }

    
    func add(document: Document) {
        let columns: [String: Any?] = [
            Document.nameC: document.name,
            Document.numberC: document.number,
            Document.createdAtC: document.createdAt,
            Document.expiryDateC: document.expiryDate,
            Document.fileC: document.file,
            Document.notesC: document.notes,
            Document.lastModifiedC: document.lastModified,
            Document.isRestrictedC: document.isRestricted
        ]
        
        db.insertInto(tableName: Document.databaseTableName, values: columns)
    }
    
    func update(document: Document) {
        db.updateInto(data: document)
    }
    
    func updateNotes(text: String?, id: Int) {
        db.updateNotes(table: Document.databaseTableName, id: id, text: text, date: Date())
    }

    func delete(id: Int) {
        db.delete(table: Document.databaseTableName, id: id)
    }
    
    func toggleRestricted(_ document: Document) {
        db.toggle(table: Document.databaseTableName, column: Document.isRestrictedC, id: document.id, value: document.isRestricted, lastModified: Date())

    }
    
    func fetchAll() -> [Document] {
        return db.fetchDocuments()
    }
        
}
