//
//  AddMedicalItemPresenter.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//


import UIKit
class AddMedicalItemPresenter: AddMedicalItemPresenterProtocol {
    
    weak var view: AddMedicalItemViewDelegate?
    let router: AddMedicalItemRouterProtocol
    let mode: MedicalItemFormMode
    var fields: [MedicalItemFormField] = []
        
    var title: String {
        return mode.navigationTitle
    }
    
    let medicalId: Int
    let kind: MedicalKind

    init(view: AddMedicalItemViewDelegate? = nil, router: AddMedicalItemRouterProtocol,mode: MedicalItemFormMode, medicalId: Int, kind: MedicalKind ) {
        self.view = view
        self.router = router
        self.mode = mode
        self.medicalId = medicalId
        self.kind = kind
        
        buildFields()
    }
    
}


extension AddMedicalItemPresenter {
    func buildFields() {
        let existing = existingMedical()
        fields = [
            
            MedicalItemFormField(label: "Name", placeholder: "Enter Name", type: .name, validators: [.required, .maxLength(30)], value: existing?.name, returnType: .next, keyboardMode: .default),
            
            MedicalItemFormField(label: "Instruction", placeholder: nil, type: .instruction, validators: [.required, .maxLength(30)], value: existing?.instruction.value ?? MedicalInstruction.beforeFood.value, returnType: .next, keyboardMode: .default),
            
            MedicalItemFormField(label: "Dosage", placeholder: "Enter Dosage", type: .dosage, validators: [.required,], value: existing?.dosage, returnType: .next, keyboardMode: .default),
            
            MedicalItemFormField(label: "Schedules", placeholder: nil, type: .schedule, validators: [.required,], value: existing?.shedule.dbValue ?? MedicalSchedule.morning.rawValue, returnType: .next, keyboardMode: .default),
            
            MedicalItemFormField(label: "Duration", placeholder: "Enter Duration", type: .duration, validators: [.required,.numeric,.maxValue(30),.minValue(1)], value: existing?.duration != nil ? String(existing!.duration) : nil , returnType: .done, keyboardMode: .numberPad),
            
            MedicalItemFormField(label: "Duration Type", placeholder: nil, type: .duration, validators: [], value: existing?.durationType.rawValue ?? DurationType.day.rawValue, returnType: .done, keyboardMode: .default)
        ]
    }
    
    func existingMedical() -> MedicalItem? {
        if case let .edit(medicalItem) = mode {
            return medicalItem
        }
        return nil
    }

}


extension AddMedicalItemPresenter {
    func saveClicked() {
        if validateFields() {
            let medicalItem = buildMedicalItem()
            
            switch mode {
            case .add:
                view?.onAdd?(medicalItem)
            case .edit:
                view?.onEdit?(medicalItem)
            }
            view?.dismiss()
        }
    }
    func buildMedicalItem() -> MedicalItem {
        
        
        let name = field(at: 0).value as? String ?? "Tablet"
        let instruction = field(at: 1).value as? String ?? MedicalInstruction.afterFood.value
        let medicalInstruction = MedicalInstruction.valueOf(instruction)
        let dosage: String = field(at: 2).value as? String ?? "Full"
        let schedule = field(at: 3).value as? String ?? MedicalSchedule.morning.rawValue
        let medicalSchedule: [MedicalSchedule] = .from(dbValue: schedule)
        let durationValue = field(at: 4).value as? String ?? "1"
        let duration = Int(durationValue) ?? 1
        let durationType = field(at: 5).value as? String ?? DurationType.day.rawValue
        let medicalDurationType: DurationType = DurationType(rawValue: durationType) ?? DurationType.day
        switch mode {
        case .add:
            return MedicalItem(id: 1, medical: medicalId, kind: kind, name: name, instruction: medicalInstruction, dosage: dosage, shedule: medicalSchedule, duration: duration, durationType: medicalDurationType)
        case .edit(let medicalItem):
            medicalItem.update(kind: kind, name: name, instruction: medicalInstruction, dosage: dosage, shedule: medicalSchedule, duration: duration, durationType: medicalDurationType)
            return medicalItem
        }
    }
    
}

extension AddMedicalItemPresenter {
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

extension AddMedicalItemPresenter {
    func numberOfFields() -> Int {
        return fields.count - 1
    }
    
    func field(at index: Int) -> MedicalItemFormField {
        return fields[index]
    }
    
    func updateValue(_ value: Any?, at index: Int) {
        fields[index].value = value
    }

}
extension AddMedicalItemPresenter {
    func cancelClicked() {
        view?.dismiss()
    }
    func instructionOptionSelected(at index: Int) {
        let field = fields[index]
        let options = MedicalInstruction.getList()
        let selected = field.value as? String ?? MedicalInstruction.beforeFood.value

        router.openSelectVC(options: options, selected: selected) { [weak self] value in
                self?.didSelectInstructionOption(index, value)
        }

    }
    func didSelectInstructionOption(_ index: Int, _ value: String) {
        fields[index].value = value
        view?.reloadField(at: index)
    }
    
    func scheduleOptionSelected(at index: Int) {
        let field = fields[index]
        let options = MedicalSchedule.allCases.map{ $0.rawValue }
        let selected = field.value as? String ?? MedicalSchedule.morning.rawValue
        let selectedList: [String] = selected
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        router.openMultiSelectVC(options: options, selected: selectedList) { [weak self] value in
                self?.didSelectScheduleOption(index, value)
        }
    
    }
    func didSelectScheduleOption(_ index: Int, _ value: [String]) {
        let schedule = value.joined(separator: ",")
        fields[index].value = schedule
        view?.reloadField(at: index)
    }

    
}

