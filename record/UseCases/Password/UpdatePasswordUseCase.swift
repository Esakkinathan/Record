//
//  UpdatePasswordUseCase.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

class UpdatePasswordUseCase {
    private let repository: PasswordRepositoryProtocol
    
    init(repository: PasswordRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(password: Password) {
        repository.update(newPassword: password)
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
