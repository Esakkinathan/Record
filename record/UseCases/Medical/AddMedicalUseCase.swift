//
//  AddMedicalUseCase.swift
//  record
//
//  Created by Esakkinathan B on 08/02/26.
//

protocol AddMedicalUseCaseProtocol {
    func execute(medical: Medical)
}

class AddMedicalUseCase: AddMedicalUseCaseProtocol {
    private let repository: MedicalRepositoryProtocol
    
    init(repository: MedicalRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(medical: Medical) {
        repository.add(medical: medical)
    }
}
