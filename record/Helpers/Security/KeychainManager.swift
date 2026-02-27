//
//  KeychainManager.swift
//  record
//
//  Created by Esakkinathan B on 27/02/26.
//

import Foundation
import Security

final class KeychainManager {
    
    static let shared = KeychainManager()
    private init() {}
    
    let key = "masterPassword"
    
    @discardableResult
    func savePassword(_ password: String) -> Bool {
        
        let data = HashManager.hash(for: password)
        //guard let data = hashed else { return false }
                
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func getPassword() -> Data? {
        deletePassword()
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data else{
            return nil
        }
        
        return data
    }
    
    @discardableResult
    func deletePassword() -> Bool {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
