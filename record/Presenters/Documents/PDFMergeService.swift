//
//  PDFMergeService.swift
//  record
//
//  Created by Esakkinathan B on 23/02/26.
//
import Foundation
import PDFKit

enum PDFMergeError: LocalizedError {
    
    static let maxFiles = 10
    case emptyInput
    case moreThanAllowed
    case invalidPDF
    case failedToGenerateData
    
    var errorDescription: String? {
        switch self {
        case .emptyInput:
            return "No PDF files selected."
            
        case .moreThanAllowed:
            return "You can merge only up to 5 PDF files."
            
        case .invalidPDF:
            return "One of the selected files is not a valid PDF."
            
        case .failedToGenerateData:
            return "Unable to create merged PDF."
        }
    }
}


final class PDFMergerService {
    
    
    func mergePDFs(from urls: [URL]) throws -> Data {
        
        guard !urls.isEmpty else {
            throw PDFMergeError.emptyInput
        }
        
        guard urls.count <= PDFMergeError.maxFiles else {
            throw PDFMergeError.moreThanAllowed
        }
        
        let mergedDocument = PDFDocument()
        var pageIndex = 0
        
        for url in urls {
            guard let document = PDFDocument(url: url) else {
                throw PDFMergeError.invalidPDF
            }
            
            for i in 0..<document.pageCount {
                if let page = document.page(at: i) {
                    mergedDocument.insert(page, at: pageIndex)
                    pageIndex += 1
                }
            }
        }
        
        guard let data = mergedDocument.dataRepresentation() else {
            throw PDFMergeError.failedToGenerateData
        }
        
        return data
    }
}

