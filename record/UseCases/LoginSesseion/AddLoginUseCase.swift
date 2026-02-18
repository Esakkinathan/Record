//
//  AddLoginUseCase.swift
//  record
//
//  Created by Esakkinathan B on 17/02/26.
//


protocol AddLoginUseCaseProtocol {
    func execute(session: LoginSession)
}

class AddLoginUseCase: AddLoginUseCaseProtocol {
    var repository: LoginRepositoryProtocol
    init(repository: LoginRepositoryProtocol) {
        self.repository = repository
    }
    func execute(session: LoginSession) {
        repository.add(session: session)
    }
}
