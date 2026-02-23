//
//  DocumentOCRService.swift
//  record
//
//  Created by Esakkinathan B on 21/02/26.
//
import UIKit
import Vision


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
        print("OCR process started")

        let limitedImages = Array(images.prefix(10))
        print("limited images:", limitedImages.count)

        extractText(from: limitedImages) { text in
            print("text extraction completed")

            let detectedType = self.detect(from: text)
            print("detected type:", detectedType)

            let number = self.extractNumber(from: text, type: detectedType)
            let expiry = self.extractExpiry(from: text, type: detectedType)
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
        let rules: [DefaultDocument: [String]] = [
            .adhar: [
                "aadhaar",
            ],
            .pan: [
                "income tax department",
                "permanent"
            ],
            .voterId: [
                "voter",
                "election",
            ],
            .passport: [
                "republic",
                "passport"
            ],
            .drivingLicense: [
                "driving",
                "license"
            ],
            .rationCard: [
                "ration",
                "family card",
                "civil supplies",
                
            ],
            .birthCertificate: [
                "birth"
            ],
            .deathCertificate: [
                "death"
            ],
            .vehicleRegistrationCertificate: [
                "registration"
            ],
            .incomeCertificate: [
                "income"
            ],
            .marriageCertificate: [
                "marriage"
            ],
            .nativityCertificate: [
                "nativity"
            ],
            .communityCertificate: [
                "community"
            ],
            .disabilityCertificate: [
                "disability"
            ],
            .firstGraduateCertificate: [
                "first graduate"
            ]
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
            
        case .drivingLicense:
            data = match("[A-Z]{2}\\d{2}[A-Z]\\d{11}", in: text.uppercased())
            
        default:
            data = match("[A-Z0-9]{6,20}", in: text.uppercased())
        }
        data = data?.replacingOccurrences(of: " ", with: "")
        return data
    }
    
    func extractExpiry(
        from text: String,
        type: DefaultDocument
    ) -> Date? {
        
        let lines = text.components(separatedBy: .newlines)
        
        switch type {
            
        case .passport:
            return extractDate(
                afterKeywords: ["date of expiry"],
                in: lines
            )
            
        case .drivingLicense:
            return extractDate(
                afterKeywords: ["validity", "valid till", "validity (nt)", "validity (tr)"],
                in: lines
            )
            
        case .incomeCertificate:
            return extractDate(
                afterKeywords: ["valid upto", "expiry"],
                in: lines
            )
            
        default:
            return nil
        }
    }
    private func extractDate(
        afterKeywords keywords: [String],
        in lines: [String]
    ) -> Date? {
        
        for (index, line) in lines.enumerated() {
            
            let lowerLine = line.lowercased()
            
            if keywords.contains(where: { lowerLine.contains($0) }) {
                
                // Check same line first
                if let date = detectDate(in: line) {
                    return date
                }
                
                // Then check next 2 lines (OCR sometimes splits text)
                if index + 1 < lines.count,
                   let date = detectDate(in: lines[index + 1]) {
                    return date
                }
                
                if index + 2 < lines.count,
                   let date = detectDate(in: lines[index + 2]) {
                    return date
                }
            }
        }
        
        return nil
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
