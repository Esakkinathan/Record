//
//  ToggleFavouriteUseCase.swift
//  record
//
//  Created by Esakkinathan B on 04/02/26.
//

class ToggleFavouriteUseCase {
    var repository: PasswordRepositoryProtocol
    
    init(repository: PasswordRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ password: Password) {
        repository.toggleFavourite(password)
    }

}
