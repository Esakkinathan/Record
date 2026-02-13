//
//  FetchBillUseCase.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//

protocol FetchBillUseCaseProtocol {
    func execute(utilityAccountId: Int, billType: BillType) -> [Bill]
}

class FetchBillUseCase: FetchBillUseCaseProtocol {
    private let repository: BillRepositoryProtocol
    
    init(repository: BillRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(utilityAccountId: Int, billType: BillType) -> [Bill] {
        return repository.fetchAll(utilityAccountId: utilityAccountId, billType: billType)
    }
}
