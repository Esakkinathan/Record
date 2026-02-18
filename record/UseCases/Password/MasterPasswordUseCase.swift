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
        let data = HashManager.hash(for: password)
        repository.insertInto(password: data)
    }
    func fetch() -> String? {
        repository.fetchPassword()
    }
}
