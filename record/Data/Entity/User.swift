//
//  User.swift
//  record
//
//  Created by Esakkinathan B on 16/02/26.
//
import VTDB

class User: Persistable {
    
    func encode(to container: inout VTDB.Container) {
        container[User.idC] = id
        container[User.emailC] = email
        container[User.nameC] = name
        container[User.passwordC] = password

    }
    
    static var databaseTableName: String {
        "User"
    }
    
    
    static let idC = "id"
    static let emailC = "email"
    static let nameC = "name"
    static let passwordC = "password"
    
    let id: Int
    let email: String
    let name: String
    var password: String
    
    init(id: Int, email: String,  name: String, password: String) {
        self.id = id
        self.email = email
        self.name = name
        self.password = password
    }
    
}

class LoginSession: Persistable {
    func encode(to container: inout VTDB.Container) {
        //
    }
    static let userIdC = "userId"
    static let lastLoginC = "lastLogin"
    
    static var databaseTableName: String {
        "LoginSession"
    }
    
    var userId:Int
    var lastLogin: Date
    init(userId: Int, lastLogin: Date) {
        self.userId = userId
        self.lastLogin = lastLogin
    }
}
