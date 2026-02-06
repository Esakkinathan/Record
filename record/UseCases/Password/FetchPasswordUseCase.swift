//
//  FetchPasswordUseCase.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

class FetchPasswordUseCase {
    var repository: PasswordRepositoryProtocol
    
    init(repository: PasswordRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> [Password] {
        return repository.fetchAll()
    }
}
