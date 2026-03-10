//
//  UpdateDocumentUseCase.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//
protocol UpdateDocumentUseCaseProtocol {
    func execute(document: Document)
    func execute(text: String?, id: Int)
    func toggleRestricted(document: Document)
}
class UpdateDocumentUseCase: UpdateDocumentUseCaseProtocol {
    private let repository: DocumentRepositoryProtocol
    
    init(repository: DocumentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(document: Document) {
        repository.update(document: document)
    }
    func execute(text: String?, id: Int) {
        repository.updateNotes(text: text, id: id)
    }
    func toggleRestricted(document: Document) {
        repository.toggleRestricted(document)
    }
}

