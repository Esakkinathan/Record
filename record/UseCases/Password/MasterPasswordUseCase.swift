//
//  MasterPasswordUseCase.swift
//  record
//
//  Created by Esakkinathan B on 06/02/26.
//

class MasterPasswordUseCase {
    var repository: MasterPasswordRepositoryProtocol
    
    init(repository: MasterPasswordRepositoryProtocol) {
        self.repository = repository
    }
    func add(_ password: String) {
        repository.insertInto(password: password)
    }
    func fetch() -> String? {
        repository.fetchPassword()
    }
    
    
}
