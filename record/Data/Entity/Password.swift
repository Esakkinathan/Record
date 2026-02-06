//
//  Password.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//
import Foundation
import VTDB

class Password: Persistable {
    
    static var counter = 1

    static let idC = "id"
    static let titleC = "title"
    static let usernameC = "username"
    static let passwordC = "password"
    static let notesC = "notes"
    static let createdAtC = "createdAt"
    static let lastModifiedC = "lastModified"
    static let isFavoriteC = "isFavorite"

    
    let id: Int
    var title: String
    var username: String
    var password: String
    var notes: String?
    let createdAt: Date
    var lastModified: Date
    var isFavorite: Bool
    
    init(id: Int, title: String, username: String, password: String, notes: String? = nil, createdAt: Date = Date(), lastModified: Date = Date(), isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.username = username
        self.password = password
        self.notes = notes
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.isFavorite = isFavorite
    }
    
    func toggleFavorite() {
        isFavorite = !isFavorite
    }
    
    func update(title: String, username: String, password: String) {
        self.title = title
        self.username = username
        self.password = password
        self.lastModified = Date()

    }
    
    func updateNotes(text: String?) {
        notes = text
    }
    
    func encode(to container: inout VTDB.Container) {
        container[Password.idC] = id
        container[Password.titleC] = title
        container[Password.usernameC] = username
        container[Password.notesC] = notes
        container[Password.createdAtC] = createdAt
        container[Password.lastModifiedC] = lastModified
        container[Password.isFavoriteC] = isFavorite
    }
    
    static var databaseTableName: String {
        return "Password"
    }


}
