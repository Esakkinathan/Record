//
//  FetchUtilityUseCase.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//

protocol FetchUtilityUseCaseProtocol {
    func execute() -> [Utility]
}

class FetchUtilityUseCase: FetchUtilityUseCaseProtocol {
    private let repository: UtilityRepositoryProtocol
    
    init(repository: UtilityRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> [Utility] {
        return repository.fetchAll()
    }
}
