//
//  UpdateMedicalUseCase.swift
//  record
//
//  Created by Esakkinathan B on 08/02/26.
//

class UpdateMedicalUseCase {
    private let repository: MedicalRepositoryProtocol
    
    init(repository: MedicalRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(medical: Medical) {
        repository.update(medical: medical)
    }

}

class UpdateMedicalNotesUseCase {
    private let repository: MedicalRepositoryProtocol
    
    init(repository: MedicalRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(text: String?, id: Int) {
        repository.updateNotes(text: text, id: id)
    }
}
