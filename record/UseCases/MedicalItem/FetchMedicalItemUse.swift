//
//  FetchMedicalItemUse.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//


protocol FetchMedicineUseCaseProtocol {
    func execute(id: Int, kind: MedicalKind) -> [Medicine]
}

class FetchMedicineUseCase: FetchMedicineUseCaseProtocol {
    private let repository: MedicineRepositoryProtocol
    
    init(repository: MedicineRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: Int, kind: MedicalKind) -> [Medicine] {
        return repository.fetchMedicinesByMedicalId(id, kind: kind)
    }
}
