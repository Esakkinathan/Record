//
//  UdateUserPasswordUseCase.swift
//  record
//
//  Created by Esakkinathan B on 16/02/26.
//

protocol UpdateUserPasswordUseCaseProtocol {
    func execute(userId: Int, password: String)
}

class UpdateUserPasswordUseCase: UpdateUserPasswordUseCaseProtocol {
    var repository: UserRepositoryProtocol
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    func execute(userId: Int, password: String)  {
        let hashPassword = HashManager.hash(for: password)
        //repository.updatePassword(userId: userId, newHash: hashPassword)
    }
}
