//
//  DeleteDocumentUseCase.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//
protocol DeleteDocumentUseCaseProtocol {
    func execute(id: Int)
}
class DeleteDocumentUseCase: DeleteDocumentUseCaseProtocol {
    private let repository: DocumentRepositoryProtocol
    
    init(repository: DocumentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: Int) {
        repository.delete(id: id)
    }
}
