//
//  AddMedicalItemPresenter.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//

import UIKit
class AddMedicalItemPresenter: FormFieldPresenter {
    
    var mode: MedicalItemFormMode
    var router: AddMedicalItemRouterProtocol
    let medical: Medical
    let kind: MedicalKind
    var startDate: Date
    
    init(view: FormFieldViewDelegate? = nil, router: AddMedicalItemRouterProtocol,mode: MedicalItemFormMode, medical: Medical, kind: MedicalKind, startDate: Date) {
        self.router = router
        self.mode = mode
        self.medical = medical
        self.kind = kind
        self.startDate = startDate
        super.init(view: view)

    }
    
    override func viewDidLoad() {
        buildFields()
    }
    
    func existing() -> MedicalItem? {
        if case let .edit(medical) = mode {
            return medical
        }
        return nil
    }

    func buildFields() {
        let existing = existing()
        
        fields = [
            FormField(label: "Name", type: .text, validators: [.required,.maxLength(40)], gotoNextField: false, placeholder: "Enter Name", value: existing?.name, returnType: .next),
            FormField(label: "Instruction", type: .select, validators: [.required], gotoNextField: false, value: existing?.instruction.value ?? MedicalInstruction.beforeFood.value),
            FormField(label: "Dosage", type: .text, validators: [.required, .maxLength(40)], gotoNextField: false, placeholder: "Enter Dosage", value: existing?.dosage,returnType: .next),
            FormField(label: "Schedule", type: .select, validators: [.required], gotoNextField: false, value: existing?.shedule.dbValue ?? MedicalSchedule.morning.rawValue)
        ]
        
    }
    
    override var title: String {
        return mode.navigationTitle
    }
    
    override func selectClicked(at index: Int ) {
        let field = field(at: index)
        if index == 1 {
            let options = MedicalInstruction.getList()
            let selected = field.value as? String ?? MedicalInstruction.beforeFood.value
            router.openSelectVC(options: options, selected: selected, addExtra: true) { [weak self] value in
                self?.didSelectOption(at: index,value)
            }
        } else if index == 3 {
            let options = MedicalSchedule.getList()
            let value = field.value as? String ?? MedicalSchedule.morning.rawValue
            let selected = value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            router.openMultiSelectVC(options: options, selected: selected) { [weak self] list in
                self?.didSelectOption(at: index, list.joined(separator: ","))
        }
        
        }

    }
    
    func buildMedicalItem() -> MedicalItem {
        
        let name = field(at: 0).value as? String ?? "Tablet"
        let instruction = field(at: 1).value as? String ?? MedicalInstruction.afterFood.value
        let medicalInstruction = MedicalInstruction.valueOf(instruction)
        let dosage: String = field(at: 2).value as? String ?? "Full"
        let schedule = field(at: 3).value as? String ?? MedicalSchedule.morning.rawValue
        let medicalSchedule: [MedicalSchedule] = .from(dbValue: schedule)
        switch mode {
        case .add:
            return MedicalItem(id: 1, medical: medical.id, kind: kind, name: name, instruction: medicalInstruction, dosage: dosage, startDate: startDate,shedule: medicalSchedule, endDate: medical.endDate)
        case .edit(let medicalItem):
            medicalItem.update(kind: kind, name: name, instruction: medicalInstruction, dosage: dosage, shedule: medicalSchedule, startDate: startDate)
            return medicalItem
        }
    }

    override func didSelectOption(at index: Int,_ value: String) {
        updateValue(value, at: index)
        view?.reloadField(at: index)
    }
    
    override func saveClicked() {
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
}

