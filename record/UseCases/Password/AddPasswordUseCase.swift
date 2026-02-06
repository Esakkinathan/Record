//
//  AddPasswordUseCase.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

class AddPasswordUseCase {
    private let repository: PasswordRepositoryProtocol
    
    init(repository: PasswordRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(password: Password) {
        repository.add(password: password)
    }
}
