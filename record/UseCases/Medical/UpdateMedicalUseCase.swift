//
//  UpdateMedicalUseCase.swift
//  record
//
//  Created by Esakkinathan B on 08/02/26.
//

import Foundation

protocol UpdateMedicalUseCaseProtocol {
    func execute(medical: Medical)
    func setStatus(medical: Medical, value: Bool, date: Date?)
    func execute(text: String?, id: Int)
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
    
    func setStatus(medical: Medical, value: Bool, date: Date?) {
        repository.setStatus(id: medical.id, value: value, date: date)
        let medicines = medicineRepo.fetchActiveMedicines(medical.id)
        print("medicine count",medicines.count)
        if !value {
            //let medicines = medicineRepo.fetchActiveMedicines(id)
            for medicine in medicines {
                if medicine.status {
                    medicineRepo.setStatus(id: medicine.id, value: value, date: date)
                }
            }
        } else {
            for medicine in medicines {
                if let medicineEndDate = medicine.endDate, medicineEndDate == Date().end {
                    medicineRepo.setStatus(id: medicine.id, value: value, date: date)
                }
            }
        }
    }
    func execute(text: String?, id: Int) {
        repository.updateNotes(text: text, id: id)
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
