//
//  MarkAsPaidUseCase.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//
import Foundation

protocol MarkAsPaidUseCaseProtocol {
    func execute(bill: Bill, paidDate: Date)
}

class MarkAsPaidUseCase: MarkAsPaidUseCaseProtocol {
    var repository: BillRepositoryProtocol
    
    init(repository: BillRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bill: Bill, paidDate: Date) {
        repository.markAsPaid(billId: bill.id, paidDate: paidDate)
    }
    
}
