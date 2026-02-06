//
//  DocumentRepository.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//
import Foundation

protocol RepositoryProtocol {
    
}

protocol DocumentRepositoryProtocol {
    func add(document: Document)
    func update(document: Document)
    func delete(id: Int)
    func fetchAll() -> [Document]
    func updateNotes(text: String?, id: Int)
}

protocol PasswordRepositoryProtocol {
    func add(password: Password)
    func update(newPassword: Password)
    func delete(id: Int)
    func fetchAll() -> [Password]
    func toggleFavourite(_ password: Password)
    func updateNotes(text: String?, id: Int)
}

protocol MasterPasswordRepositoryProtocol {
    func insertInto(password: String)
    func fetchPassword() -> String?
}
