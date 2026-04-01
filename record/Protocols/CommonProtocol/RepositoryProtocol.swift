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
    func toggleRestricted(_ document: Document)
    func fetchDocumentName() -> [String]
    
    func fetchDocuments(limit: Int, offset: Int, sort: DocumentSortOption, searchText: String?) -> [Document]
}

protocol PasswordRepositoryProtocol {
    func updateLastCopiedDate(id: Int, date: Date)
    func add(password: Password)
    func update(password: Password)
    func delete(id: Int)
    func fetchAll() -> [Password]
    func toggleFavourite(_ password: Password)
    func updateNotes(text: String?, id: Int)
    func resetPasswords(newPin: String)
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
    func fetchActiveMedical() -> [Medical]
    func fetchHospitals() -> [String]
    func fetchDoctors() -> [String]
    func setStatus(id: Int,value: Bool, date: Date?)
    func fetchMedical(limit: Int, offset: Int, sort: MedicalSortOption, category: MedicalType?,searchText: String?) -> [Medical]
}
protocol MedicineRepositoryProtocol {
    func add(medicine: Medicine, medicalId: Int)
    func update(medicine: Medicine)
    func delete(id: Int)
    func fetchMedicinesByMedicalId(_ id: Int, kind: MedicalKind) -> [Medicine]
    func fetchActiveMedicines(_ medicalId: Int) -> [Medicine]
    func fetchActiveMedicines() -> [Medicine]
//    func fetchMedicines(for medicalId: Int) -> [Medicine]
    func setStatus(id: Int,value: Bool, date: Date?)
    func fetchActiveMedicines(date: Date) -> [Medicine]
}
/*
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
*/
protocol UserRepositoryProtocol {
    func add(user: User)
    func updatePassword(userId: Int, newHash: String)
    func getUserByEmail(_ email: String) -> User?
    func getUserById(_ id: Int) -> User?
}

protocol LoginRepositoryProtocol {
    func add(session: LoginSession)
    func getLoginSession() ->LoginSession?
    func clearSession()
}

protocol MedicalIntakeLogRepositoryProtocol {
    func add(log: MedicineIntakeLog)
    func update(log: MedicineIntakeLog)
    func fetch(medicalId: Int,date: Date) -> [MedicineIntakeLog]
    func fetch(medicalId: Int) -> [MedicineIntakeLog]
}
