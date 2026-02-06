//
//  PasswordRepository.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

import VTDB

class PasswordRepository: PasswordRepositoryProtocol {
    
    
    
    var db: PasswordDatabaseProtocol = DatabaseAdapter.shared
    
    init() {
        createTable()
    }
    
    func createTable() {
        let colums: [String: TableColumnType] = [
            Password.idC: .int,
            Password.titleC: .string,
            Password.usernameC: .string,
            Password.passwordC: .string,
            Password.notesC: .text,
            Password.createdAtC: .date,
            Password.lastModifiedC: .date,
            Password.isFavoriteC: .bool
        ]
        db.create(table: Password.databaseTableName, columnDefinitions: colums, primaryKey: [Document.idC], uniqueKeys:[[Password.idC,Password.titleC]])
    }

    func fetchAll() -> [Password] {
        return db.fetchPasswords()
    }
    
    func add(password: Password) {
        let columns: [String: Any?] = [
            Password.titleC: password.title,
            Password.usernameC: password.username,
            Password.passwordC: password.password,
            Password.notesC: password.notes,
            Password.createdAtC: password.createdAt,
            Password.lastModifiedC: password.lastModified,
            Password.isFavoriteC: password.isFavorite
        ]
        db.insertInto(tableName: Password.databaseTableName, values: columns)

    }
    
    func update(newPassword: Password){
        db.updateInto(data: newPassword)
    }
    
    func toggleFavourite(_ password: Password) {
        db.toggle(table: Password.databaseTableName, id: password.id, value: !password.isFavorite)
    }
    func delete(id: Int) {
        db.delete(table: Password.databaseTableName, id: id)
    }
    
    func updateNotes(text: String?, id: Int) {
        db.updateNotes(table: Password.databaseTableName, id: id, text: text, date: Date())
    }

}

class MasterPasswordRepository: MasterPasswordRepositoryProtocol {
    static let tableName = "MasterPassword"
    var db: MasterPasswordDatabaseProtocol = DatabaseAdapter.shared
    init() {
        createTable()
    }
    func createTable() {
        let columns: [String:TableColumnType] = [
            Password.idC: .int,
            Password.passwordC: .text,
        ]
        db.create(table: MasterPasswordRepository.tableName, columnDefinitions: columns, primaryKey: [Password.idC])
    }
    func insertInto(password: String) {
        deleteAllPassword()
        let columns: [TableColumnName : TableColumnValue] = [
            Password.passwordC: password,
        ]
        db.insertInto(tableName: MasterPasswordRepository.tableName, values: columns)
    }
    
    func deleteAllPassword() {
        db.deleteAll(table: MasterPasswordRepository.tableName)
    }
    
    func fetchPassword() -> String? {
        return db.fetchPassword(table: MasterPasswordRepository.tableName)
    }
}
