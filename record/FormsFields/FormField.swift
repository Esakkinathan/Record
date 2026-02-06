//
//  FormField.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

struct DocumentFormField {
    let label: String
    let placeholder: String?
    let type: DocumentFormFieldType
    let validators: [ValidationRules]
    var value: Any?
}
