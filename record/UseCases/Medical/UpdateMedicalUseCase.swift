//
//  UpdateMedicalUseCase.swift
//  record
//
//  Created by Esakkinathan B on 08/02/26.
//

import Foundation

protocol UpdateMedicalUseCaseProtocol {
    func execute(medical: Medical)
    func setStatus(id: Int, value: Bool, date: Date?)
}
class UpdateMedicalUseCase: UpdateMedicalUseCaseProtocol {
    private let repository: MedicalRepositoryProtocol
    let medicineRepo: MedicineRepositoryProtocol
    init(repository: MedicalRepositoryProtocol) {
        self.repository = repository
        self.medicineRepo = MedicineRepository()
    }
    
    
    func execute(medical: Medical) {
        repository.update(medical: medical)
    }
    
    func setStatus(id: Int, value: Bool, date: Date?) {
        repository.setStatus(id: id, value: value, date: date)
        let medicines = medicineRepo.fetchActiveMedicines(id)
        for medicine in medicines {
            medicineRepo.setStatus(id: medicine.id, value: value, date: date)
        }
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
