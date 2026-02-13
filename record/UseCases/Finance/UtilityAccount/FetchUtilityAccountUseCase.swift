//
//  FetchUtilityAccountAccountUseCase.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//

protocol FetchUtilityAccountUseCaseProtocol {
    func execute(utilityId: Int) -> [UtilityAccount]
}

class FetchUtilityAccountUseCase: FetchUtilityAccountUseCaseProtocol {
    private let repository: UtilityAccountRepositoryProtocol
    
    init(repository: UtilityAccountRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(utilityId: Int) -> [UtilityAccount] {
        return repository.fetchAllByUtilityId(utilityId: utilityId)
    }
}
