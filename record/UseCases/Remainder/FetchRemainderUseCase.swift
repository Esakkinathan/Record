//
//  FetchRemainderUse.swift
//  record
//
//  Created by Esakkinathan B on 24/02/26.
//

protocol FetchRemainderUseCaseProtocol {
    func execute(id: Int) -> [Remainder]
}

class FetchRemainderUseCase: FetchRemainderUseCaseProtocol {
    let repository: RemainderRepositoryProtocol
    init(repository: RemainderRepositoryProtocol) {
        self.repository = repository
    }
    func execute(id: Int) -> [Remainder] {
        return repository.fetchAllByDocumentId(id)
    }
}
