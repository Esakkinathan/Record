//
//  UpdateBillUseCase.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//

protocol UpdateBillUseCaseProtocol {
    func execute(bill: Bill)
}
class UpdateBillUseCase: UpdateBillUseCaseProtocol {
    private let repository: BillRepositoryProtocol
    
    init(repository: BillRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bill: Bill) {
        repository.update(bill: bill)
    }

}

