//
//  DeleteMedicalItemUseCase.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
protocol DeleteMedicineUseCaseProtocol {
    func execute(id: Int)
}


class DeleteMedicineUseCase: DeleteMedicineUseCaseProtocol {
    private let repository: MedicineRepositoryProtocol
    
    init(repository: MedicineRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: Int) {
        repository.delete(id: id)
        NotificationManager.shared.syncMedicalNotifications()

    }

}
