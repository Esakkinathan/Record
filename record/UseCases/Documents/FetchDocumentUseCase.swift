//
//  FetchDocumentUseCase.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//
protocol FetchDocumentsUseCaseProtocol {
    func execute() -> [Document]
    func execute(limit: Int, offset: Int, sort: DocumentSortOption, searchText: String?) -> [Document]
    func fetchDocument() -> Set<String>
}
class FetchDocumentsUseCase: FetchDocumentsUseCaseProtocol {
    private let repository: DocumentRepositoryProtocol
    
    init(repository: DocumentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> [Document] {
        return repository.fetchAll()
    }
    func execute(limit: Int, offset: Int, sort: DocumentSortOption, searchText: String?) -> [Document] {
        return repository.fetchDocuments(limit: limit, offset: offset, sort: sort, searchText: searchText)
    }
    
    func fetchDocument() -> Set<String> {
        var names = Set(repository.fetchDocumentName())
        let documents = DefaultDocument.allCases
        for document in documents {
            names.insert(document.rawValue)
        }
        return names
    }
}
