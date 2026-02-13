//
//  UpdateUtilityUseCase.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//

protocol UpdateUtilityUseCaseProtocol {
    func execute(utility: Utility)
}
class UpdateUtilityUseCase: UpdateUtilityUseCaseProtocol {
    private let repository: UtilityRepositoryProtocol
    
    init(repository: UtilityRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(utility: Utility) {
        repository.update(utility: utility)
    }

}

