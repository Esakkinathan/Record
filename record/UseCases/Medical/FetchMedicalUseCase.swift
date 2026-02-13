//
//  FetchMedicalUseCase.swift
//  record
//
//  Created by Esakkinathan B on 08/02/26.
//

protocol FetchMedicalUseCaseProtocol {
    func execute() -> [Medical]
}


class FetchMedicalUseCase: FetchMedicalUseCaseProtocol {
    private let repository: MedicalRepositoryProtocol
    
    init(repository: MedicalRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> [Medical] {
        return repository.fetchAll()
    }
}
