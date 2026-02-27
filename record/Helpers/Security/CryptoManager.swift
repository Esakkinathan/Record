//
//  CryptoManager.swift
//  record
//
//  Created by Esakkinathan B on 27/02/26.
//

import CryptoKit
import Foundation

class CryptoManager {
    
    static func encrypt(text: String) throws -> String {
        let key = KeychainManager.shared.getPassword()
        guard let key = key else { return "" }
        let symmetricKey = SymmetricKey(data: key)
        
        let data = Data(text.utf8)
        let sealedBox = try AES.GCM.seal(data, using: symmetricKey)
        
        guard let combined = sealedBox.combined else {
            throw NSError(domain: "EncryptionError", code: -1)
        }
        
        return combined.base64EncodedString()
    }
    
    
    static func decrypt(baseString: String) throws -> String {
        let key = KeychainManager.shared.getPassword()
        
        guard let key = key else { return "" }
        
        let symmetricKey = SymmetricKey(data: key)

        guard let encryptedData = Data(base64Encoded: baseString) else {
            throw NSError(domain: "InvalidBase64", code: -1)
        }
        
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
        
        guard let result = String(data: decryptedData, encoding: .utf8) else {
            throw NSError(domain: "StringConversionError", code: -1)
        }
        
        return result
    }
}
