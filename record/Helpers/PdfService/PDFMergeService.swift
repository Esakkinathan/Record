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
        
        let outputData = NSMutableData()
        
        guard let consumer = CGDataConsumer(data: outputData as CFMutableData),
              let context = CGContext(consumer: consumer, mediaBox: nil, nil) else {
            throw PDFMergeError.failedToGenerateData
        }
        
        for url in urls {
            guard let pdf = CGPDFDocument(url as CFURL) else {
                throw PDFMergeError.invalidPDF
            }
            
            for pageNumber in 1...pdf.numberOfPages {
                guard let page = pdf.page(at: pageNumber) else { continue }
                
                var mediaBox = page.getBoxRect(.mediaBox)
                context.beginPage(mediaBox: &mediaBox)
                context.drawPDFPage(page)
                context.endPage()
            }
        }
        
        context.closePDF()
        
        return outputData as Data
    }
    
}

