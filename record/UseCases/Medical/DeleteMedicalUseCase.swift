//
//  DeleteMedicalUseCase.swift
//  record
//
//  Created by Esakkinathan B on 08/02/26.
//

protocol DeleteMedicalUseCaseProtocol {
    func execute(id: Int)
}

class DeleteMedicalUseCase: DeleteMedicalUseCaseProtocol {
    private let repository: MedicalRepositoryProtocol
    
    init(repository: MedicalRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: Int) {
        repository.delete(id: id)
    }

}
