//
//  RemainderRepository.swift
//  record
//
//  Created by Esakkinathan B on 24/02/26.
//

protocol RemainderRepositoryProtocol {
    func add(remainder: Remainder) -> Int
    func delete(id: Int)
    func fetchAllByDocumentId(_ id: Int) -> [Remainder]
}

class RemainderRepository: RemainderRepositoryProtocol {
    var db: RemainderDatabaseProtocol = DatabaseAdapter.shared
    init() {
        
    }
    
    func add(remainder: Remainder) -> Int {
        let columns: [String: Any?] = [
            Remainder.documentIdC: remainder.documentId,
            Remainder.dateC: remainder.date
        ]
        return db.insertandGetRemainderId(table: Remainder.databaseTableName, values: columns)
        
    }
    
    func delete(id: Int) {
        db.delete(table: Remainder.databaseTableName, id: id)
    }
    
    func fetchAllByDocumentId(_ id: Int) -> [Remainder] {
        return db.fetchRemainderByDocumentId(id)
    }

}
