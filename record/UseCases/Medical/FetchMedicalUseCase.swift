//
//  FetchMedicalUseCase.swift
//  record
//
//  Created by Esakkinathan B on 08/02/26.
//

class FetchMedicalUseCase {
    private let repository: MedicalRepositoryProtocol
    
    init(repository: MedicalRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> [Medical] {
        return repository.fetchAll()
    }
}
