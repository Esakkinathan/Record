//
//  MedicalRepository.swift
//  record
//
//  Created by Esakkinathan B on 07/02/26.
//

import VTDB
import Foundation
internal import _LocationEssentials

extension Date {
    /// Generates a random Date between two specified dates.
    /// - Parameters:
    ///   - start: The earliest possible date.
    ///   - end: The latest possible date.
    /// - Returns: A random Date within the start and end range.
    static func randomBetween(start: Date, end: Date) -> Date {
        let startInterval = start.timeIntervalSince1970
        let endInterval = end.timeIntervalSince1970

        // Ensure the start date is before the end date
        guard startInterval <= endInterval else {
            return randomBetween(start: end, end: start)
        }

        // Generate a random time interval between the start and end intervals
        let randomInterval = TimeInterval.random(in: startInterval...endInterval)

        // Create a new Date using the random interval
        return Date(timeIntervalSince1970: randomInterval)
    }
}

class MedicalRepository: MedicalRepositoryProtocol {
    
    var db: MedicalDatabaseProtocol = DatabaseAdapter.shared
    func randomDateLastYear() -> Date {
        Date().addingTimeInterval(-Double.random(in: 0...31536000))
    }
    func createEmptyData() {
        let records: [Medical] = [

            Medical(
                id: 1,
                title: "Fever",
                type: .checkup,
                hospital: "Apollo Hospital",
                doctor: "Dr. Kumar",
                date: Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1))!,
                createdAt: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 1))!,
                lastModified: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 1))!,
                status: false,
                notes: "High temperature observed",
                receipt: nil,
                endDate: nil
            ),

            Medical(
                id: 2,
                title: "Diabetes",
                type: .chronic,
                hospital: "Fortis Hospital",
                doctor: "Dr. Priya",
                date: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 1))!,
                createdAt: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 1))!,
                lastModified: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 1))!,
                status: false,
                notes: "Blood sugar monitoring started",
                receipt: nil,
                endDate: nil
            ),

            Medical(id: 3, title: "Migraine", type: .chronic, hospital: "MIOT International", doctor: "Dr. Rajesh", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Pain medication prescribed", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 4, title: "Asthma", type: .chronic, hospital: "Global Health City", doctor: "Dr. Anitha", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Inhaler recommended", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 5, title: "Cold", type: .checkup, hospital: "Apollo Hospital", doctor: "Dr. Suresh", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Rest advised", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 6, title: "Stomach Pain", type: .emergency, hospital: "Fortis Hospital", doctor: "Dr. Kumar", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Possible gastritis", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 7, title: "Food Poisoning", type: .emergency, hospital: "MIOT International", doctor: "Dr. Priya", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "IV fluids given", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 8, title: "Back Pain", type: .checkup, hospital: "Global Health City", doctor: "Dr. Rajesh", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Physiotherapy suggested", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 9, title: "Knee Pain", type: .checkup, hospital: "Apollo Hospital", doctor: "Dr. Anitha", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Joint inflammation", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 10, title: "Eye Infection", type: .checkup, hospital: "Fortis Hospital", doctor: "Dr. Suresh", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Eye drops prescribed", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 11, title: "Ear Infection", type: .checkup, hospital: "MIOT International", doctor: "Dr. Kumar", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Antibiotics given", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 12, title: "Tooth Pain", type: .checkup, hospital: "Apollo Hospital", doctor: "Dr. Priya", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Dental cavity", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 13, title: "Hypertension", type: .chronic, hospital: "Fortis Hospital", doctor: "Dr. Rajesh", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "BP monitoring", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 14, title: "Allergy", type: .chronic, hospital: "Global Health City", doctor: "Dr. Anitha", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Antihistamine prescribed", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 15, title: "Skin Rash", type: .checkup, hospital: "Apollo Hospital", doctor: "Dr. Suresh", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Ointment prescribed", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 16, title: "Fracture", type: .surgery, hospital: "MIOT International", doctor: "Dr. Kumar", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Arm cast applied", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 17, title: "Sprain", type: .emergency, hospital: "Fortis Hospital", doctor: "Dr. Priya", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Rest and ice therapy", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 18, title: "Thyroid", type: .chronic, hospital: "Global Health City", doctor: "Dr. Rajesh", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Hormone therapy started", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 19, title: "Bronchitis", type: .checkup, hospital: "Apollo Hospital", doctor: "Dr. Anitha", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Cough medication", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 20, title: "Pneumonia", type: .emergency, hospital: "Fortis Hospital", doctor: "Dr. Suresh", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Hospital observation", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 21, title: "Appendicitis", type: .surgery, hospital: "MIOT International", doctor: "Dr. Kumar", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Appendix removed", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 22, title: "Ulcer", type: .chronic, hospital: "Apollo Hospital", doctor: "Dr. Priya", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Diet restrictions advised", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 23, title: "Malaria", type: .emergency, hospital: "Fortis Hospital", doctor: "Dr. Rajesh", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Antimalarial medication", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 24, title: "Dengue", type: .emergency, hospital: "Global Health City", doctor: "Dr. Anitha", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Platelet monitoring", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 25, title: "Typhoid", type: .checkup, hospital: "Apollo Hospital", doctor: "Dr. Suresh", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Antibiotic course", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 26, title: "Sinusitis", type: .chronic, hospital: "Fortis Hospital", doctor: "Dr. Kumar", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Nasal spray recommended", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 27, title: "Vertigo", type: .checkup, hospital: "MIOT International", doctor: "Dr. Priya", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Balance exercises suggested", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 28, title: "Anemia", type: .chronic, hospital: "Apollo Hospital", doctor: "Dr. Rajesh", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Iron supplements", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 29, title: "Kidney Stone", type: .emergency, hospital: "Fortis Hospital", doctor: "Dr. Anitha", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Pain management", receipt: nil, endDate: randomDateLastYear()),

            Medical(id: 30, title: "Flu", type: .checkup, hospital: "Global Health City", doctor: "Dr. Suresh", date: randomDateLastYear(), createdAt: randomDateLastYear(), lastModified: randomDateLastYear(), status: true, notes: "Rest and hydration", receipt: nil, endDate: randomDateLastYear())
        ]
        records.forEach { add(medical: $0) }
    }
    static var hospitals: [String] = []
    private var hospitalsTask: Task<[String], Never>?

    init() {
        //createEmptyData()
        guard MedicalRepository.hospitals.isEmpty, hospitalsTask == nil else { return }
        hospitalsTask = Task {
            let result = await getHospitals()
            MedicalRepository.hospitals = result
            return result
        }
    }
    func fetchHospitals(lat: Double, lng: Double) async -> [String]? {

        let query = """
        [out:json][timeout:15];
        node["amenity"="hospital"](around:5000,\(lat),\(lng));
        out;
        """

        guard let url = URL(string: "https://overpass-api.de/api/interpreter") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.httpBody = query.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200 else {
                return nil
            }

            let result = try JSONDecoder().decode(OSMResponse.self, from: data)

            return result.elements.compactMap { $0.tags?.name }

        } catch {
            print(error)
            return nil
        }
    }
    
    func isSameArea(lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Bool {

        let loc1 = CLLocation(latitude: lat1, longitude: lng1)
        let loc2 = CLLocation(latitude: lat2, longitude: lng2)

        let distance = loc1.distance(from: loc2)

        return distance < 5000 // 5km radius
    }

    
    func add(medical: Medical) {
        let columns: [String: Any?] = [
            Medical.titleC: medical.title.lowercased(),
            Medical.typeC: medical.type.rawValue,
            Medical.hospitalC: medical.hospital,
            Medical.doctorC: medical.doctor,
            Medical.dateC: medical.date,
            Medical.createdAtC: medical.createdAt,
            Medical.lastModifiedC: medical.lastModified,
            Medical.notesC: medical.notes,
            Medical.receiptC: medical.receipt,
            Medical.endDateC: medical.endDate,
            Medical.statusC: medical.status,
        ]
        
        db.insertInto(tableName: Medical.databaseTableName, values: columns)
    }
    
    func fetchDoctors() -> [String] {
        return db.fetchDistinctValues(table: Medical.databaseTableName, column: Medical.doctorC)
    }
    
    func getHospitals() async -> [String] {

        async let locationTask = LocationService.shared.getLocation()
        async let dbTask: [String] = fetchDBHospitals()

        guard let location = await locationTask else {
            return await dbTask
        }

        
        if let cache = HospitalCacheManager.shared.load(),
           isSameArea(lat1: location.latitude,
                      lng1: location.longitude,
                      lat2: cache.lat,
                      lng2: cache.lng) {

            return cache.hospitals
        }

        
        if let hospitals = await fetchHospitals(lat: location.latitude, lng: location.longitude),
           !hospitals.isEmpty {

            HospitalCacheManager.shared.save(
                lat: location.latitude,
                lng: location.longitude,
                hospitals: hospitals
            )

            return hospitals
        }

        return await dbTask
    }
    func fetchHospitals() -> [String] {
        return MedicalRepository.hospitals
    }
    
    func fetchDBHospitals() -> [String] {
        return db.fetchDistinctValues(table: Medical.databaseTableName, column: Medical.hospitalC)
    }
    
    func update(medical: Medical) {
        
        let columns: [String: Any?] = [
            Medical.idC: medical.id,
            Medical.titleC: medical.title.lowercased(),
            Medical.typeC: medical.type.rawValue,
            Medical.hospitalC: medical.hospital,
            Medical.doctorC: medical.doctor,
            Medical.dateC: medical.date,
            Medical.createdAtC: medical.createdAt,
            Medical.lastModifiedC: medical.lastModified,
            Medical.notesC: medical.notes,
            Medical.receiptC: medical.receipt,
            Medical.endDateC: medical.endDate,
            Medical.statusC: medical.status,
        ]
        
        db.insertInto(tableName: Medical.databaseTableName, values: columns)

    }
    
    func updateNotes(text: String?, id: Int) {
        db.updateNotes(table: Medical.databaseTableName, id: id, text: text, date: Date())
    }

    func delete(id: Int) {
        db.delete(table: Medical.databaseTableName, id: id)
    }
    
    func fetchAll() -> [Medical] {
        return db.fetchMedical()
    }
    
    func fetchActiveMedical() -> [Medical] {
        return db.fetchActiveMedical()
    }
    func fetchMedical(limit: Int, offset: Int, sort: MedicalSortOption, category: MedicalType?,searchText: String?) -> [Medical] {
        let medicals = db.fetchMedical(limit: limit, offset: offset, sort: sort, category: category, searchText: searchText?.lowercased())
        
        for medical in medicals {
            medical.title = medical.title.capitalized
        }
        return medicals
    }
    func setStatus(id: Int,value: Bool, date: Date?) {
        db.setStaus(table: Medical.databaseTableName, column: Medical.statusC, id: id, value: value, endDate: date)
    }
}

struct OSMResponse: Decodable {
    let elements: [OSMElement]
}

struct OSMElement: Decodable {
    let tags: OSMTags?
}

struct OSMTags: Decodable {
    let name: String?
}
