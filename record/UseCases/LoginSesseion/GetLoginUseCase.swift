//
//  GetLoginUseCase.swift
//  record
//
//  Created by Esakkinathan B on 17/02/26.
//

protocol GetLoginUseCaseProtocol {
    func execute() -> LoginSession?

}

class GetLoginUseCase: GetLoginUseCaseProtocol {
    
    var repository: LoginRepositoryProtocol
    
    init(repository: LoginRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> LoginSession? {
        repository.getLoginSession()
    }
}
