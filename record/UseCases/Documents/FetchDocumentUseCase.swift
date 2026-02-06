//
//  FetchDocumentUseCase.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

class FetchDocumentsUseCase {
    private let repository: DocumentRepositoryProtocol
    
    init(repository: DocumentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> [Document] {
        return repository.fetchAll()
    }
}
