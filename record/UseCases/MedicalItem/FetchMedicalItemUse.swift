//
//  FetchMedicalItemUse.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//

class FetchMedicalItemUseCase {
    private let repository: MedicalItemRepositoryProtocol
    
    init(repository: MedicalItemRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: Int, kind: MedicalKind) -> [MedicalItem] {
        return repository.fetchByMedicalId(id, kind: kind)
    }
}
