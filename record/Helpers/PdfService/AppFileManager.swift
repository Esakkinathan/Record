//
//  AppFileManager.swift
//  record
//
//  Created by Esakkinathan B on 02/03/26.
//
import Foundation
import UIKit

enum AppFileDirectory: String {
    case docs = "GovtDocs"
    case medicalReciept = "MedicalReciept"
}

class AppFileManager {
    func saveFileLocally(sourceURL: URL, directory: AppFileDirectory, name: String) -> String? {
        let fileManager = FileManager.default
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = documentsDir.appendingPathComponent(directory.rawValue, isDirectory: true)
        
        do {
            if !fileManager.fileExists(atPath: dir.path) {
                try fileManager.createDirectory(at: dir,withIntermediateDirectories: true,attributes: nil)
            }
            let name = name.replacingOccurrences(of: " ", with: "")
            let fileName = "\(name).\(sourceURL.pathExtension)"
            let destinationURL = dir.appendingPathComponent(fileName)

            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }

            try fileManager.copyItem(at: sourceURL, to: destinationURL)

            return relativePath(from: destinationURL)

        } catch {
            print("File save failed:", error)
            return nil
        }
    }
    func relativePath(from url: URL) -> String? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        return url.path.replacingOccurrences(of: documentsURL.path + "/", with: "")
    }
    
    func saveImage(_ image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: SettingsManager.shared.compressionLevel.value) else { return nil }
        
        let fileName = UUID().uuidString + ".jpg"
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempURL)
           // print("Temp saved at:", tempURL)
            return tempURL
            //didPickDocument(url: tempURL)
        } catch {
            print("Error saving temp image:", error)
            return nil
        }

    }
    
    func removeFile(name: String, type: AppFileDirectory) {
        let fileManager = FileManager.default
        
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let directoryURL = documentsDir.appendingPathComponent(type.rawValue, isDirectory: true)
        
        let fileURL = directoryURL.appendingPathComponent(name)
        
        do {
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
                print("File removed successfully")
            } else {
                print("File not found")
            }
        } catch {
            print("Error removing file:", error)
        }
    }
    func saveFile(pdfData: Data) -> URL? {
        let name = UUID().uuidString + ".pdf"
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(name)
        
        do {
            try pdfData.write(to: tempURL)
            print("Temp saved at:", tempURL)
            return tempURL
        } catch {
            print("Error saving temp image:", error)
            return nil
        }
    }

}
