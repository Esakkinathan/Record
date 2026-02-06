//
//  ListDocumentPresenter.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//


import Foundation

class ListDocumentPresenter: ListDocumentProtocol {
    
    
    weak var view: ListDocumentViewDelegate?
    
    var documentList: [[Document]] = []
    private var filteredDocuments: [Document] = []
    private var selectedSegmentIndex = 0
    private var isSearching = false
    
    init(view: ListDocumentViewDelegate) {
        self.view = view
        documentList = fetchDocumentList()
    }
    
    func segmentChange(index: Int) {
        selectedSegmentIndex = index
        isSearching = false
        filteredDocuments.removeAll()
        view?.reloadData()
    }
    
    func numberOfRows() -> Int {
        return currentDocuments().count
    }

    func document(at index: Int) -> Document {
        return currentDocuments()[index]
    }
    
    func addDocument(_ document: Document) {
        documentList[selectedSegmentIndex].append(document)
        view?.reloadData()
    }

    func updateDocument(at index: Int, document: Document) {
        documentList[selectedSegmentIndex][index] = document
        view?.reloadData()

    }
    
    func deleteDocument(at index: Int) {
        documentList[selectedSegmentIndex].remove(at: index)
        view?.reloadData()
    }
    
    
    private func fetchDocumentList() -> [[Document]] {
        return [
            [Document(id: 1, name: "Adhar Card", number: "228861826825",expiryDate: nil ,file: nil, type: .Default)],
            [Document(id: 1, name: "Marriage Certificate", number: "TnMrgerg-2345sdfg",expiryDate: Date() ,file: nil, type: .Custom)]
        ]
    }
    
    private func currentDocuments() -> [Document]{
        return isSearching ?  filteredDocuments : documentList[selectedSegmentIndex]
    }
    
    func shareDocument(at index: Int) {
        let document = document(at: index)
        if let path = document.file {
            view?.shareDocument(url: URL(filePath: path))
        }
        
    }

}
