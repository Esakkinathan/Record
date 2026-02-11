//
//  ListDocumentPresenter.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//


import Foundation
import CoreGraphics

class ListDocumentPresenter: ListDocumentPresenterProtocol {
        
    weak var view: ListDocumentViewDelegate?
    let router: ListDocumentRouterProtocol
    
    let addUseCase: AddDocumentUseCase
    let updateUseCase: UpdateDocumentUseCase
    let deleteUseCase: DeleteDocumentUseCase
    let fetchUseCase: FetchDocumentsUseCase
    let updateNotesUseCase: UpdateDocumentNotesUseCase
    
    var documentList: [Document] = []
    var filteredDocuments: [Document] = []
    var isSearching = false
    var currentSort: DocumentSortOption
    var visibleDocuments: [Document] = []
    
    
    init(view: ListDocumentViewDelegate,
         router: ListDocumentRouterProtocol,
         addUseCase: AddDocumentUseCase,
         updateUseCase: UpdateDocumentUseCase,
         deleteUseCase: DeleteDocumentUseCase,
         fetchUseCase: FetchDocumentsUseCase,
         updateNotesUseCase: UpdateDocumentNotesUseCase  ) {
        
        self.view = view
        self.router = router
        self.addUseCase = addUseCase
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.fetchUseCase = fetchUseCase
        self.updateNotesUseCase = updateNotesUseCase
        currentSort = DocumentSortStore.load()
        
    }
    
    func viewDidLoad() {
        loadDocuments()
    }
    
    func numberOfRows() -> Int {
        return currentDocuments().count
    }

    
}

extension ListDocumentPresenter {
    func document(at index: Int) -> Document {
        return currentDocuments()[index]
    }
    
    func addDocument(_ document: Document) {
        addUseCase.execute(document: document)
        loadDocuments()
    }

    func updateDocument(document: Document) {
        updateUseCase.execute(document: document)
        loadDocuments()
    }
    
    func deleteDocument(at index: Int) {
        let document = currentDocuments()[index]
        deleteUseCase.execute(id: document.id)
        loadDocuments()
    }
    
        
    func loadDocuments() {
        documentList = fetchUseCase.execute()
        applySort()
    }
    
    func updateNotes(text: String?, id: Int) {
        updateNotesUseCase.execute(text: text,id: id)
        loadDocuments()
    }


}


extension ListDocumentPresenter {
    private func currentDocuments() -> [Document] {
        return isSearching ?  filteredDocuments : visibleDocuments
    }

    
    func search(text: String?) {
        guard let text, !text.isEmpty else {
            isSearching = false
            view?.reloadData()
            return
        }
        
        isSearching = true
        let value = text.prepareSearchWord()
        filteredDocuments = visibleDocuments.filter {
            $0.name.filterForSearch(value) ||
            $0.number.filterForSearch(value)
        }
        view?.reloadData()
    }
    
}

extension ListDocumentPresenter {
    
    func gotoAddDocumentScreen() {
        router.openAddDocumentVC(mode: .add) { [weak self] document in
            self?.addDocument(document)
        }
    }
    
    func shareDocument(at index: Int) {
        let document = document(at: index)
        guard let path = document.file else { return }
        router.openShareDocumentVC(filePath: path)
    }

    
    func didSelectedRow(at index: Int) {
        let document = document(at: index)
        router.openDetailDocumentVC(document: document,onUpdate: { [weak self] updatedDoc in
            self?.updateDocument(document: updatedDoc)
        }, onUpdateNotes: { [weak self] text, id in
            self?.updateNotes(text: text, id: id)
            }
        )
    }
    
    
    func shareDocumentWithLock(at index: Int, password: String) {
        let document = document(at: index)
        guard let path = document.file else { return }
        let lockedUrl = createPasswordProtectedPDF(password: password,sourceURL: URL(filePath: path))
        if let lockedUrlPath = lockedUrl {
            router.openShareDocumentVC(filePath: lockedUrlPath.path)
        }
        
    }

}

extension ListDocumentPresenter {
    
    func didSelectSortField(_ field: DocumentSortField) {
        if currentSort.field == field {
            currentSort = DocumentSortOption(
                field: field,
                direction: currentSort.direction == .ascending ? .descending : .ascending
            )
        } else {
            currentSort = DocumentSortOption(field: field, direction: .ascending)
        }

        DocumentSortStore.save(currentSort)
        applySort()
    }

    
    func applySort() {
        visibleDocuments = documentList
        if currentSort.field == .expiryDate {
            visibleDocuments = visibleDocuments.filter { $0.expiryDate != nil }
        }
        visibleDocuments.sort(by: { (lhs: Document, rhs: Document) -> Bool in
            switch currentSort.field {

            case .name:
                if currentSort.direction == .ascending {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                } else {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedDescending
                }

            case .createdAt:
                if currentSort.direction == .ascending {
                    return lhs.createdAt > rhs.createdAt
                } else {
                    return lhs.createdAt < rhs.createdAt
                }

            case .updatedAt:
                if currentSort.direction == .ascending {
                    return lhs.lastModified > rhs.lastModified
                } else {
                    return lhs.lastModified < rhs.lastModified
                }

            case .expiryDate:
                let lhsDate = lhs.expiryDate ?? .distantFuture
                let rhsDate = rhs.expiryDate ?? .distantFuture

                if currentSort.direction == .ascending {
                    return lhsDate < rhsDate
                } else {
                    return lhsDate > rhsDate
                }
            }
        })

        view?.refreshSortMenu()
        view?.reloadData()

    }

}

extension ListDocumentPresenter {
    func createPasswordProtectedPDF(password: String, sourceURL: URL) -> URL? {
        let lockedFileName = "Locked-\(sourceURL.lastPathComponent)"
        let lockedURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(lockedFileName)

        if FileManager.default.fileExists(atPath: lockedURL.path) {
            return lockedURL
        }

        guard let sourcePDF = CGPDFDocument(sourceURL as CFURL) else {
            return nil
        }

        let pdfData = NSMutableData()

        let options: [CFString: Any] = [
            kCGPDFContextUserPassword: password,
            kCGPDFContextOwnerPassword: password,
            kCGPDFContextEncryptionKeyLength: 128
        ]

        guard let consumer = CGDataConsumer(data: pdfData as CFMutableData),
              let context = CGContext(
                consumer: consumer,
                mediaBox: nil,
                options as CFDictionary
              )
        else { return nil }

        for pageNumber in 1...sourcePDF.numberOfPages {
            guard let page = sourcePDF.page(at: pageNumber) else { continue }
            var mediaBox = page.getBoxRect(.mediaBox)
            context.beginPage(mediaBox: &mediaBox)
            context.drawPDFPage(page)
            context.endPage()
        }

        context.closePDF()
        pdfData.write(to: lockedURL, atomically: true)

        return lockedURL
    }

    func getDocumentById(_ id: Int) -> Document? {
        loadDocuments()
        var doc: Document?
        for document in documentList {
            if document.id == id {
                doc = document
            }
        }
        return doc
    }

}
