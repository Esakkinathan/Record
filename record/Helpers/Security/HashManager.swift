//
//  HashManager.swift
//  record
//
//  Created by Esakkinathan B on 13/02/26.
//
import CryptoKit
import Foundation

class HashManager {
    static func hash(for pin: String) -> Data {
        let pinData = Data(pin.utf8)
        let hash = SHA256.hash(data: pinData)
        return Data(hash) // ✅ 32 raw bytes
    }}
