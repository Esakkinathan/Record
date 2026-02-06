//
//  ListDocumentProtocol.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

protocol ListDocumentProtocol {
    func numberOfRows() -> Int
    func document(at index: Int)  -> Document
    func segmentChange(index: Int)
    func addDocument(_ document: Document)
    func updateDocument(at index: Int, document: Document)
    func deleteDocument(at index: Int)
    func shareDocument(at index: Int)
    
}

