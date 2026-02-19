//
//  ActiveMedicalItemsUseCase.swift
//  record
//
//  Created by Esakkinathan B on 18/02/26.
//
import Foundation

struct SectionViewModel {
    let title: String
    let rows: [InfoRowModel]
}

struct LogKey: Hashable {
    let medicalItemId: Int
    let schedule: MedicalSchedule
}


class ActiveMedicalItemsUseCase {
    var itemRepository = MedicalItemRepository()
    var logRepository = MedicalIntakeLogRepository()
    /*
    func execute(medicals: [Medical]) -> [SectionViewModel] {
        
        let today = Calendar.current.startOfDay(for: Date())
        
        let medicalItems = medicals.flatMap {
            itemRepository.activeMedicalItems($0.id, date: today)
        }
        print("item count",medicalItems.count)
        
        let logs = medicalItems.flatMap {
            logRepository.fetch(medicalId: $0.id, date: today)
        }
        print("logs count",logs.count)
        let logMap = Dictionary(
            uniqueKeysWithValues: logs.map {
                (LogKey(medicalItemId: $0.medicalItemId,
                        schedule: $0.schedule), $0)
            }
        )
        
        let medicalMap = Dictionary(
            uniqueKeysWithValues: medicals.map { ($0.id, $0) }
        )
        
        return MedicalSchedule.allCases.compactMap { schedule in
            
            let rows: [InfoRowModel] = medicalItems.compactMap { item in
                
                guard item.shedule.contains(schedule),
                      let medicalTitle = medicalMap[item.medical]?.title
                else { return nil }
                
                let key = LogKey(medicalItemId: item.id, schedule: schedule)
                
                let style: InfoRowModel.Style
                let summary: String
                
                if let log = logMap[key] {
                    if log.taken {
                        style = .success
                        summary = "Taken"
                    } else {
                        style = .warning
                        summary = "Pending"
                    }
                } else {
                    style = .danger
                    summary = "Remaining"
                }
                
                return InfoRowModel(
                    title: "\(item.name) for \(medicalTitle)",
                    summary: summary,
                    style: style
                )
            }
            
            guard !rows.isEmpty else { return nil }
            
            return SectionViewModel(
                title: "\(schedule.rawValue) (\(rows.count) medicines)",
                rows: rows
            )
        }
    }
     */
    func execute() -> SectionViewModel {

        let today = Date().start
        let end = Date().end

        let medicalItems = itemRepository.fetchMedicalItemsByDate(from: today, to: end)
            
        print("medical item count",medicalItems.count)
        let logs = medicalItems.flatMap {
            logRepository.fetch(medicalId: $0.id, date: today)
        }
        print("log item count",medicalItems.count)

        let logMap = Dictionary(
            uniqueKeysWithValues: logs.map {
                (LogKey(medicalItemId: $0.medicalItemId,
                        schedule: $0.schedule), $0)
            }
        )

        var rows: [InfoRowModel] = []

        for schedule in MedicalSchedule.allCases {

            var remainingCount = 0

            for item in medicalItems {

                guard item.shedule.contains(schedule) else { continue }

                let key = LogKey(
                    medicalItemId: item.id,
                    schedule: schedule
                )

                if let log = logMap[key] {
                    if !log.taken {
                        remainingCount += 1
                    }
                } else {
                    remainingCount += 1
                }
            }

            let style: InfoRowModel.Style
            let summary: String

            if remainingCount == 0 {
                style = .success
                summary = "No Medicines"
            } else {
                style = .danger
                summary = "\(remainingCount) medicines remaining"
            }

            rows.append(
                InfoRowModel(
                    title: schedule.rawValue,
                    summary: summary,
                    style: style
                )
            )
        }

        return
            SectionViewModel(
                title: "Today's Overview",
                rows: rows
            )
        
    }


}
