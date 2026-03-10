//
//  LockFileGenerator.swift
//  record
//
//  Created by Esakkinathan B on 04/03/26.
//
import PDFKit

class LockFileGenerator {
    func createPasswordProtectedPDF(password: String, sourceURL: URL) -> URL? {
        let lockedFileName = "Locked-\(sourceURL.lastPathComponent)"
        let lockedURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(lockedFileName)

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

}
