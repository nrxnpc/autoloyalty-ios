// TokenManager.swift
// Управление токенами аутентификации

import Foundation
import Security

class TokenManager {
    static let shared = TokenManager()
    
    private let tokenKey = "nsp_auth_token"
    private let keychainService = "com.nsp.app"
    
    private init() {}
    
    // MARK: - Public Methods
    
    func saveToken(_ token: String) {
        // Сохраняем в Keychain для безопасности
        if saveToKeychain(token) {
            // Также сохраняем в UserDefaults как fallback
            UserDefaults.standard.set(token, forKey: tokenKey)
        } else {
            // Если Keychain недоступен, используем только UserDefaults
            UserDefaults.standard.set(token, forKey: tokenKey)
        }
    }
    
    func getToken() -> String? {
        // Сначала пытаемся получить из Keychain
        if let keychainToken = getFromKeychain() {
            return keychainToken
        }
        
        // Fallback на UserDefaults
        return UserDefaults.standard.string(forKey: tokenKey)
    }
    
    func removeToken() {
        // Удаляем из Keychain
        deleteFromKeychain()
        
        // Удаляем из UserDefaults
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
    
    func hasToken() -> Bool {
        return getToken() != nil
    }
    
    // MARK: - Keychain Methods
    
    private func saveToKeychain(_ token: String) -> Bool {
        guard let data = token.data(using: .utf8) else { return false }
        
        // Удаляем старое значение
        deleteFromKeychain()
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func getFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    private func deleteFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
