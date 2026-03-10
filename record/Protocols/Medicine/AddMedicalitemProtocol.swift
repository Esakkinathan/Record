//
//  AddMedicalitemProtocol.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
protocol AddMedicalItemRouterProtocol {
    func openSelectVC(options: [String], selected: String, addExtra: Bool, validator: [ValidationRules],onSelect: @escaping (String) -> Void )
    
    func openMultiSelectVC(options: [String], selected: [String], onSelect: @escaping ([String]) -> Void)
}
