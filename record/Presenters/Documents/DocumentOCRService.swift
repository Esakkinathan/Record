//
//  DocumentOCRService.swift
//  record
//
//  Created by Esakkinathan B on 21/02/26.
//
import UIKit
import Vision
import PDFKit


struct ExtractedDocumentModel {
    let detectedType: DefaultDocument
    let documentNumber: String?
    let expiryDate: Date?
    let fullText: String
    let pdfData: Data
}


final class DocumentOCRService {
    
    func process(
        images: [UIImage],
        completion: @escaping (Result<ExtractedDocumentModel, Error>) -> Void
    ) {
        
        let limitedImages = Array(images.prefix(10))
        print("limited images:", limitedImages.count)
        
        extractText(from: limitedImages) { text in
            
            let detectedType = self.detect(from: text)
            print("detected type:", detectedType)
            
            let number = self.extractNumber(from: text, type: detectedType)
            let expiry = self.extractMaxDate(from: text, type: detectedType)
            let pdfData = self.generate(from: limitedImages)
            
            let model = ExtractedDocumentModel(
                detectedType: detectedType,
                documentNumber: number,
                expiryDate: expiry,
                fullText: text,
                pdfData: pdfData
            )
            
            print("completion about to return")
            
            DispatchQueue.main.async {
                completion(.success(model))
            }
        }
    }
    func process(urls: [URL], ) async throws -> ExtractedDocumentModel {
        var extractedText: String = ""
        let mergedDocument = PDFDocument()
        var pageIndex = 0

        for url in urls {
            guard let pdf = PDFDocument(url: url) else { continue }
            
            for index in 0..<pdf.pageCount {
                guard let page = pdf.page(at: index) else { continue }
                if let text = page.string, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    extractedText += "\n" + text
                } else {
                    extractedText += await extractTextFromPDFPage(page: page)
                }
                mergedDocument.insert(page, at: pageIndex)
                pageIndex+=1
            }
        }
        let detectedType = self.detect(from: extractedText)
        print("detected type:", detectedType)
        
        let number = self.extractNumber(from: extractedText, type: detectedType)
        let expiry = self.extractMaxDate(from: extractedText, type: detectedType)
        guard let data = mergedDocument.dataRepresentation() else {
            throw PDFMergeError.failedToGenerateData
        }
        
        let model = ExtractedDocumentModel(
            detectedType: detectedType,
            documentNumber: number,
            expiryDate: expiry,
            fullText: extractedText,
            pdfData: data
        )
        return model
    }
    
    func extractTextFromPDFPage(page: PDFPage) async -> String {
        
        let pageImage = page.thumbnail(of: CGSize(width: 1000, height: 1400), for: .mediaBox)
        do {
            let text = try await recognizeText(from: pageImage)
            return text
        } catch {
            print(error)
        }
        return ""
    }
    
    func recognizeText(from image: UIImage) async throws -> String {
        
        guard let cgImage = image.cgImage else {
            return ""
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            
            let request = VNRecognizeTextRequest { request, error in
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                
                let recognizedText = observations.compactMap {
                    $0.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                continuation.resume(returning: recognizedText)
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}


private extension DocumentOCRService {
    
    func extractText(
        from images: [UIImage],
        completion: @escaping (String) -> Void
    ) {
        let group = DispatchGroup()
        var results = Array<String?>(repeating: nil, count: images.count)
        
        for (index, image) in images.enumerated() {
            group.enter()
            
            recognize(image: image) { text in
                results[index] = text
                group.leave()
            }
        }
        
        group.notify(queue: .global(qos: .userInitiated)) {
            let combined = results.compactMap { $0 }.joined(separator: "\n")
            completion(combined)
        }
    }
    
    func recognize(
        image: UIImage,
        completion: @escaping (String) -> Void
    ) {
        guard let cgImage = image.cgImage else {
            completion("")
            return
        }
        
        let request = VNRecognizeTextRequest { request, _ in
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            
            let text = observations.compactMap {
                $0.topCandidates(1).first?.string
            }.joined(separator: "\n")
            print("recognized text is",text)
            completion(text)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-IN"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        try? handler.perform([request])
    }
}


private extension DocumentOCRService {
    struct DocumentDetector {
        
        
    }
    func detect(from text: String) -> DefaultDocument {
        let rules: [(type: DefaultDocument, keywords: [String])] = [
            (.adhar, ["aadhaar"]),
            (.pan, ["income tax department", "permanent"]),
            (.voterId, ["voter", "election", "elector"]),
            (.passport, ["republic", "passport"]),
            (.drivingLicense, ["driving", "license"]),
            (.rationCard, ["ration", "family card", "civil supplies"]),
            (.birthCertificate, ["birth"]),
            (.deathCertificate, ["death"]),
            (.vehicleRegistrationCertificate, ["registration"]),
            (.incomeCertificate, ["income certificate"]),
            (.marriageCertificate, ["marriage"]),
            (.nativityCertificate, ["nativity"]),
            (.communityCertificate, ["community"]),
            (.disabilityCertificate, ["disability"]),
            (.firstGraduateCertificate, ["first graduate"])
        ]
        let lower = text.lowercased()
        
        for (document, keywords) in rules {
            if keywords.contains(where: { lower.contains($0) }) {
                return document
            }
        }
        
        return .custom
    }
}


private extension DocumentOCRService {
    
    func extractNumber(
        from text: String,
        type: DefaultDocument
    ) -> String? {
        var data: String?
        switch type {
            
        case .adhar:
            data = match("\\d{4}\\s\\d{4}\\s\\d{4}", in: text)
            
        case .pan:
            data = match("[A-Z]{5}[0-9]{4}[A-Z]", in: text.uppercased())
            
        case .passport:
            var value = match("[A-Z]{2}[0-9]{6}", in: text.uppercased())
            if value == nil {
                value = match("[A-Z][0-9]{7}", in: text.uppercased())
            }
            data = value
        case .voterId:
            data = match("[A-Z]{3}\\d{6,10}", in: text.uppercased())
        case .drivingLicense:
            var value = match("[A-Z]{2}\\d{2}[A-Z]\\d{11}", in: text.uppercased())
            if value == nil {
                value = match("[A-Z]{2}\\d{2}\\s\\d{11}", in: text.uppercased())
            }
            data = value
        default:
            data = match("[A-Z0-9]{6,20}", in: text.uppercased())
        }
        data = data?.replacingOccurrences(of: " ", with: "")
        return data
    }
    
//    func extractExpiry(
//        from text: String,
//        type: DefaultDocument
//    ) -> Date? {
//        
////        let lines = text.components(separatedBy: .newlines)
//        
//        switch type {
//            
//        case .passport:
//            return extractMaxDate(
//                afterKeywords: ["date of expiry"],
//                in: lines
//            )
//            
//        case .drivingLicense:
//            return extractMaxDate(
//                afterKeywords: ["validity", "valid till", "validity (nt)", "validity (tr)"],
//                in: lines
//            )
//            
//        case .incomeCertificate:
//            return extractMaxDate(
//                afterKeywords: ["valid upto", "expiry"],
//                in: lines
//            )
//            
//        default:
//            return nil
//        }
//    }
//    private func extractDate(
//        afterKeywords keywords: [String],
//        in lines: [String]
//    ) -> Date? {
//        
//        for (index, line) in lines.enumerated() {
//            
//            let lowerLine = line.lowercased()
//            
//            if keywords.contains(where: { lowerLine.contains($0) }) {
//                
//                if let date = detectDate(in: line) {
//                    return date
//                }
//                
//                if index + 1 < lines.count,
//                   let date = detectDate(in: lines[index + 1]) {
//                    return date
//                }
//                
//                if index + 2 < lines.count,
//                   let date = detectDate(in: lines[index + 2]) {
//                    return date
//                }
//            }
//        }
//        
//        return nil
//    }
    private func extractMaxDate(from text: String, type: DefaultDocument) -> Date? {
        if type.hasExpiryDate {
            
            let pattern = "\\d{2}[./-]\\d{2}[./-]\\d{4}"
            
            let regex = try? NSRegularExpression(pattern: pattern)
            let matches = regex?.matches(in: text, range: NSRange(text.startIndex..., in: text)) ?? []
            
            var dates: [Date] = []
            
            for match in matches {
                if let range = Range(match.range, in: text) {
                    let dateString = String(text[range])
                    if let date = convertToDate(dateString) {
                        dates.append(date)
                    }
                }
            }
            return dates.max()
        } else {
            return nil
        }
            
     }
    private func detectDate(in text: String) -> Date? {
        
        let pattern = "\\d{2}[./-]\\d{2}[./-]\\d{4}"
        
        guard let range = text.range(of: pattern, options: .regularExpression) else {
            return nil
        }
        
        let dateString = String(text[range])
        
        return convertToDate(dateString)
    }
    private func convertToDate(_ string: String) -> Date? {
        
        let formats = [
            "dd/MM/yyyy",
            "dd-MM-yyyy",
            "dd.MM.yyyy"
        ]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_IN")
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: string) {
                return date
            }
        }
        
        return nil
    }
    func match(_ pattern: String, in text: String) -> String? {
        return text.range(of: pattern, options: .regularExpression)
            .map { String(text[$0]) }
    }
}
extension DocumentOCRService {
    
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
