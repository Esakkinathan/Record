//
//  DeleteUtilityAccountAccountUseCase.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//

protocol DeleteUtilityAccountUseCaseProtocol {
    func execute(id: Int)
}

class DeleteUtilityAccountUseCase: DeleteUtilityAccountUseCaseProtocol {
    private let repository: UtilityAccountRepositoryProtocol
    
    init(repository: UtilityAccountRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: Int) {
        repository.delete(id: id)
    }

}
