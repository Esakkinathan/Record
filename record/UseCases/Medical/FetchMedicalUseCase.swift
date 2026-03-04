//
//  FetchMedicalUseCase.swift
//  record
//
//  Created by Esakkinathan B on 08/02/26.
//

protocol FetchMedicalUseCaseProtocol {
    func execute() -> [Medical]
    func fetchDoctors() -> Set<String>
    func fetchHospitals() -> Set<String>
}


class FetchMedicalUseCase: FetchMedicalUseCaseProtocol {
    
    private let repository: MedicalRepositoryProtocol
    
    init(repository: MedicalRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> [Medical] {
        return repository.fetchAll()
    }
    
    func activeMedicals() -> [Medical] {
        return repository.fetchActiveMedical()
    }
    
    func fetchDoctors() -> Set<String> {
        return Set(repository.fetchDoctors())
    }
    
    func fetchHospitals() -> Set<String> {
        return Set(repository.fetchHospitals())
    }

}
