//
//  UpdateLogUseCase.swift
//  record
//
//  Created by Esakkinathan B on 18/02/26.
//

protocol UpdateLogUseCaseProtocol {
    func execute(log: MedicineIntakeLog)
}
class UpdateLogUseCase: UpdateLogUseCaseProtocol {
    private let repository: MedicalIntakeLogRepositoryProtocol
    
    init(repository: MedicalIntakeLogRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(log: MedicineIntakeLog) {
        repository.update(log: log)
    }

}
