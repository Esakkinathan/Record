//
//  SearchPresenter.swift
//  record
//
//  Created by Esakkinathan B on 20/02/26.
//

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
}
protocol SearchViewDelegate: AnyObject {
    func selectedData(text: String)
    func dismiss()
    func reloadData()
    func showAddOptionAlert(_ value: String)
}
class SelectionPresenter: SelectionPresenterProtocol {
    
    weak var view: SearchViewDelegate?
    private let options: [String]
    var selectedOption: String
    var addExtra: Bool
    var isSearching = false
    var visibleRecords: [String] = []
    var isEmpty: Bool {
        current().isEmpty
    }
    var title: String {
        "Select Option"
    }
    
    init(view: SearchViewDelegate? = nil, options: [String], selectedOption: String, addExtra: Bool = true) {
        self.view = view
        self.options = options
        self.selectedOption = selectedOption
        self.addExtra = addExtra
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
    
    func didSelectRow(at index: Int) {
        let selected = field(at: index)
        if selected != selectedOption {
            selectedOption = selected
            view?.selectedData(text: selectedOption)
        }
        view?.dismiss()
    }
    
}
