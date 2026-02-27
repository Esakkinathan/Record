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
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let startDate = dateFormatter.date(from: "2022-01-01")!
//        let endDate = dateFormatter.date(from: "2026-02-26")!
//
//        for _ in 0...10000 {
//            let title = PasswordGenerator.generate(options: .init(length: Int.random(in: 1...30), includeLetters: true, includeNumbers: false, includeSymbols: false))
//            let username = PasswordGenerator.generate(options: .init(length: Int.random(in: 1...30), includeLetters: true, includeNumbers: true, includeSymbols: true))
//            let password = PasswordGenerator.generate(options: .init(length: Int.random(in: 1...30), includeLetters: true, includeNumbers: true, includeSymbols: true))
//            add(password: Password(id: 1, title: title, username: username, password: password, createdAt: Date.randomBetween(start: startDate, end: endDate), lastModified: Date.randomBetween(start: startDate, end: endDate),isFavorite: Bool.random()))
 //       }
    }
    

    func fetchAll() -> [Password] {
        let encryptedPasswords = db.fetchPasswords()
        
        return encryptedPasswords.map { password in
            let decrypted = password
            
            decrypted.title = decrypt(password.title)
            decrypted.username = decrypt(password.username)
            decrypted.password = decrypt(password.password)
            
            return decrypted
        }
    }

    func add(password: Password) {
        let columns: [String: Any?] = [
            Password.titleC: encrypt(password.title),
            Password.usernameC: encrypt(password.username),
            Password.passwordC: encrypt(password.password),
            Password.notesC: password.notes, // NOT encrypted
            Password.createdAtC: password.createdAt,
            Password.lastModifiedC: password.lastModified,
            Password.isFavoriteC: password.isFavorite,
            Password.lastCopiedDateC: password.lastCopiedDate
        ]
        
        db.insertInto(tableName: Password.databaseTableName, values: columns)
    }

    func update(newPassword: Password) {
        let encrypted = newPassword
        
        encrypted.title = encrypt(newPassword.title)
        encrypted.username = encrypt(newPassword.username)
        encrypted.password = encrypt(newPassword.password)
        
        db.updateInto(data: encrypted)
    }

    func toggleFavourite(_ password: Password) {
        db.toggle(table: Password.databaseTableName, column: Password.isFavoriteC, id: password.id, value: password.isFavorite, lastModified: Date())
    }
    func delete(id: Int) {
        db.delete(table: Password.databaseTableName, id: id)
    }
    
    func updateNotes(text: String?, id: Int) {
        db.updateNotes(table: Password.databaseTableName, id: id, text: text, date: Date())
    }
    private func encrypt(_ text: String) -> String {
        do {
            return try CryptoManager.encrypt(text: text)
        } catch {
            fatalError("Encryption failed: \(error)")
        }
    }

    private func decrypt(_ text: String) -> String {
        do {
            return try CryptoManager.decrypt(baseString: text)
        } catch {
            fatalError("Decryption failed: \(error)")
        }
    }
}

class MasterPasswordRepository: MasterPasswordRepositoryProtocol {
    static let tableName = "MasterPassword"
    var db: MasterPasswordDatabaseProtocol = DatabaseAdapter.shared
    init() {
        createTable()
    }
    func createTable() {
        //deleteAllPassword()
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
