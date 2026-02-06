//
//  AddDocumentUseCase.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

class AddDocumentUseCase {
    private let repository: DocumentRepository
    
    init(repository: DocumentRepository) {
        self.repository = repository
    }
    
    func execute(document: Document) {
        repository.add(document: document)
    }
}
