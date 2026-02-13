//
//  UtilityRepository.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//
import VTDB

class UtilityRepository: UtilityRepositoryProtocol {
    
    var db: UtilityDatabaseProtocol = DatabaseAdapter.shared
    
    init() {
        createTable()
//        add(utility: Utility(id: 1, name: "Electric Bill"))
//        add(utility: Utility(id: 1, name: "Water Connection Bill"))
//        add(utility: Utility(id: 1, name: "Internet Bill"))
//        add(utility: Utility(id: 1, name: "Gas Bill"))
//        add(utility: Utility(id: 1, name: "Credit Card Bill"))
//        add(utility: Utility(id: 1, name: "Loan Bill"))
    }
    
    func createTable() {
//                do {
//                    try db.database.writeInTransaction { db in
//                        let sql = "DROP TABLE \(Utility.databaseTableName);"
//                        try db.execute(sql)
//                        return .commit
//                    }
//                } catch {
//                    print(error)
//                }

        let colums: [String: TableColumnType] = [
            Utility.idC: .int,
            Utility.nameC: .string,
        ]
        
        db.create(table: Utility.databaseTableName, columnDefinitions: colums, primaryKey: [Utility.idC])

    }
    
    func add(utility: Utility) {
        let columns: [String: Any?] = [
            Utility.nameC: utility.name,
        ]
        db.insertInto(tableName: Utility.databaseTableName, values: columns)
    }
    
    func update(utility: Utility) {
        db.updateInto(data: utility)
    }

    func delete(id: Int) {
        db.delete(table: Utility.databaseTableName, id: id)
    }
    func fetchAll() -> [Utility] {
        return db.fetchUtility()
    }

}
