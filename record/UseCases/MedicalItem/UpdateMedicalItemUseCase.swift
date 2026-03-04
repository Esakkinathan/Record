//
//  UpdateMedicalItemUseCase.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
import Foundation
protocol UpdateMedicineUseCaseProtocol {
    func execute(medicine: Medicine)
    func execute(medicineId: Int, value: Bool,date: Date?)
}

    

class UpdateMedicineUseCase: UpdateMedicineUseCaseProtocol {
    private let repository: MedicineRepositoryProtocol
    
    init(repository: MedicineRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(medicine: Medicine) {
        repository.update(medicine: medicine)
    }
    func execute(medicineId: Int, value: Bool,date: Date?) {
        repository.setStatus(id: medicineId, value: value, date: date)
        NotificationManager.shared.syncMedicalNotifications()

    }

}
