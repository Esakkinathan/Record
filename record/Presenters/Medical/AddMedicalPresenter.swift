//
//  AddMedicalPresenter.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//

import UIKit

/*
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
        let durationValue = field(at: 4).value as? String ?? "1"
        let duration = Int(durationValue) ?? 1
        let durationType = field(at: 5).value as? String ?? DurationType.day.rawValue
        let medicalDurationType: DurationType = DurationType(rawValue: durationType) ?? DurationType.day
        switch mode {
        case .add:
            return Medical(id: 1, title: title, type: medicalType, duration: duration, durationType: medicalDurationType,hospital: hospital, doctor: doctor, date: recordDate)
        case .edit(let medical):
            medical.update(title: title, type: medicalType, duration: duration, durationType: medicalDurationType, hospital: hospital,doctor: doctor,date: recordDate)
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
        //view?.reloadData()
    }
}
extension AddMedicalPresenter {
    
}
*/

class AddMedicalPresenter: FormFieldPresenter {
    let router: AddMedicalRouterProtocol
    let mode: MedicalFormMode

    init(view: FormFieldViewDelegate? = nil, router: AddMedicalRouterProtocol, mode: MedicalFormMode) {
        self.router = router
        self.mode = mode
        super.init(view: view)
    }
    
    func existing() -> Medical? {
        if case let .edit(medical) = mode {
            return medical
        }
        return nil
    }
    override func numberOfFields() -> Int {
        return fields.count - 1
    }
    

    func buildFields() {
        let existing = existing()
        
        fields = [
            FormField(label: "Type", type: .select, validators: [.required], gotoNextField: false, value: existing?.type.rawValue ?? MedicalType.checkup.rawValue),
            FormField(label: "Title", type: .text, validators: [.required, .maxLength(30)], gotoNextField: true, placeholder: "Enter Title", value: existing?.title,returnType: .next,),
            FormField(label: "Hospital", type: .text, validators: [.maxLength(30)], gotoNextField: true, placeholder: "Enter Hospital Name", value: existing?.hospital, returnType: .next),
            FormField(label: "Doctor", type: .text, validators: [.maxLength(30)], gotoNextField: false, placeholder: "Enter Doctor Name", value: existing?.doctor, returnType: .done),
            FormField(label: "Recorded At", type: .date, validators: [.required], gotoNextField: false),
            FormField(label: "Duration", type: .textSelect, validators: [.required, .maxValue(30)], gotoNextField: false, placeholder: "Duration", value: existing?.duration != nil ? String(existing!.duration) : nil, returnType: .done, keyboardMode: .numberPad),
            FormField(label: "Duration Type", type: .text, validators: [], gotoNextField: false, value: existing?.durationType.rawValue ?? DurationType.day.rawValue)
        ]
    }
    override var title: String {
        return mode.navigationTitle
    }
    
    override func viewDidLoad() {
        buildFields()
    }
    
    func buildMedical() -> Medical {
        let type = field(at: 0).value as? String ?? MedicalType.defaultValue.rawValue
        let title = field(at: 1).value as? String ?? MedicalType.defaultValue.rawValue
        let medicalType = MedicalType(rawValue: type) ?? MedicalType.defaultValue
        let hospital = field(at: 2).value as? String
        let doctor = field(at: 3).value as? String
        let recordDate = field(at: 4).value as? Date
        let durationValue = field(at: 5).value as? String ?? "1"
        let duration = Int(durationValue) ?? 1
        let durationType = field(at: 6).value as? String ?? DurationType.day.rawValue
        let medicalDurationType: DurationType = DurationType(rawValue: durationType) ?? DurationType.day
        switch mode {
        case .add:
            return Medical(id: 1, title: title, type: medicalType, duration: duration, durationType: medicalDurationType,hospital: hospital, doctor: doctor, date: recordDate)
        case .edit(let medical):
            medical.update(title: title, type: medicalType, duration: duration, durationType: medicalDurationType, hospital: hospital,doctor: doctor,date: recordDate)
            return medical
        }
    }
    override func saveClicked() {
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
    
    override func selectClicked(at index: Int ) {
        let field = field(at: index)
        var options: [String] = []
        var selected: String = ""
        if field.type == .select {
            options = MedicalType.getList()
            selected = field.value as? String ?? MedicalType.defaultValue.rawValue
        } else if field.type == .textSelect {
            let nextField: FormField = super.field(at: index+1)
            
            selected = nextField.value as? String ?? DurationType.day.rawValue
            options = DurationType.getList()
        }
        router.openSelectVC(options: options, selected: selected, addExtra: false) { [weak self] value in
            self?.didSelectOption(at: index,value)
        }

    }
    
    override func didSelectOption(at index: Int,_ value: String) {
        switch index {
        case 0:
            updateValue(value, at: index)
        case 5:
            updateValue(value, at: index+1)
        default:
            print("")
        }
        view?.reloadField(at: index, )
    }

    
}
