//
//  MedicalItem.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//

protocol AddMedicalItemUseCaseProtocol {
    func execute(medicalItem: MedicalItem, medicalId: Int)

}

class AddMedicalItemUseCase: AddMedicalItemUseCaseProtocol {
    private let repository: MedicalItemRepositoryProtocol
    
    init(repository: MedicalItemRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(medicalItem: MedicalItem, medicalId: Int) {
        repository.add(medicalItem: medicalItem, medicalId: medicalId)
        NotificationManager.shared.syncMedicalNotifications()

    }
}
