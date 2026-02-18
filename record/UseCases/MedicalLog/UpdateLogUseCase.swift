//
//  UpdateLogUseCase.swift
//  record
//
//  Created by Esakkinathan B on 18/02/26.
//

protocol UpdateLogUseCaseProtocol {
    func execute(log: MedicalIntakeLog)
}
class UpdateLogUseCase: UpdateLogUseCaseProtocol {
    private let repository: MedicalIntakeLogRepositoryProtocol
    
    init(repository: MedicalIntakeLogRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(log: MedicalIntakeLog) {
        repository.update(log: log)
    }

}
