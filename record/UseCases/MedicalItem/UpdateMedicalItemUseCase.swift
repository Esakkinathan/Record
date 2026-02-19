//
//  UpdateMedicalItemUseCase.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
import Foundation
protocol UpdateMedicalItemUseCaseProtocol {
    func execute(medicalItem: MedicalItem)
    func execute(medicalItemId: Int, date: Date)
}

    

class UpdateMedicalItemUseCase: UpdateMedicalItemUseCaseProtocol {
    private let repository: MedicalItemRepositoryProtocol
    
    init(repository: MedicalItemRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(medicalItem: MedicalItem) {
        repository.update(medicalItem: medicalItem)
    }
    func execute(medicalItemId: Int, date: Date) {
        repository.updateEndDate(medicalItemId: medicalItemId, date: date)
        NotificationManager.shared.syncMedicalNotifications()

    }

}
