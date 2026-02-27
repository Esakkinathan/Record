//
//  ToggleRestrictedDocumentUseCase.swift
//  record
//
//  Created by Esakkinathan B on 27/02/26.
//

class ToggleRestrictedUseCase {
    var repository: DocumentRepositoryProtocol
    
    init(repository: DocumentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ document: Document) {
        repository.toggleRestricted(document)
    }
}
