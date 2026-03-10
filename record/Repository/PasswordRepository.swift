//
//  PasswordRepository.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

import VTDB

class PasswordRepository: PasswordRepositoryProtocol {
    
    
    
    var db: PasswordDatabaseProtocol = DatabaseAdapter.shared
    func createEmpty() {
        let titles = ["Google", "Facebook", "Twitter", "Instagram", "Amazon", "Netflix", "Apple", "GitHub", "LinkedIn", "Dropbox"]
        let usernames = ["john123", "alex_dev", "user007", "swiftcoder", "techguy", "nathan_b", "sampleUser", "dev_user", "ios_master"]
        let notesSamples = ["Work account", "Personal login", "Important account", "Backup email used", "2FA enabled", nil]
        let urls = ["https://google.com", "https://facebook.com", "https://twitter.com", "https://amazon.com", "https://github.com", nil]

        for i in 1...100 {

            let randomTitle = titles.randomElement()!
            let randomUsername = usernames.randomElement()! + "\(Int.random(in: 1...999))"

            let randomPassword = UUID().uuidString.prefix(12) // random password

            let created = Date().addingTimeInterval(-Double.random(in: 0...31536000)) // within last year
            let modified = created.addingTimeInterval(Double.random(in: 0...100000))

            let isFavorite = Bool.random()

            let lastCopied = Bool.random()
                ? Date().addingTimeInterval(-Double.random(in: 0...100000))
                : nil

            let password = Password(
                id: i,
                title: randomTitle,
                username: randomUsername,
                password: String(randomPassword),
                notes: notesSamples.randomElement() ?? nil,
                createdAt: created,
                lastModified: modified,
                isFavorite: isFavorite,
                url: urls.randomElement() ?? nil, lastCopiedDate: lastCopied
            )

            add(password: password)
        }

    }
    init() {
        //createEmpty()
    }
    

    func fetchAll() -> [Password] {
        let encryptedPasswords = db.fetchPasswords()
        if encryptedPasswords.isEmpty {return encryptedPasswords}
        return encryptedPasswords.map { password in
            let decrypted = password
            
            decrypted.title = decrypt(password.title).capitalized
            decrypted.username = decrypt(password.username)
            decrypted.password = decrypt(password.password)
            
            return decrypted
        }
    }

    func add(password: Password) {
        let columns: [String: Any?] = [
            Password.titleC: encrypt(password.title.lowercased()),
            Password.usernameC: encrypt(password.username),
            Password.passwordC: encrypt(password.password),
            Password.notesC: password.notes,
            Password.createdAtC: password.createdAt,
            Password.lastModifiedC: password.lastModified,
            Password.isFavoriteC: password.isFavorite,
            Password.lastCopiedDateC: password.lastCopiedDate,
            Password.urlC: password.url
        ]
        db.insertInto(tableName: Password.databaseTableName, values: columns)
    }

    func update(password: Password) {
        let columns: [String: Any?] = [
            Password.idC: password.id,
            Password.titleC: encrypt(password.title),
            Password.usernameC: encrypt(password.username),
            Password.passwordC: encrypt(password.password),
            Password.notesC: password.notes,
            Password.createdAtC: password.createdAt,
            Password.lastModifiedC: password.lastModified,
            Password.isFavoriteC: password.isFavorite,
            Password.lastCopiedDateC: password.lastCopiedDate,
            Password.urlC: password.url
        ]
        
        db.insertInto(tableName: Password.databaseTableName, values: columns)
    }

    func toggleFavourite(_ password: Password) {
        db.toggle(table: Password.databaseTableName, column: Password.isFavoriteC, id: password.id, value: password.isFavorite, lastModified: Date())
    }
    func delete(id: Int) {
        db.delete(table: Password.databaseTableName, id: id)
    }
    
    func updateLastCopiedDate(id: Int, date: Date) {
        db.updateLastCopiedDate(id: id,date: date)
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
    
    func resetPasswords(newPin: String) {
        let passwords: [Password] = fetchAll()
        print(KeychainManager.shared.savePin(newPin))
        for password in passwords {
            delete(id: password.id)
        }
        for password in passwords {
            add(password: password)
        }
    }
//    func fetchPasswords(limit: Int, offset: Int, sort: PasswordSortOption, searchText: String?, isFavorite: Bool) -> [Password] {
//        
//    }
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
