//
//  DocumentRepository.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//
import Foundation

protocol RepositoryProtocol {
    
}

protocol DocumentRepositoryProtocol {
    func add(document: Document)
    func update(document: Document)
    func delete(id: Int)
    func fetchAll() -> [Document]
    func updateNotes(text: String?, id: Int)
}

protocol PasswordRepositoryProtocol {
    func add(password: Password)
    func update(newPassword: Password)
    func delete(id: Int)
    func fetchAll() -> [Password]
    func toggleFavourite(_ password: Password)
    func updateNotes(text: String?, id: Int)
}

protocol MasterPasswordRepositoryProtocol {
    func insertInto(password: String)
    func fetchPassword() -> String?
}

protocol MedicalRepositoryProtocol {
    func add(medical: Medical)
    func update(medical: Medical)
    func delete(id: Int)
    func fetchAll() -> [Medical]
    func updateNotes(text: String?, id: Int)

}
protocol MedicalItemRepositoryProtocol {
    func add(medicalItem: MedicalItem, medicalId: Int)
    func update(medicalItem: MedicalItem)
    func delete(id: Int)
    func fetchByMedicalId(_ id: Int, kind: MedicalKind) -> [MedicalItem]
}

protocol UtilityRepositoryProtocol {
    func add(utility: Utility)
    func update(utility: Utility)
    func delete(id: Int)
    func fetchAll() -> [Utility]

}

protocol UtilityAccountRepositoryProtocol {
    func add(utilityAccount: UtilityAccount)
    func update(utilityAccount: UtilityAccount)
    func delete(id: Int)
    func fetchAllByUtilityId(utilityId: Int) -> [UtilityAccount]
    func updateNotes(text: String?, id: Int)

}

protocol BillRepositoryProtocol {
    func add(bill: Bill)
    func update(bill: Bill)
    func updateNotes(text: String?, id: Int)
    func delete(id: Int)
    func fetchAll(utilityAccountId: Int, billType: BillType) -> [Bill]
    func markAsPaid(billId: Int, paidDate: Date)
}
