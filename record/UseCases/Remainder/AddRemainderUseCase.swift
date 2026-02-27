//
//  AddRemainderUse.swift
//  record
//
//  Created by Esakkinathan B on 24/02/26.
//

protocol AddRemainderUseCaseProtocol {
    func execute(remainder: Remainder) -> Int
}

class AddRemainderUseCase: AddRemainderUseCaseProtocol {
    var repository: RemainderRepositoryProtocol
    init(repository: RemainderRepositoryProtocol) {
        self.repository = repository
    }
    func execute(remainder: Remainder) -> Int {
        return repository.add(remainder: remainder)
    }
}
