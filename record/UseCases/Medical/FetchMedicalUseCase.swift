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
    func fetchMedical(limit: Int, offset: Int, sort: MedicalSortOption, category: MedicalType?,searchText: String?) -> [Medical]
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
        let hospitals = repository.fetchHospitals()
        return Set(hospitals)
    }
    func fetchMedical(limit: Int, offset: Int, sort: MedicalSortOption, category: MedicalType?,searchText: String?) -> [Medical] {
        return repository.fetchMedical(limit: limit, offset: offset, sort: sort, category: category, searchText: searchText)
    }

}
