//
//  UpdatePasswordUseCase.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//
import Foundation
class UpdatePasswordUseCase {
    private let repository: PasswordRepositoryProtocol
    
    init(repository: PasswordRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(password: Password) {
        repository.update(password: password)
    }
    
    func execute(text: String?, id: Int) {
        repository.updateNotes(text: text, id: id)
    }
    func execute(id: Int, date: Date) {
        repository.updateLastCopiedDate(id: id, date: date)
    }
}

class UpdatePasswordNotesUseCase {
    private let repository: PasswordRepositoryProtocol
    
    init(repository: PasswordRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(text: String?, id: Int) {
        repository.updateNotes(text: text, id: id)
    }
}
