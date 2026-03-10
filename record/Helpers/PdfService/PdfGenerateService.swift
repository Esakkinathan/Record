//
//  PdfGenerateService.swift
//  record
//
//  Created by Esakkinathan B on 02/03/26.
//
import UIKit

class PdfGenerateService {
    func generate(from images: [UIImage]) -> Data {
        
        let pageWidth: CGFloat = 595
        let pageHeight: CGFloat = 842
        
        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        )
        
        return renderer.pdfData { context in
            for image in images {
                context.beginPage()
                
                let rect = aspectFitRect(
                    for: image.size,
                    in: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
                )
                
                image.draw(in: rect)
            }
        }
    }
    
    func aspectFitRect(
        for imageSize: CGSize,
        in boundingRect: CGRect
    ) -> CGRect {
        
        let widthRatio = boundingRect.width / imageSize.width
        let heightRatio = boundingRect.height / imageSize.height
        let scale = min(widthRatio, heightRatio)
        
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        
        let x = (boundingRect.width - scaledWidth) / 2
        let y = (boundingRect.height - scaledHeight) / 2
        
        return CGRect(
            x: x,
            y: y,
            width: scaledWidth,
            height: scaledHeight
        )
    }

}


import UIKit
import CoreGraphics
import ImageIO
/*
final class PDFService {

    func generatePDF(from images: [UIImage]) -> Data {
        let compression = SettingsManager.shared.compressionLevel
        let pageSize = CGSize(width: 595, height: 842) // A4

        let pdfData = NSMutableData()
        guard let consumer = CGDataConsumer(data: pdfData as CFMutableData) else { return Data() }

        var mediaBox = CGRect(origin: .zero, size: pageSize)
        guard let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else { return Data() }

        for image in images {
            guard let cgImage = image.cgImage else { continue }

            let compressedData = NSMutableData()
            guard
                let imageDestination = CGImageDestinationCreateWithData(
                    compressedData as CFMutableData,
                    "public.jpeg" as CFString,
                    1,
                    nil
                )
            else { continue }

            let options: [CFString: Any] = [
                kCGImageDestinationLossyCompressionQuality: compression.value
            ]
            CGImageDestinationAddImage(imageDestination, cgImage, options as CFDictionary)
            guard CGImageDestinationFinalize(imageDestination) else { continue }

            guard
                let source = CGImageSourceCreateWithData(compressedData as CFData, nil),
                let compressedCGImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
            else { continue }

            _ = CGRect(origin: .zero, size: pageSize)
            context.beginPDFPage(nil)

            let drawRect = aspectFitRect(
                for: CGSize(width: compressedCGImage.width, height: compressedCGImage.height),
                in: CGRect(origin: .zero, size: pageSize)
            )

            context.draw(compressedCGImage, in: drawRect)
            context.endPDFPage()
        }

        context.closePDF()
        return pdfData as Data
    }

    private func aspectFitRect(for imageSize: CGSize, in boundingRect: CGRect) -> CGRect {
        let scale = min(boundingRect.width / imageSize.width,
                        boundingRect.height / imageSize.height)
        let scaledSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let origin = CGPoint(
            x: (boundingRect.width - scaledSize.width) / 2,
            y: (boundingRect.height - scaledSize.height) / 2
        )
        return CGRect(origin: origin, size: scaledSize)
    }
}
*/


final class PDFService {

    func generatePDF(from images: [UIImage]) -> Data {
        let compression = SettingsManager.shared.compressionLevel
        let pageSize = CGSize(width: 595, height: 842) // A4

        let pdfData = NSMutableData()
        guard let consumer = CGDataConsumer(data: pdfData as CFMutableData) else { return Data() }

        var mediaBox = CGRect(origin: .zero, size: pageSize)
        guard let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else { return Data() }

        for image in images {

            // Fix orientation
            let fixedImage = image.normalized()
            guard let cgImage = fixedImage.cgImage else { continue }

            // Compress image
            let compressedData = NSMutableData()
            guard
                let imageDestination = CGImageDestinationCreateWithData(
                    compressedData as CFMutableData,
                    "public.jpeg" as CFString,
                    1,
                    nil
                )
            else { continue }

            let options: [CFString: Any] = [
                kCGImageDestinationLossyCompressionQuality: compression.value
            ]

            CGImageDestinationAddImage(imageDestination, cgImage, options as CFDictionary)
            guard CGImageDestinationFinalize(imageDestination) else { continue }

            guard
                let source = CGImageSourceCreateWithData(compressedData as CFData, nil),
                let compressedCGImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
            else { continue }

            context.beginPDFPage(nil)

            // Fix PDF coordinate system
            //context.saveGState()
            //context.translateBy(x: 0, y: pageSize.height)
            //context.scaleBy(x: 1.0, y: -1.0)

            let drawRect = aspectFitRect(
                for: CGSize(width: compressedCGImage.width, height: compressedCGImage.height),
                in: CGRect(origin: .zero, size: pageSize)
            )

            context.draw(compressedCGImage, in: drawRect)

            //context.restoreGState()
            context.endPDFPage()
        }

        context.closePDF()
        return pdfData as Data
    }

    private func aspectFitRect(for imageSize: CGSize, in boundingRect: CGRect) -> CGRect {
        let scale = min(
            boundingRect.width / imageSize.width,
            boundingRect.height / imageSize.height
        )

        let scaledSize = CGSize(
            width: imageSize.width * scale,
            height: imageSize.height * scale
        )

        let origin = CGPoint(
            x: (boundingRect.width - scaledSize.width) / 2,
            y: (boundingRect.height - scaledSize.height) / 2
        )

        return CGRect(origin: origin, size: scaledSize)
    }
}
extension UIImage {

    func normalized() -> UIImage {

        if imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage ?? self
    }
}
