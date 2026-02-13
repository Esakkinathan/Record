//
//  UpdateUtilityAccountUseCase.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//

protocol UpdateUtilityAccountUseCaseProtocol {
    func execute(utilityAccount: UtilityAccount)
}
class UpdateUtilityAccountUseCase: UpdateUtilityAccountUseCaseProtocol {
    private let repository: UtilityAccountRepositoryProtocol
    
    init(repository: UtilityAccountRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(utilityAccount: UtilityAccount) {
        repository.update(utilityAccount: utilityAccount)
    }

}

protocol UpdateUtilityAccountNotesUseCaseProtocol {
    func execute(text: String?, id: Int)
}


class UpdateUtilityAccountNotesUseCase: UpdateUtilityAccountNotesUseCaseProtocol {
    private let repository: UtilityAccountRepositoryProtocol
    
    init(repository: UtilityAccountRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(text: String?, id: Int) {
        repository.updateNotes(text: text, id: id)
    }
}
