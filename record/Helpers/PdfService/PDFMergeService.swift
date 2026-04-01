//
//  PDFMergeService.swift
//  record
//
//  Created by Esakkinathan B on 23/02/26.
//
import Foundation
import PDFKit

//enum PDFMergeError: LocalizedError {
//    
//    static let maxFiles = 10
//    case emptyInput
//    case moreThanAllowed
//    case invalidPDF
//    case failedToGenerateData
//    
//    var errorDescription: String? {
//        switch self {
//        case .emptyInput:
//            return "No PDF files selected."
//            
//        case .moreThanAllowed:
//            return "You can merge only up to 5 PDF files."
//            
//        case .invalidPDF:
//            return "One of the selected files is not a valid PDF."
//            
//        case .failedToGenerateData:
//            return "Unable to create merged PDF."
//        }
//    }
//}
class PDFMergerService {
    
    func validateFileSize(fileURL: URL) throws {
        let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
        
        if let fileSize = resourceValues.fileSize {
            if fileSize > AppConstantData.maxFileSize {
                throw PDFMergeError.fileTooLarge
            }
        }
    }
    enum PDFMergeError: LocalizedError {
        case emptyInput
        case invalidPDF
        case failedToGenerateData
        case passwordRequired
        case wrongPassword
        case moreThanAllowed
        case tooHuge
        case fileTooLarge
        
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
                
            case .wrongPassword:
                return "Pasword is wrong, cancelling the operation"
            case .passwordRequired:
                return "The document you have upload required password"
            case .tooHuge:
                return "Maximum \(AppConstantData.maxPdfPage) pages allowed in a document. Please try again."
            case .fileTooLarge:
                return "File is larger than 20 MB. Please try again"
            }
        }
        
    }
    
    func mergePDFs(
        from urls: [URL],
        passwordProvider: ((URL) async -> String?)?
    ) async throws -> Data? {
        
        guard !urls.isEmpty else {
            throw PDFMergeError.emptyInput
        }
        
        let outputData = NSMutableData()
        
        guard let consumer = CGDataConsumer(data: outputData as CFMutableData),
              let context = CGContext(consumer: consumer, mediaBox: nil, nil) else {
            throw PDFMergeError.failedToGenerateData
        }
        
        var addedPages = false
        
        for url in urls {

            try validateFileSize(fileURL: url)
            
            let access = url.startAccessingSecurityScopedResource()
            defer {
                if access { url.stopAccessingSecurityScopedResource() }
            }

            guard let pdf = CGPDFDocument(url as CFURL) else {
                throw PDFMergeError.invalidPDF
            }

            if pdf.isEncrypted {

                guard let passwordProvider else {
                    throw PDFMergeError.passwordRequired
                }

                let password = await passwordProvider(url)

                // user cancelled
                guard let password else {
                    continue
                }

                if !pdf.unlockWithPassword(password) {
                    throw PDFMergeError.wrongPassword
                }
            }
            guard pdf.numberOfPages <= AppConstantData.maxPdfPage else {
                throw PDFMergeError.tooHuge
            }

            for pageNumber in 1...pdf.numberOfPages {
                guard let page = pdf.page(at: pageNumber) else { continue }

                var mediaBox = page.getBoxRect(.mediaBox)
                context.beginPage(mediaBox: &mediaBox)
                context.drawPDFPage(page)
                context.endPage()

                addedPages = true
            }
        }
        context.closePDF()
        
        if !addedPages {
            return nil
        }
        
        return outputData as Data
    }
}
/*
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

*/
