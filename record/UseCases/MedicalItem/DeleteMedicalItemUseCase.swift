//
//  DeleteMedicalItemUseCase.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
protocol DeleteMedicalItemUseCaseProtocol {
    func execute(id: Int)
}


class DeleteMedicalItemUseCase: DeleteMedicalItemUseCaseProtocol {
    private let repository: MedicalItemRepositoryProtocol
    
    init(repository: MedicalItemRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: Int) {
        repository.delete(id: id)
        NotificationManager.shared.syncMedicalNotifications()

    }

}
