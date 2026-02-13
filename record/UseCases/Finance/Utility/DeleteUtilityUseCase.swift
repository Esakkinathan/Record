//
//  DeleteUtilityUseCase.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//
protocol DeleteUtilityUseCaseProtocol {
    func execute(id: Int)
}

class DeleteUtilityUseCase: DeleteUtilityUseCaseProtocol {
    private let repository: UtilityRepositoryProtocol
    
    init(repository: UtilityRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: Int) {
        repository.delete(id: id)
    }

}
