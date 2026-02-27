//
//  DeleteRemainderUseCase.swift
//  record
//
//  Created by Esakkinathan B on 24/02/26.
//

protocol DeleteRemainderUseCaseProtocol {
    func execute(id: Int)
}

class DeleteRemainderUseCase: DeleteRemainderUseCaseProtocol {
    
    let repository: RemainderRepository
    init(repository: RemainderRepository) {
        self.repository = repository
    }
    func execute(id: Int) {
        repository.delete(id: id)
    }
    
}
