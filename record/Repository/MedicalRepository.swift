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
    
    func createEmptyData() {
        
    }

    
    init() {
        //createEmptyData()
    }
    func fetchHospitals(lat: Double, lng: Double) async -> [String]? {

        let query = """
        [out:json][timeout:8];
        node["amenity"="hospital"](around:5000,\(lat),\(lng));
        out;
        """

        guard let url = URL(string: "https://overpass-api.de/api/interpreter") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 8
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

        guard let location = await LocationService.shared.getLocation() else {
            return fetchHospitals()
        }

        if let hospitals = await fetchHospitals(
            lat: location.latitude,
            lng: location.longitude
        ), !hospitals.isEmpty {
            return hospitals
        }

        return fetchHospitals()
    }
    
    func fetchHospitals() -> [String] {
        return db.fetchDistinctValues(table: Medical.databaseTableName, column: Medical.hospitalC)
    }
    
    func update(medical: Medical) {
        
        let columns: [String: Any?] = [
            Medical.idC: medical.id,
            Medical.titleC: medical.title,
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
