//
//  HashManager.swift
//  record
//
//  Created by Esakkinathan B on 13/02/26.
//
import CryptoKit
import Foundation

class HashManager {
    static func hash(for input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
