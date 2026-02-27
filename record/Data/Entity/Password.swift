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
    static let lastCopiedDateC = "lastCopiedDate"

    
    let id: Int
    var title: String
    var username: String
    var password: String
    var notes: String?
    let createdAt: Date
    var lastModified: Date
    var isFavorite: Bool
    var lastCopiedDate: Date?
    
    init(id: Int, title: String, username: String, password: String, notes: String? = nil, createdAt: Date = Date(), lastModified: Date = Date(), isFavorite: Bool = false, lastCopiedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.username = username
        self.password = password
        self.notes = notes
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.isFavorite = isFavorite
        self.lastCopiedDate = lastCopiedDate
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
    
    func updateLastCopiedDate(date: Date) {
        lastCopiedDate = date
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
        container[Password.lastCopiedDateC] = lastCopiedDate
    }
    
    static var databaseTableName: String {
        return "Password"
    }


}

enum PasswordSortField: String, Codable {
    case title = "Title"
    case createdAt = "Created At"
    case updatedAt = "Recent"
}

struct PasswordSortOption: Codable, Equatable  {
    let field: PasswordSortField
    let direction: SortDirection
}


enum PasswordSortStore {
    private static let key = "password_sort_option"

    static func load() -> PasswordSortOption {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let option = try? JSONDecoder().decode(PasswordSortOption.self, from: data)
        else {
            return PasswordSortOption(field: .title, direction: .ascending)
        }
        return option
    }

    static func save(_ option: PasswordSortOption) {
        let data = try? JSONEncoder().encode(option)
        UserDefaults.standard.set(data, forKey: key)
    }
}

enum PasswordFormMode: FormMode {
    case add
    case edit(Password)
    
    var navigationTitle: String {
        switch self {
        case .add: return "Add Password"
        case .edit: return "Edit Password"
        }
    }

}
