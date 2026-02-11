//
//  AddMedicalPresenter.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//

import UIKit
class AddMedicalPresenter: AddMedicalPresenterProtocol {
    
    
    weak var view: AddMedicalViewDelegate?
    let router: AddMedicalRouterProtocol
    let mode: MedicalFormMode
    var fields: [MedicalFormField] = []
    
    init(view: AddMedicalViewDelegate? = nil, router: AddMedicalRouterProtocol, mode: MedicalFormMode) {
        self.view = view
        self.router = router
        self.mode = mode
        buildFields()
    }
    var title: String {
        return mode.navigationTitle
    }
    
    
}

extension AddMedicalPresenter {
    func buildFields() {
        let existing = existingMedical()
        fields = [
            MedicalFormField(label: "Type", placeholder: nil, type: .type, validators: [.required], value: existing?.type.rawValue ?? MedicalType.defaultValue.rawValue, returnType: .next, keyboardMode: .default),
            MedicalFormField(label: "Title", placeholder: "Enter Title", type: .title, validators: [.required,.maxLength(20)], value: existing?.title, returnType: .next, keyboardMode: .default),
            MedicalFormField(label: "Hospital", placeholder: "Enter Hospital Name", type: .hospital, validators: [.maxLength(30)], value: existing?.hospital, returnType: .next, keyboardMode: .default),
            MedicalFormField(label: "Doctor", placeholder: "Enter Doctor Name", type: .doctor, validators: [.maxLength(20)], returnType: .next, keyboardMode: .default),
            MedicalFormField(label: "Recorded At", placeholder: nil, type: .date, validators: [], returnType: .done, keyboardMode: .default)
        ]
    }
    
    func existingMedical() -> Medical? {
        if case let .edit(medical) = mode {
            return medical
        }
        return nil
    }

}
extension AddMedicalPresenter {
    func saveClicked() {
        if validateFields() {
            let medical = buildMedical()

            switch mode {
            case .add:
                view?.onAdd?(medical)
            case .edit:
                view?.onEdit?(medical)
            }
            view?.dismiss()
        }
    }
    
    func buildMedical() -> Medical {
        let type = field(at: 0).value as? String ?? MedicalType.defaultValue.rawValue
        let title = field(at: 1).value as? String ?? MedicalType.defaultValue.rawValue
        let medicalType = MedicalType(rawValue: type) ?? MedicalType.defaultValue
        let hospital = field(at: 2).value as? String
        let doctor = field(at: 3).value as? String
        let recordDate = field(at: 4).value as? Date
        
        switch mode {
        case .add:
            return Medical(id: 1, title: title, type: medicalType, hospital: hospital, doctor: doctor, date: recordDate)
        case .edit(let medical):
            medical.update(title: title, type: medicalType,hospital: hospital,doctor: doctor,date: recordDate)
            return medical
        }
    }

    

}

extension AddMedicalPresenter {
    func validateText(text: String, index: Int,rules: [ValidationRules] = []) -> ValidationResult {
        let result = Validator.Validate(input: text, rules: rules)
        if result.isValid {
            updateValue(text, at: index)
        }
        return result
    }

    func validateFields() -> Bool{
        for field in fields {
            let result = Validator.Validate(input: field.value as? String ?? "" , rules: field.validators)
            if !result.isValid {
                view?.showError(result.errorMessage)
                return result.isValid
            }
        }
        return true
    }
}

extension AddMedicalPresenter {
    func numberOfFields() -> Int {
        return fields.count
    }
    
    func field(at index: Int) -> MedicalFormField {
        return fields[index]
    }
    
    func updateValue(_ value: Any?, at index: Int) {
        fields[index].value = value
    }

}
extension AddMedicalPresenter {
    func cancelClicked() {
        view?.dismiss()
    }
    func selectClicked(at index: Int) {
        let field = fields[index]
        let options = MedicalType.getList()
        let selected = field.value as? String ?? MedicalType.defaultValue.rawValue

        router.openSelectVC(options: options, selected: selected) { [weak self] value in
                self?.didSelectOption(value)
        }

    }
    func didSelectOption(_ value: String) {
        fields[0].value = value
        view?.reloadField(at: 0)
        //buildFields()
        view?.reloadData()
    }
}
extension AddMedicalPresenter {
    
}
