//
//  PdfCompressService.swift
//  record
//
//  Created by Esakkinathan B on 02/03/26.
//

import PDFKit
import UIKit

final class PDFCompressor {
    
    func compress(inputURL: URL) -> URL? {
        
        let compressionLevel = SettingsManager.shared.compressionLevel
        
        guard let pdfDocument = PDFDocument(url: inputURL) else {
            return nil
        }
        
        let compressedURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".pdf")
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        
        do {
            try renderer.writePDF(to: compressedURL) { context in
                
                for pageIndex in 0..<pdfDocument.pageCount {
                    guard let page = pdfDocument.page(at: pageIndex) else { continue }
                    
                    context.beginPage()
                    
                    let pageBounds = page.bounds(for: .mediaBox)
                    
                    let quality: CGFloat = compressionLevel.value
                                        
                    let pageImage = page.thumbnail(of: pageBounds.size, for: .mediaBox)
                    
                    if let jpegData = pageImage.jpegData(compressionQuality: quality),
                       let compressedImage = UIImage(data: jpegData) {
                        
                        compressedImage.draw(in: pageBounds)
                    }
                }
            }
            return compressedURL
            
        } catch {
            print("Compression error:", error)
            return nil
        }
    }
}
