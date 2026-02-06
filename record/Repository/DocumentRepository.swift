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
        createTable()
    }

    func createTable() {
        let colums: [String: TableColumnType] = [
            Document.idC: .int,
            Document.nameC: .string,
            Document.numberC: .string,
            Document.createdAtC: .date,
            Document.expiryDateC: .date,
            Document.fileC: .text,
            Document.notesC: .text,
            Document.lastModifiedC: .date
        ]
        db.create(table: Document.databaseTableName, columnDefinitions: colums, primaryKey: [Document.idC], uniqueKeys:[[Document.idC,Document.numberC]])
    }
    
    func add(document: Document) {
        let columns: [String: Any?] = [
            Document.nameC: document.name,
            Document.numberC: document.number,
            Document.createdAtC: document.createdAt,
            Document.expiryDateC: document.expiryDate,
            Document.fileC: document.file,
            Document.notesC: document.notes,
            Document.lastModifiedC: document.lastModified
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
    
    func fetchAll() -> [Document] {
        return db.fetchDocuments()
    }
        
}
