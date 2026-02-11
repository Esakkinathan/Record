//
//  AddMedicalUseCase.swift
//  record
//
//  Created by Esakkinathan B on 08/02/26.
//

class AddMedicalUseCase {
    private let repository: MedicalRepositoryProtocol
    
    init(repository: MedicalRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(medical: Medical) {
        repository.add(medical: medical)
    }
}
