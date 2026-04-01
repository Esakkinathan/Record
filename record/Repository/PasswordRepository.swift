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

        let passwords: [Password] = [

            Password(id: 1, title: "Google", username: "john123", password: "GooGle@123", notes: "Personal Gmail", createdAt: Date(), lastModified: Date(), isFavorite: true, url: "https://google.com", lastCopiedDate: nil),

            Password(id: 2, title: "Facebook", username: "alex_dev", password: "Face@2024", notes: "Social account", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://facebook.com", lastCopiedDate: nil),

            Password(id: 3, title: "Twitter", username: "swiftcoder", password: "Twit@2025", notes: nil, createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://twitter.com", lastCopiedDate: nil),

            Password(id: 4, title: "Instagram", username: "photo_user", password: "Insta@777", notes: "Photography page", createdAt: Date(), lastModified: Date(), isFavorite: true, url: "https://instagram.com", lastCopiedDate: nil),

            Password(id: 5, title: "Amazon", username: "shopper01", password: "AmaZon@555", notes: "Shopping account", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://amazon.com", lastCopiedDate: nil),

            Password(id: 6, title: "Netflix", username: "movie_fan", password: "Net@flix11", notes: "Family subscription", createdAt: Date(), lastModified: Date(), isFavorite: true, url: "https://netflix.com", lastCopiedDate: nil),

            Password(id: 7, title: "Apple", username: "ios_master", password: "AppLe@888", notes: "Apple ID", createdAt: Date(), lastModified: Date(), isFavorite: true, url: "https://apple.com", lastCopiedDate: nil),

            Password(id: 8, title: "GitHub", username: "dev_user", password: "Git@Code22", notes: "Work repos", createdAt: Date(), lastModified: Date(), isFavorite: true, url: "https://github.com", lastCopiedDate: nil),

            Password(id: 9, title: "LinkedIn", username: "career_dev", password: "Link@111", notes: "Professional profile", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://linkedin.com", lastCopiedDate: nil),

            Password(id: 10, title: "Dropbox", username: "file_store", password: "Drop@444", notes: "Backup storage", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://dropbox.com", lastCopiedDate: nil),

            Password(id: 11, title: "Slack", username: "team_user", password: "SlacK@123", notes: "Office workspace", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://slack.com", lastCopiedDate: nil),

            Password(id: 12, title: "Notion", username: "note_keeper", password: "Note@567", notes: "Personal notes", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://notion.so", lastCopiedDate: nil),

            Password(id: 13, title: "Spotify", username: "musiclover", password: "Spot@999", notes: "Music streaming", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://spotify.com", lastCopiedDate: nil),

            Password(id: 14, title: "Reddit", username: "reddit_user", password: "Red@321", notes: nil, createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://reddit.com", lastCopiedDate: nil),

            Password(id: 15, title: "PayPal", username: "pay_user", password: "Pay@777", notes: "Payment account", createdAt: Date(), lastModified: Date(), isFavorite: true, url: "https://paypal.com", lastCopiedDate: nil),

            Password(id: 16, title: "StackOverflow", username: "stack_dev", password: "Stack@555", notes: "Developer account", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://stackoverflow.com", lastCopiedDate: nil),

            Password(id: 17, title: "YouTube", username: "video_user", password: "YT@1111", notes: "Content channel", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://youtube.com", lastCopiedDate: nil),

            Password(id: 18, title: "Medium", username: "writer_dev", password: "Med@777", notes: "Blog posts", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://medium.com", lastCopiedDate: nil),

            Password(id: 19, title: "Trello", username: "task_user", password: "Trel@2025", notes: "Project boards", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://trello.com", lastCopiedDate: nil),

            Password(id: 20, title: "Zoom", username: "meeting_user", password: "Zoom@888", notes: "Video meetings", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://zoom.us", lastCopiedDate: nil),

            Password(id: 21, title: "Canva", username: "design_user", password: "Can@333", notes: "Design templates", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://canva.com", lastCopiedDate: nil),

            Password(id: 22, title: "Figma", username: "ui_designer", password: "Fig@888", notes: "UI design files", createdAt: Date(), lastModified: Date(), isFavorite: true, url: "https://figma.com", lastCopiedDate: nil),

            Password(id: 23, title: "Adobe", username: "creative_user", password: "Ado@111", notes: "Creative cloud", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://adobe.com", lastCopiedDate: nil),

            Password(id: 24, title: "DigitalOcean", username: "cloud_dev", password: "DO@999", notes: "Server hosting", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://digitalocean.com", lastCopiedDate: nil),

            Password(id: 25, title: "AWS", username: "aws_admin", password: "AWS@777", notes: "Cloud infra", createdAt: Date(), lastModified: Date(), isFavorite: true, url: "https://aws.amazon.com", lastCopiedDate: nil),

            Password(id: 26, title: "Firebase", username: "firebase_dev", password: "Fire@555", notes: "Backend services", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://firebase.google.com", lastCopiedDate: nil),

            Password(id: 27, title: "Bitbucket", username: "repo_user", password: "Bit@222", notes: "Private repos", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://bitbucket.org", lastCopiedDate: nil),

            Password(id: 28, title: "Heroku", username: "deploy_user", password: "Hero@123", notes: "App deployment", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://heroku.com", lastCopiedDate: nil),

            Password(id: 29, title: "Coursera", username: "learn_user", password: "Course@555", notes: "Online courses", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://coursera.org", lastCopiedDate: nil),

            Password(id: 30, title: "Udemy", username: "study_user", password: "Ude@444", notes: "Learning platform", createdAt: Date(), lastModified: Date(), isFavorite: false, url: "https://udemy.com", lastCopiedDate: nil)
        ]

        passwords.forEach { add(password: $0) }
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
        KeychainManager.shared.savePin(newPin)
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
