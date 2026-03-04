//
//  ResetPasswordUseCase.swift
//  record
//
//  Created by Esakkinathan B on 02/03/26.
//
import Foundation

protocol ResetPasswordUseCaseProtocol {
    func execute(newPin: String)
}

class ResetPasswordUseCase: ResetPasswordUseCaseProtocol {
    var repository: PasswordRepositoryProtocol
    
    init(repository: PasswordRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(newPin: String) {
        repository.resetPasswords(newPin: newPin)
    }
}
