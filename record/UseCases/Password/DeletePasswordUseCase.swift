//
//  DeletePasswordUseCase.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

class DeletePasswordUseCase {
    private let repository: PasswordRepositoryProtocol
    
    init(repository: PasswordRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: Int) {
        repository.delete(id: id)
    }
}
