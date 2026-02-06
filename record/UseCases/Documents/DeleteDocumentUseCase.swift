//
//  DeleteDocumentUseCase.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

final class DeleteDocumentUseCase {
    private let repository: DocumentRepository
    
    init(repository: DocumentRepository) {
        self.repository = repository
    }
    
    func execute(documentId: Int) {
        repository.delete(documentId: documentId)
    }
}
