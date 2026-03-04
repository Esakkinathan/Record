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
struct InfoRowModel {
    let title: String
    let summary: String
    let style: Style
    
    enum Style {
        case normal
        case success
        case warning
        case danger
    }
}

struct LogKey: Hashable {
    let medicalItemId: Int
    let schedule: MedicalSchedule
}

/*
class ActiveMedicineUseCase {
    var itemRepository = MedicineRepository()
    var logRepository = MedicalIntakeLogRepository()
    func execute() -> SectionViewModel {

        let today = Date().start

        let medicalItems = itemRepository.fetchActiveMedicines()
        print("medical item count",medicalItems.count)
        let logs = medicalItems.flatMap {
            logRepository.fetch(medicalId: $0.id, date: today)
        }
        print("log item count",medicalItems.count)

        let logMap = Dictionary(
            uniqueKeysWithValues: logs.map {
                (LogKey(medicalItemId: $0.medicineId,
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
*/

class ActiveMedicineUseCase {
    var itemRepository  = MedicineRepository()
    var logRepository   = MedicalIntakeLogRepository()

    /// Pass the full list of `Medical` records so we can resolve each medicine → medical title.
    func execute(medicals: [Medical]) -> DashboardViewModel {

        let today        = Date().start
        let medicines    = itemRepository.fetchActiveMedicines()
        let logs         = medicines.flatMap { logRepository.fetch(medicalId: $0.id, date: today) }

        // medical-id → Medical  (fast lookup)
        print("logs for entirely",logs, logs.count)
        let medicalMap   = Dictionary(uniqueKeysWithValues: medicals.map { ($0.id, $0) })

        // (medicineId, schedule) → log
        let logMap       = Dictionary(
            uniqueKeysWithValues: logs.map {
                (LogKey(medicalItemId: $0.medicineId, schedule: $0.schedule), $0)
            }
        )

        var scheduleRows: [ScheduleRowViewModel] = []

        for schedule in MedicalSchedule.allCases {

            var completed: [MedicineDetail] = []
            var remaining: [MedicineDetail] = []

            for medicine in medicines {
                guard medicine.shedule.contains(schedule) else { continue }

                let medicalTitle = medicalMap[medicine.medical]?.title ?? "Unknown"
                let detail       = MedicineDetail(
                    medicineName: medicine.name,
                    medicalTitle: medicalTitle
                )

                let key = LogKey(medicalItemId: medicine.id, schedule: schedule)

                if let log = logMap[key], log.taken {
                    completed.append(detail)
                } else {
                    remaining.append(detail)
                }
            }

            scheduleRows.append(
                ScheduleRowViewModel(
                    schedule: schedule,
                    completed: completed,
                    remaining: remaining
                )
            )
        }

        return DashboardViewModel(scheduleRows: scheduleRows)
    }
}

