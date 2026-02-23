//
//  trydoc.swift
//  record
//
//  Created by Esakkinathan B on 22/02/26.
//

/*
import UIKit
import Vision

struct ExtractedDocumentModel {
    let detectedType: DefaultDocument
    let documentNumber: String?
    let expiryDate: String?
    let fullText: String
    let pdfData: Data
}

class DocumentOCRService {

    func process(images: [UIImage],
                 completion: @escaping (ExtractedDocumentModel) -> Void) {

        let limitedImages = Array(images.prefix(10))

        extractText(from: limitedImages) { [weak self] text in
            guard let self = self else { return }

            let detectedType = detect(from: text)
            let number = extractNumber(from: text, type: detectedType)
            let expiry = extractExpiry(from: text, type: detectedType)
            let pdfData = generate(from: limitedImages)

            let model = ExtractedDocumentModel(
                detectedType: detectedType,
                documentNumber: number,
                expiryDate: expiry,
                fullText: text,
                pdfData: pdfData
            )

            completion(model)
        }
    }

    func extractText(from images: [UIImage],
                     completion: @escaping (String) -> Void) {

        let group = DispatchGroup()
        var combinedText = ""

        for image in images {
            group.enter()

            recognize(image: image) { text in
                combinedText += text + "\n"
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(combinedText)
        }
    }

    private func recognize(image: UIImage,
                           completion: @escaping (String) -> Void) {

        guard let cgImage = image.cgImage else {
            completion("")
            return
        }

        let request = VNRecognizeTextRequest { request, _ in
            let observations = request.results as? [VNRecognizedTextObservation] ?? []

            let text = observations.compactMap {
                $0.topCandidates(1).first?.string
            }.joined(separator: "\n")

            completion(text)
        }

        request.recognitionLevel = .accurate

        let handler = VNImageRequestHandler(cgImage: cgImage)

        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    func detect(from text: String) -> DefaultDocument {

        let lower = text.lowercased()

        if lower.contains("aadhaar") || lower.contains("government of india") {
            return .adhar
        }

        if lower.contains("income tax department") {
            return .pan
        }

        if lower.contains("voter") {
            return .voterId
        }

        if lower.contains("passport") &&
           lower.contains("republic of india") {
            return .passport
        }

        if lower.contains("driving licence") {
            return .drivingLicense
        }

        if lower.contains("ration") {
            return .rationCard
        }

        if lower.contains("birth certificate") {
            return .birthCertificate
        }

        if lower.contains("death certificate") {
            return .deathCertificate
        }

        if lower.contains("registration certificate") {
            return .vehicleRegistrationCertificate
        }

        if lower.contains("income certificate") {
            return .incomeCertificate
        }

        if lower.contains("marriage certificate") {
            return .marriageCertificate
        }

        if lower.contains("nativity") {
            return .nativityCertificate
        }

        if lower.contains("community certificate") {
            return .communityCertificate
        }

        if lower.contains("disability certificate") {
            return .disabilityCertificate
        }

        if lower.contains("first graduate") {
            return .firstGraduateCertificate
        }

        return .custom
    }
    func extractNumber(from text: String,
                       type: DefaultDocument) -> String? {
        
        switch type {
            
        case .adhar:
            return match("\\d{4}\\s\\d{4}\\s\\d{4}", in: text)
            
        case .pan:
            return match("[A-Z]{5}[0-9]{4}[A-Z]{1}", in: text)
            
        case .passport:
            return match("[A-Z]{1}[0-9]{7}", in: text)
            
        case .drivingLicense:
            return match("[A-Z]{2}\\d{2}\\s?\\d{11}", in: text)
            
        default:
            return match("[A-Z0-9]{6,20}", in: text)
        }
    }
    func extractExpiry(from text: String,
                       type: DefaultDocument) -> String? {

        switch type {
        case .passport, .drivingLicense, .incomeCertificate:
            return match("\\d{2}/\\d{2}/\\d{4}", in: text)
        default:
            return nil
        }
    }
    private func match(_ pattern: String,
                       in text: String) -> String? {

        return text.range(of: pattern, options: .regularExpression)
            .map { String(text[$0]) }
    }
    
    func generate(from images: [UIImage]) -> Data {

        let pageWidth: CGFloat = 595
        let pageHeight: CGFloat = 842

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        )

        return renderer.pdfData { context in
            for image in images {
                context.beginPage()

                let scaledRect = self.aspectFitRect(
                    for: image.size,
                    in: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
                )

                image.draw(in: scaledRect)
            }
        }
    }

    private func aspectFitRect(for imageSize: CGSize,
                               in boundingRect: CGRect) -> CGRect {

        let widthRatio = boundingRect.width / imageSize.width
        let heightRatio = boundingRect.height / imageSize.height
        let scale = min(widthRatio, heightRatio)

        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale

        let x = (boundingRect.width - scaledWidth) / 2
        let y = (boundingRect.height - scaledHeight) / 2

        return CGRect(x: x, y: y,
                      width: scaledWidth,
                      height: scaledHeight)
    }

}

*/
