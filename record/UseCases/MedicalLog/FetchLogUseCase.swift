//
//  FetchLogUse.swift
//  record
//
//  Created by Esakkinathan B on 18/02/26.
//
import Foundation

protocol FetchLogUseCaseProtocol {
    func execute(medicalId: Int, date: Date) -> [MedicalIntakeLog]
}


class FetchLogUseCase: FetchLogUseCaseProtocol {
    private let repository: MedicalIntakeLogRepositoryProtocol
    
    init(repository: MedicalIntakeLogRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(medicalId: Int, date: Date) -> [MedicalIntakeLog] {
        return repository.fetch(medicalId: medicalId, date: date)
    }
}
