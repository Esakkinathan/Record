//
//  UpdateDocumentUseCase.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

class UpdateDocumentUseCase {
    private let repository: DocumentRepositoryProtocol
    
    init(repository: DocumentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(document: Document) {
        repository.update(document: document)
    }
}

class UpdateDocumentNotesUseCase {
    private let repository: DocumentRepositoryProtocol
    
    init(repository: DocumentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(text: String?, id: Int) {
        repository.updateNotes(text: text, id: id)
    }
}
