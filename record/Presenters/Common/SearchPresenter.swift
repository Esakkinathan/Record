//
//  SearchPresenter.swift
//  record
//
//  Created by Esakkinathan B on 20/02/26.
//
import Foundation

protocol SelectionPresenterProtocol {
    func numberOfFields() -> Int
    func field(at index: Int) -> String
    var addExtra: Bool { get }
    var title: String { get }
    var selectedOption: String { get }
    func search(text: String?)
    func didSelectRow(at index: Int)
    func clickedAddOption(text: String)
    var isEmpty: Bool { get }
    func validateText(enteredText: String?)
    var maxCount: Int { get }
}
protocol SearchViewDelegate: AnyObject {
    func selectedData(text: String)
    func dismiss()
    func reloadData()
    func showAddOptionAlert(_ value: String)
    func showToastVC(message: String, type: ToastType)
}
class SelectionPresenter: SelectionPresenterProtocol {
    
    weak var view: SearchViewDelegate?
    private let options: [String]
    var selectedOption: String
    var addExtra: Bool
    var isSearching = false
    var visibleRecords: [String] = []
    var maxCount: Int {
        for rule in validators {
            switch rule {
            case .maxLength(let value):
                return value
            case .exactLength(let value):
                return value
            default:
                return 30
            }
        }
        return 30
    }
    var isEmpty: Bool {
        current().isEmpty
    }
    let validators: [ValidationRules]
    var title: String {
        "Select Option"
    }
    
    init(view: SearchViewDelegate? = nil, options: [String], selectedOption: String, addExtra: Bool = true, validators: [ValidationRules]) {
        self.view = view
        self.options = options
        self.selectedOption = selectedOption
        self.addExtra = addExtra
        self.validators = validators
    }
    
    
    func numberOfFields() -> Int {
        return  current().count
    }
    func field(at index: Int) -> String {
        return current()[index]
    }
    
    func current() -> [String] {
        return isSearching ? visibleRecords : options
    }
    
    func clickedAddOption(text: String = "" ) {
        view?.showAddOptionAlert(text)
    }

    func search(text: String?) {
        guard let text, !text.isEmpty else {
            isSearching = false
            view?.reloadData()
            return
        }
        
        isSearching = true
        let value = text.prepareSearchWord()
        visibleRecords = options.filter {
            $0.filterForSearch(value) ||
            $0.filterForSearch(value)
        }
        view?.reloadData()
    }
    
    func validateText(enteredText: String?) {
        guard let enteredText = enteredText else {
            view?.showToastVC(message: "Add Option", type: .error)
            self.clickedAddOption()
            return
        }
        
        let result = Validator.Validate(input: enteredText, rules: validators)
        if result.isValid {
            view?.selectedData(text: enteredText)
            return
        }
        view?.showToastVC(message: result.errorMessage ?? "Some error in entered text", type: .error)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.clickedAddOption(text: enteredText)
        }

    }
//        if enteredText.isEmpty {
//            view?.showToastVC(message: "Add Option", type: .error)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.clickedAddOption()
//            }
//            return
//
//        }
//        if enteredText.count < 1 || enteredText.count > maxCount {
//            view?.showToastVC(message: "Length Should be 1 to \(maxCount)", type: .error)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.clickedAddOption(text: enteredText)
//            }
//            return
//        }
//        
//
//    }
    
    func didSelectRow(at index: Int) {
        let selected = field(at: index)
        if selected != selectedOption {
            selectedOption = selected
            view?.selectedData(text: selectedOption)
        }
        view?.dismiss()
    }
    
}
