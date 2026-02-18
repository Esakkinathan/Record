//
//  FetchMedicalItemUse.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//


protocol FetchMedicalItemUseCaseProtocol {
    func execute(id: Int, kind: MedicalKind) -> [MedicalItem]
}

class FetchMedicalItemUseCase: FetchMedicalItemUseCaseProtocol {
    private let repository: MedicalItemRepositoryProtocol
    
    init(repository: MedicalItemRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: Int, kind: MedicalKind) -> [MedicalItem] {
        return repository.fetchByMedicalId(id, kind: kind)
    }
}
