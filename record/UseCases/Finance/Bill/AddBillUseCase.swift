//
//  UseCase.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//

protocol AddBillUseCaseProtocol {
    func execute(bill: Bill)
}

class AddBillUseCase: AddBillUseCaseProtocol {
    private let repository: BillRepositoryProtocol
    
    init(repository: BillRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bill: Bill) {
        repository.add(bill: bill)
    }
}
