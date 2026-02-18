//
//  GetUserByEmail.swift
//  record
//
//  Created by Esakkinathan B on 16/02/26.
//

protocol GetUserUseCaseProtocol {
    func execute(email: String) -> User?
    func execute(id: Int) -> User?
}

class GetUserUseCase: GetUserUseCaseProtocol {
    
    var repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(email: String) -> User? {
        return repository.getUserByEmail(email)
    }
    func execute(id: Int) -> User? {
        return repository.getUserById(id)
    }

}
