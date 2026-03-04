//
//  FetchLogUse.swift
//  record
//
//  Created by Esakkinathan B on 18/02/26.
//
import Foundation

protocol FetchLogUseCaseProtocol {
    func execute(medicalId: Int, date: Date) -> [MedicineIntakeLog]
}


class FetchLogUseCase: FetchLogUseCaseProtocol {
    private let repository: MedicalIntakeLogRepositoryProtocol
    
    init(repository: MedicalIntakeLogRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(medicalId: Int, date: Date) -> [MedicineIntakeLog] {
        return repository.fetch(medicalId: medicalId, date: date)
    }
    func execute(medicalId: Int) -> [MedicineIntakeLog] {
        return repository.fetch(medicalId: medicalId)
    }
}
