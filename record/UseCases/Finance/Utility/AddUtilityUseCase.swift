//
//  AddUtilityUseCase.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//


protocol AddUtilityUseCaseProtocol {
    func execute(utility: Utility)
}

class AddUtilityUseCase: AddUtilityUseCaseProtocol {
    private let repository: UtilityRepositoryProtocol
    
    init(repository: UtilityRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(utility: Utility) {
        repository.add(utility: utility)
    }
}
