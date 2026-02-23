//
//  FetchMedicalUseCase.swift
//  record
//
//  Created by Esakkinathan B on 08/02/26.
//

protocol FetchMedicalUseCaseProtocol {
    func execute() -> [Medical]
    func fetchDoctors() -> [String]
    func fetchHospitals() -> [String]
}


class FetchMedicalUseCase: FetchMedicalUseCaseProtocol {
    
    private let repository: MedicalRepositoryProtocol
    
    init(repository: MedicalRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> [Medical] {
        return repository.fetchAll()
    }
    func fetchDoctors() -> [String] {
        repository.fetchDoctors()
    }
    
    func fetchHospitals() -> [String] {
        repository.fetchHospitals()
    }

}
