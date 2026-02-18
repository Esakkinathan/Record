//
//  addUserCase.swift
//  record
//
//  Created by Esakkinathan B on 16/02/26.
//

protocol AddUserUseCaseProtocol {
    func execute(user: User)
}

class AddUserUseCase: AddUserUseCaseProtocol {
    var repository: UserRepositoryProtocol
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    func execute(user: User) {
        let password = user.password
        let hashPassword = HashManager.hash(for: password)
        user.password = hashPassword
        repository.add(user: user)
    }
}
