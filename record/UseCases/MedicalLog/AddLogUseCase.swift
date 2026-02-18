//
//  AddLogUseCase.swift
//  record
//
//  Created by Esakkinathan B on 18/02/26.
//


protocol AddLogUseCaseProtocol {
    func execute(log: MedicalIntakeLog)
}

class AddLogUseCase: AddLogUseCaseProtocol {
    private let repository: MedicalIntakeLogRepositoryProtocol
    
    init(repository: MedicalIntakeLogRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(log: MedicalIntakeLog) {
        repository.add(log: log)
    }
}
