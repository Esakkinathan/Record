//
//  ClearLoginUseCase.swift
//  record
//
//  Created by Esakkinathan B on 17/02/26.
//



protocol ClearLoginUseCaseProtocol {
    func execute()
}

class ClearLoginUseCase: ClearLoginUseCaseProtocol {
    var repository: LoginRepositoryProtocol
    init(repository: LoginRepositoryProtocol) {
        self.repository = repository
    }
    func execute() {
        repository.clearSession()
    }
}
