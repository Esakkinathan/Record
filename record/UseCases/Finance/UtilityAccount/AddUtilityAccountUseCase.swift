//
//  Addd.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//


protocol AddUtilityAccountUseCaseProtocol {
    func execute(utilityAccount: UtilityAccount)
}

class AddUtilityAccountUseCase: AddUtilityAccountUseCaseProtocol {
    private let repository: UtilityAccountRepositoryProtocol
    
    init(repository: UtilityAccountRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(utilityAccount: UtilityAccount) {
        repository.add(utilityAccount: utilityAccount)
    }
}

