//
//  AddLogUseCase.swift
//  record
//
//  Created by Esakkinathan B on 18/02/26.
//


protocol AddLogUseCaseProtocol {
    func execute(log: MedicineIntakeLog)
}

class AddLogUseCase: AddLogUseCaseProtocol {
    private let repository: MedicalIntakeLogRepositoryProtocol
    
    init(repository: MedicalIntakeLogRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(log: MedicineIntakeLog) {
        repository.add(log: log)
    }
}
