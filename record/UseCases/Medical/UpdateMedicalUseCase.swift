//
//  UpdateMedicalUseCase.swift
//  record
//
//  Created by Esakkinathan B on 08/02/26.
//
protocol UpdateMedicalUseCaseProtocol {
    func execute(medical: Medical)
}
class UpdateMedicalUseCase: UpdateMedicalUseCaseProtocol {
    private let repository: MedicalRepositoryProtocol
    
    init(repository: MedicalRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(medical: Medical) {
        repository.update(medical: medical)
    }

}

protocol UpdateMedicalNotesUseCaseProtocol {
    func execute(text: String?, id: Int)
}


class UpdateMedicalNotesUseCase: UpdateMedicalNotesUseCaseProtocol {
    private let repository: MedicalRepositoryProtocol
    
    init(repository: MedicalRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(text: String?, id: Int) {
        repository.updateNotes(text: text, id: id)
    }
}
