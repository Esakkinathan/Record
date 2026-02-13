//
//  DelteBillUseCase.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//

protocol DeleteBillUseCaseProtocl {
    func execute(id: Int)
}

class DeleteBillUseCase: DeleteBillUseCaseProtocl {
    private let repository: BillRepositoryProtocol
    
    init(repository: BillRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: Int) {
        repository.delete(id: id)
    }

}
