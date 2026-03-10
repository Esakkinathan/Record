//
//  PdfExportUseCase.swift
//  record
//
//  Created by Esakkinathan B on 25/02/26.
//
import UIKit
import PDFKit

struct MedicineLog {
    let date: Date
    let schedule: MedicalSchedule
    let name: String
    let status: Bool
}

class PdfExportUseCase {

    let fetchMedicalItemUseCase = FetchMedicineUseCase(repository: MedicineRepository())
    let fetchMedicalLogUseCase = FetchLogUseCase(repository: MedicalIntakeLogRepository())

    func datesBetween(start: Date, end: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = start
        
        let calendar = Calendar.current
        
        while currentDate <= end {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return dates
    }
    
    func fetchLog(medicine: Medicine) -> [MedicineLog] {
        let logs: [MedicineIntakeLog] = fetchMedicalLogUseCase.execute(medicalId: medicine.id)
        var logDict: [String: Bool] = [:]
        for log in logs {
            let key = "\(log.medicineId)_\(log.date.timeIntervalSince1970)_\(log.schedule.rawValue)"
            logDict[key] = log.taken
        }

        var medicinesLog: [MedicineLog] = []
        let endDate = medicine.endDate
        let days = datesBetween(start: medicine.startDate, end: endDate == nil ? Date() : endDate!)
        for day in days {
            if day > Date() {continue}
            for schedule in medicine.shedule {
                let key = "\(medicine.id)_\(day.timeIntervalSince1970)_\(schedule.rawValue)"
                let isTaken = logDict[key] ?? false
                medicinesLog.append(.init(date: day, schedule: schedule, name: medicine.name, status: isTaken))

            }
        }
        return medicinesLog
    }
    
    func fetchLog(medicalItemDict: [MedicalKind:[Medicine]])-> [MedicalKind:[MedicineLog]] {
        var logs: [MedicineIntakeLog] = []
        
        for (_, item) in medicalItemDict {
            for data in item {
                logs += fetchMedicalLogUseCase.execute(medicalId: data.id)
            }
        }
        var logDict: [String: Bool] = [:]
        for log in logs {
            let key = "\(log.medicineId)_\(log.date.timeIntervalSince1970)_\(log.schedule.rawValue)"
            logDict[key] = log.taken
        }
        var medicines: [MedicalKind:[MedicineLog]] = [:]
        for (kind, item) in medicalItemDict {
            medicines[kind] = []
            let temp = item.sorted {
                $0.startDate < $1.startDate
            }
            for data in temp {
                let endDate = data.endDate
                let days = datesBetween(start: data.startDate, end: endDate == nil ? Date() : endDate!)
                for day in days {
                    if day > Date() { break }
                    for schedule in data.shedule {
                        let key = "\(data.id)_\(day.timeIntervalSince1970)_\(schedule.rawValue)"
                        let isTaken = logDict[key] ?? false
                        medicines[kind]?.append(.init(date: day, schedule: schedule, name: data.name, status: isTaken))
                    }

                }
            }
        }
        return medicines

    }
    func fetchData(medical: Medical) -> [MedicalKind:[Medicine]] {

        var medicalItemDict: [MedicalKind:[Medicine]] = [:]
        for kind in MedicalKind.allCases {
            medicalItemDict[kind] = fetchMedicalItemUseCase.execute(id: medical.id, kind: kind)
        }
        return medicalItemDict
    }

    func generateMedicalPDF(medical: Medical) -> Data {

        let medicalItems = fetchData(medical: medical)
        let medcines = fetchLog(medicalItemDict: medicalItems)
        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let margin: CGFloat = 20

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        )

        return renderer.pdfData { context in

            context.beginPage()
            var y: CGFloat = margin

            func checkForNewPage(requiredHeight: CGFloat) {
                if y + requiredHeight > pageHeight - margin {
                    context.beginPage()
                    y = margin
                }
            }

            // MARK: - Title

            let title = "Health Record"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: AppFont.heading1
            ]

            let textWidth = title.size(withAttributes: titleAttributes).width
            let xPosition = (pageWidth - textWidth) / 2

            title.draw(
                at: CGPoint(x: xPosition, y: y),
                withAttributes: titleAttributes
            )

            y += 40

            // MARK: - Details Header

            checkForNewPage(requiredHeight: 30)

            "Details".draw(
                at: CGPoint(x: margin, y: y),
                withAttributes: [.font: AppFont.heading2]
            )

            y += 30

            // MARK: - Details Content

            let boldBody = UIFont.boldSystemFont(ofSize: 13)

            var details: [DetailMedicalTextSectionRow] = []

            details.append(.init(title: "Title", value: medical.title))
            details.append(.init(title: "Recorded At", value: medical.date.toString()))
            //details.append(.init(title: "Duration", value: medical.durationText))
            details.append(.init(title: "Type", value: medical.type.rawValue))

            if let hospital = medical.hospital {
                details.append(.init(title: "Hospital", value: hospital))
            }

            if let doctor = medical.doctor {
                details.append(.init(title: "Doctor", value: doctor))
            }
            details.append(.init(title: "Status", value: medical.status ? "On Going" : "Completed at \(medical.endDate?.toString() ?? "some day")"))
            for item in details {

                checkForNewPage(requiredHeight: 25)

                let attributedText = NSMutableAttributedString()

                let titlePart = NSAttributedString(
                    string: "\(item.title): ",
                    attributes: [.font: boldBody]
                )

                let valuePart = NSAttributedString(
                    string: item.value,
                    attributes: [.font: AppFont.body]
                )

                attributedText.append(titlePart)
                attributedText.append(valuePart)

                attributedText.draw(at: CGPoint(x: margin * 2, y: y))
                y += 25
            }

            y += 25

            // MARK: - Notes

            if let notes = medical.notes,
               !notes.isEmpty {

                drawNotes(
                    notes: notes,
                    pageWidth: pageWidth,
                    pageHeight: pageHeight,
                    margin: margin,
                    yPosition: &y,
                    context: context
                )
            }

            // MARK: - Medicines Table

            drawMedicineSections(
                medicines: medcines,
                medicalItems: medicalItems,
                pageWidth: pageWidth,
                pageHeight: pageHeight,
                margin: margin,
                yPosition: &y,
                context: context
            )
        }
    }
    func drawNotes(
        notes: String,
        pageWidth: CGFloat,
        pageHeight: CGFloat,
        margin: CGFloat,
        yPosition: inout CGFloat,
        context: UIGraphicsPDFRendererContext
    ) {

        let contentWidth = pageWidth - (margin * 2)

        let boundingRect = notes.boundingRect(
            with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            attributes: [.font: AppFont.body],
            context: nil
        )

        if yPosition + boundingRect.height + 40 > pageHeight - margin {
            context.beginPage()
            yPosition = margin
        }

        "Notes".draw(
            at: CGPoint(x: margin, y: yPosition),
            withAttributes: [.font: AppFont.heading3]
        )

        yPosition += 25

        notes.draw(
            in: CGRect(
                x: margin * 2,
                y: yPosition,
                width: contentWidth,
                height: boundingRect.height
            ),
            withAttributes: [.font: AppFont.small]
        )

        yPosition += boundingRect.height + 40
    }
    private func drawMedicineSections(
        medicines: [MedicalKind: [MedicineLog]],
        medicalItems: [MedicalKind: [Medicine]],
        pageWidth: CGFloat,
        pageHeight: CGFloat,
        margin: CGFloat,
        yPosition: inout CGFloat,
        context: UIGraphicsPDFRendererContext
    ) {

        let contentWidth = pageWidth - (margin * 2)
        let rowHeight: CGFloat = 28
        let boldFont = UIFont.boldSystemFont(ofSize: 13)
        let normalFont = AppFont.verysmall

        func startNewPageIfNeeded(requiredHeight: CGFloat) {
            if yPosition + requiredHeight > pageHeight - margin {
                context.beginPage()
                yPosition = margin
            }
        }

        func drawRow(values: [String], columnWidth: CGFloat) {
            for (index, value) in values.enumerated() {

                let rect = CGRect(
                    x: margin + CGFloat(index) * columnWidth,
                    y: yPosition,
                    width: columnWidth,
                    height: rowHeight
                )

                value.draw(
                    in: rect.insetBy(dx: 4, dy: 6),
                    withAttributes: [.font: normalFont]
                )

                drawBorder(rect)
            }

            yPosition += rowHeight
        }
        func drawLogRow(values: [String], columnWidth: CGFloat) {
            for (index, value) in values.enumerated() {

                let rect = CGRect(
                    x: margin + CGFloat(index) * columnWidth,
                    y: yPosition,
                    width: columnWidth,
                    height: rowHeight
                )
                if index+1 == values.count {
                    value.draw(
                        in: rect.insetBy(dx: 4, dy: 6),
                        withAttributes: [.font: normalFont, .foregroundColor: value == "Taken" ? UIColor.systemGreen : UIColor.systemRed ]
                    )

                } else {
                    value.draw(
                        in: rect.insetBy(dx: 4, dy: 6),
                        withAttributes: [.font: normalFont]
                    )
                }

                drawBorder(rect)
            }

            yPosition += rowHeight
        }

        func drawHeader(values: [String], columnWidth: CGFloat) {
            for (index, value) in values.enumerated() {

                let rect = CGRect(
                    x: margin + CGFloat(index) * columnWidth,
                    y: yPosition,
                    width: columnWidth,
                    height: rowHeight
                )

                value.draw(
                    in: rect.insetBy(dx: 4, dy: 6),
                    withAttributes: [.font: boldFont]
                )

                drawBorder(rect)
            }

            yPosition += rowHeight
        }

        for kind in MedicalKind.allCases {

            guard let items = medicalItems[kind], !items.isEmpty else { continue }

            startNewPageIfNeeded(requiredHeight: 30)

            kind.rawValue.draw(
                at: CGPoint(x: margin, y: yPosition),
                withAttributes: [.font: AppFont.heading3]
            )

            yPosition += 25

            // MARK: 1️⃣ Medical Items Table
            let itemHeaders = ["Name", "Instruction", "Dosage"]
            let itemColumnWidth = contentWidth / CGFloat(itemHeaders.count)

            startNewPageIfNeeded(requiredHeight: rowHeight)
            drawHeader(values: itemHeaders, columnWidth: itemColumnWidth)

            for item in items {

                startNewPageIfNeeded(requiredHeight: rowHeight)

                let rowValues = [
                    item.name,
                    item.instruction.value,
                    item.dosage
                ]

                drawRow(values: rowValues, columnWidth: itemColumnWidth)
            }

            yPosition += 20

            // MARK: 2️⃣ Medicine Log Section
            if let logs = medicines[kind], !logs.isEmpty {

                startNewPageIfNeeded(requiredHeight: 25)

                let logTitle = "\(kind.rawValue) Log"
                logTitle.draw(
                    at: CGPoint(x: margin, y: yPosition),
                    withAttributes: [.font: AppFont.heading3]
                )

                yPosition += 25

                let logHeaders = ["Date", "Schedule", "Name", "Status"]
                let logColumnWidth = contentWidth / CGFloat(logHeaders.count)

                startNewPageIfNeeded(requiredHeight: rowHeight)
                drawHeader(values: logHeaders, columnWidth: logColumnWidth)

                for log in logs {

                    startNewPageIfNeeded(requiredHeight: rowHeight)

                    let rowValues = [
                        log.date.toString(),
                        log.schedule.rawValue,
                        log.name,
                        log.status ? "Taken" : "Not Taken"
                    ]

                    drawLogRow(values: rowValues, columnWidth: logColumnWidth)
                }
            }

            yPosition += 30
        }
    }
    
    private func drawBorder(_ rect: CGRect) {
        let path = UIBezierPath(rect: rect)
        UIColor.black.setStroke()
        path.stroke()
    }
}
