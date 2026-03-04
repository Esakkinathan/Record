//
//  MedicalItem.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//

protocol AddMedicineUseCaseProtocol {
    func execute(medicine: Medicine, medicalId: Int) 
}

class AddMedicineUseCase: AddMedicineUseCaseProtocol {
    private let repository: MedicineRepositoryProtocol
    
    init(repository: MedicineRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(medicine: Medicine, medicalId: Int) {
        repository.add(medicine: medicine, medicalId: medicalId)
        NotificationManager.shared.syncMedicalNotifications()

    }
}
