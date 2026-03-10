//
//  ListDocumentPresenter.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//


import Foundation
import CoreGraphics
import UIKit

class ListDocumentPresenter: ListDocumentPresenterProtocol {
        
    weak var view: ListDocumentViewDelegate?
    let router: ListDocumentRouterProtocol
    
    let addUseCase: AddDocumentUseCaseProtocol
    let updateUseCase: UpdateDocumentUseCaseProtocol
    let deleteUseCase: DeleteDocumentUseCaseProtocol
    let fetchUseCase: FetchDocumentsUseCaseProtocol
    var documentList: [Document] = []
    var filteredDocuments: [Document] = []
    var isSearching = false
    var isEmpty: Bool {
        documentList.isEmpty
    }
    var currentSort: DocumentSortOption
    
    private var limit = 20
    private var offset = 0
    private var isLoading = false
    private var hasMoreData = true
    
    var searchText: String?
    
    init(view: ListDocumentViewDelegate,
         router: ListDocumentRouterProtocol,
         addUseCase: AddDocumentUseCaseProtocol,
         updateUseCase: UpdateDocumentUseCaseProtocol,
         deleteUseCase: DeleteDocumentUseCaseProtocol,
         fetchUseCase: FetchDocumentsUseCaseProtocol) {
        
        self.view = view
        self.router = router
        self.addUseCase = addUseCase
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.fetchUseCase = fetchUseCase
        currentSort = DocumentSortStore.load()
        
    }
    
    func viewDidLoad() {
        loadDocuments()
        
    }
    
    func numberOfRows() -> Int {
        return documentList.count
    }
}

extension ListDocumentPresenter {
    func document(at index: Int) -> Document {
        return documentList[index]
    }
    func addDocument(_ document: Document) {
        addUseCase.execute(document: document)
        loadDocuments()
    }
    func updateDocument(_ document: Document) {
        updateUseCase.execute(document: document)
        loadDocuments()
    }
    func deleteDocument(_ document: Document) {
        deleteUseCase.execute(id: document.id)
        if let file = document.file {
            AppFileManager().removeFile(name: file, type: .docs)
        }
        NotificationManager.shared.removeRemainderNotification(documentId: document.id,remainderId: 1)
        NotificationManager.shared.removeRemainderNotification(documentId: document.id,remainderId: 2)
        NotificationManager.shared.removeRemainderNotification(documentId: document.id,remainderId: 3)
        loadDocuments()
        view?.showToastVC(message: "Data deleted successfully", type: .success)
    }
    func deleteDocument(at index: Int) {
        let document = document(at: index)
        if document.isRestricted {
            DeviceAuthenticationService.shared.authenticate(onSuccess: { [weak self] in
                self?.deleteDocument(document)
            },onFailure: { [weak self] error in
                self?.handleAuthError(error: error)
            })

        } else {
            deleteDocument(document)
        }
    }
    
    func loadDocuments(reset: Bool = true) {
        if reset {
            offset = 0
            hasMoreData = true
            documentList.removeAll()
        }
        guard !isLoading, hasMoreData else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let result = fetchUseCase.execute(limit: limit, offset: offset, sort: currentSort, searchText: isSearching ? searchText : nil)
            if result.count < limit {
                hasMoreData = false
            }
            documentList.append(contentsOf: result)
            offset += result.count
            isLoading = false
            view?.refreshSortMenu()
            view?.reloadData()
        }
    }
        
    func toggleRestricterd(_ document: Document) {
        document.toggleFavorite()
        updateUseCase.toggleRestricted(document: document)
        view?.reloadData()
    }
}


extension ListDocumentPresenter {

    func search(text: String?) {
        searchText = text
        isSearching = !(text?.isEmpty ?? true)
        loadDocuments(reset: true)
        
    }
}

extension ListDocumentPresenter {
    
    func gotoAddDocumentScreen() {
        router.openAddDocumentVC(mode: .add) { [weak self] document in
            self?.addDocument(document as! Document)
            self?.view?.showToastVC(message: "Data added successfully", type: .success)
        }
    }
    
    func shareDocument(at index: Int) {
        let document = document(at: index)
        guard let path = document.file, let filePath = DocumentThumbnailProvider.fullURL(from: path) else { return }
        router.openShareDocumentVC(filePath: filePath)
    }

    func openDetailDocumentScreen(_ document: Document) {
        router.openDetailDocumentVC(document: document)
    }
    
    func didSelectedRow(at index: Int) {
        let document = document(at: index)
        if document.isRestricted {
            DeviceAuthenticationService.shared.authenticate(onSuccess: { [weak self] in
                self?.openDetailDocumentScreen(document)
            },onFailure: { [weak self] error in
                self?.handleAuthError(error: error)
            })
        } else {
            openDetailDocumentScreen(document)
        }
    }
    
    func shareDocumentWithLock(at index: Int, password: String) {
        let document = document(at: index)
        guard let path = document.file, let filePath = DocumentThumbnailProvider.fullURL(from: path) else { return }
        let lockedUrl = LockFileGenerator().createPasswordProtectedPDF(password: password,sourceURL: URL(filePath: filePath))
        if let lockedUrlPath = lockedUrl {
            router.openShareDocumentVC(filePath: lockedUrlPath.path)
        }
    }
    
    func deleteClicked(at index: Int) {
        view?.showAlertOnDelete(at: index)
    }
    
    func handleAuthError(error: AuthenticationError) {
        switch error {
        case .permissionDenied:
            view?.showToastVC(message: "Enable Face ID in Settings", type: .error)
        case .notAvailable:
            view?.showToastVC(message: "No lock screen set up on this device", type: .error)
        default:
            view?.showToastVC(message: "Authentication failed", type: .error)
        }
    }
}

extension ListDocumentPresenter {
    
    func updateSortLogic(field: DocumentSortField) {
        if currentSort.field == field {
            currentSort = DocumentSortOption(
                field: field,
                direction: currentSort.direction == .ascending ? .descending : .ascending
            )
        } else {
            currentSort = DocumentSortOption(field: field, direction: .ascending)
        }
        DocumentSortStore.save(currentSort)
    }
    
    func didSelectSortField(_ fields: DocumentSortField) {
        updateSortLogic(field: fields)
        loadDocuments(reset: true)
    }
    
}

extension ListDocumentPresenter {
    
    func validatePassword(_ password1: String, _ password2: String, at index: Int) {
        
        if password1.isEmpty || password2.isEmpty {
            view?.showToastVC(message: "Enter Password", type: .error)
            return
        }
        
        if password1 != password2 {
            view?.showToastVC(message: "Password does not match", type: .error)
        }
        
        if password1.count > 8 || password1.count < 4 {
            view?.showToastVC(message: "Password length between 4 to 8", type: .error)
        }
        shareDocumentWithLock(at: index, password: password1)
        
        
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
    
    func toggleClicked(at index: Int) {
        let document = document(at: index)
        DeviceAuthenticationService.shared.authenticate(onSuccess: { [weak self] in
            self?.toggleRestricterd(document)
        },onFailure: { [weak self] error in
            self?.handleAuthError(error: error)
        })
        
    }
    func shareButtonClicked(_ indexPath: IndexPath) {
        if document(at: indexPath.row).isRestricted {
            DeviceAuthenticationService.shared.authenticate(onSuccess: { [weak self] in
                self?.view?.showAlertOnShare(indexPath)
            },onFailure: { [weak self] error in
                self?.handleAuthError(error: error)
            })
        } else {
            view?.showAlertOnShare(indexPath)
        }
    }

}
