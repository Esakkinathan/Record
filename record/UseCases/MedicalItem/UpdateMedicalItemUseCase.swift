//
//  UpdateMedicalItemUseCase.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//


class UpdateMedicalItemUseCase {
    private let repository: MedicalItemRepositoryProtocol
    
    init(repository: MedicalItemRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(medicalItem: MedicalItem) {
        repository.update(medicalItem: medicalItem)
    }

}
