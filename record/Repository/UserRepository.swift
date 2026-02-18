//
//  UserRepository.swift
//  record
//
//  Created by Esakkinathan B on 16/02/26.
//
import VTDB

class UserRepository: UserRepositoryProtocol {
    var db: UserDatebaseProtocol = DatabaseAdapter.shared
    
    init() {
        createTable()
    }
    
    func createTable() {
        let columns: [String: TableColumnType] = [
            User.idC: .int,
            User.emailC: .string,
            User.nameC: .string,
            User.passwordC: .string
        ]
        
        db.create(table: User.databaseTableName, columnDefinitions: columns, primaryKey: [User.idC], uniqueKeys: [[User.emailC]])
    }
    
    func add(user: User) {
        let columns: [String: Any?] = [
            User.emailC: user.email,
            User.nameC: user.name,
            User.passwordC: user.password
        ]
        
        db.insertInto(tableName: User.databaseTableName, values: columns)
    }
    func updatePassword(userId: Int, newHash: String) {
        db.updatePassword(userId: userId, newHash: newHash)
    }
    
    func getUserByEmail(_ email: String) -> User? {
        return db.getUserByEmail(email)
    }
    func getUserById(_ id: Int) -> User? {
        return db.getUserById(id)
    }

}

class LoginRepository: LoginRepositoryProtocol {
    var db: LoginDatebaseProtocol = DatabaseAdapter.shared
    
    init() {
        createTable()
    }
    
    func createTable() {
        let columns: [String: TableColumnType] = [
            LoginSession.userIdC: .int,
            LoginSession.lastLoginC: .date,
        ]
        
        db.create(table: LoginSession.databaseTableName, columnDefinitions: columns, primaryKey: [LoginSession.userIdC])

    }
    
    func add(session: LoginSession) {
        let columns: [String: Any?] = [
            LoginSession.userIdC: session.userId,
            LoginSession.lastLoginC: session.lastLogin,
        ]
        
        db.insertInto(tableName: LoginSession.databaseTableName, values: columns)
    }
    
    func getLoginSession() ->LoginSession? {
        return db.getLoginSession()
    }
    
    func clearSession() {
        db.deleteAll(table: LoginSession.databaseTableName)
    }
}
