//
//  FetchDocumentUseCase.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

final class FetchDocumentsUseCase {
    private let repository: DocumentRepository
    
    init(repository: DocumentRepository) {
        self.repository = repository
    }
    
    func execute() -> [[Document]] {
        let docs = repository.fetchAll()
        var documents: [[Document]] = []
        let grouped = Dictionary(grouping: docs, by: { $0.type })
        documents.append(grouped[.Default] ?? [])
        documents.append(grouped[.Custom] ?? [])
        return documents
    }
}
