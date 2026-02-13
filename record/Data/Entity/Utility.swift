//
//  Utility.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//

import VTDB

class Utility: Persistable {
    func encode(to container: inout VTDB.Container) {
        container[Utility.idC] = id
        container[Utility.nameC] = name

    }
    
    static var databaseTableName: String {
        "Utility"
    }
    
    
    static let idC = "id"
    static let nameC = "name"
    
    let id: Int
    var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    func update(name: String) {
        self.name = name
    }
}

enum UtilityFormMode {
    case add
    case edit(Utility)
    
    var navigationTitle: String {
        switch self {
        case .add: return "Add Utility"
        case .edit: return "Edit Utility"
        }
    }

}
