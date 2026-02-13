//
//  AddBillPresenter.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//
import UIKit

class AddBillPresenter: FormFieldPresenterProtocol {
    weak var view: FormFieldViewDelegate?
    
    let mode: BillFormMode
    let utilityAccountId: Int
    var fields: [FormField] = []
    var billType: BillType
    init(view: FormFieldViewDelegate? = nil, mode: BillFormMode, utilityAccountId: Int, billType: BillType) {
        self.view = view
        self.mode = mode
        self.utilityAccountId = utilityAccountId
        self.billType = billType
    }
    
    var title: String {
        mode.title(type: billType)
    }
    
    func buildFields() {
        let existing = existingBill()
        fields = []
        fields.append(FormField(label: "Amount", placeholder: "Enter Amount", type: .text, validators: [.required, .numeric, .maxValue(100000000000)], gotoNextField: false, value: existing?.amount != nil ? String(existing!.amount) : nil, returnType: .next, keyboardMode: .numberPad))
        switch billType {
        case .ongoing:
            fields.append(FormField(label: "Due Date", placeholder: nil, type: .date, validators: [.required], gotoNextField: false))
        case .completed:
            fields.append(FormField(label: "Due Date", placeholder: nil, type: .date, validators: [], gotoNextField: false))
            fields.append(FormField(label: "Paid Date", placeholder: nil, type: .date, validators: [.required], gotoNextField: false))
        }
        
        fields.append(FormField(label: "Notes", placeholder: nil, type: .textView, validators: [.maxLength(100)], gotoNextField: false, value: existing?.notes))
        
    }
    
    func existingBill() -> Bill? {
        if case let .edit(bill) = mode {
            return bill
        }
        return nil
    }


    func field(at index: Int) -> FormField {
        return fields[index]
    }
    
    func numberOfFields() -> Int {
        fields.count
    }
    
    func updateValue(_ value: Any?, at index: Int) {
        fields[index].value = value
    }
    
    func viewDidLoad() {
        buildFields()
    }
    
    func validateText(text: String, index: Int, rules: [ValidationRules]) -> ValidationResult {
        let result = Validator.Validate(input: text, rules: rules)
        if result.isValid {
            updateValue(text, at: index)
        }
        return result

    }
    
    func cancelClicked() {
        view?.dismiss()
    }
    
    func validateFields() -> Bool {
         
        for field in fields {
            var input = field.value as? String ?? (field.value as? Date)?.toString()
            let result = Validator.Validate(input: input, rules: field.validators)
            if !result.isValid {
                view?.showError(result.errorMessage)
                return result.isValid
            }
        }
        return true
    }

    func saveClicked() {
        if validateFields() {
            let bill = buildBill()
            
            switch mode {
            case .add:
                view?.onAdd?(bill)
            case .edit:
                view?.onEdit?(bill)
            }
            view?.dismiss()
        }

    }
    func buildBill() -> Bill {
        let amount = field(at: 0).value as? String ?? "1"
        let billAmount = Double(amount) ?? 1
        let notes = fields.last?.value as? String
        let dueDate: Date?
        var paidDate: Date?
        switch billType {
        case .ongoing:
            dueDate = field(at: 1).value as? Date
        case .completed:
            dueDate = field(at: 1).value as? Date
            paidDate = field(at: 2).value as? Date
        }
        
        switch mode {
        case .add:
            return Bill(id: 1, utilityAccountId: utilityAccountId, amount: billAmount, billType: billType, dueDate: dueDate, paidDate: paidDate, notes: notes)
        case .edit(let bill):
            bill.update(amount: billAmount, dueDate: dueDate, paidDate: paidDate, notes: notes)
            return bill
        }
    }

    


}
