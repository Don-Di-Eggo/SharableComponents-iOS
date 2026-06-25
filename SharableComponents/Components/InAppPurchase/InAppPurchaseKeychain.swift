import Foundation
import Security

/// Thin Keychain wrapper for persisting trial state across app reinstalls.
/// Keychain items survive deletion by default on iOS — UserDefaults does not.
struct InAppPurchaseKeychain {

    let service: String

    // MARK: - Typed accessors

    func setInt(_ value: Int, forKey key: String) {
        set(Data(bytes: value), forKey: key)
    }

    func int(forKey key: String) -> Int? {
        data(forKey: key).flatMap { $0.value(as: Int.self) }
    }

    func setString(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }
        set(data, forKey: key)
    }

    func string(forKey key: String) -> String? {
        data(forKey: key).flatMap { String(data: $0, encoding: .utf8) }
    }

    func setDate(_ value: Date, forKey key: String) {
        set(Data(bytes: value.timeIntervalSinceReferenceDate), forKey: key)
    }

    func date(forKey key: String) -> Date? {
        data(forKey: key)
            .flatMap { $0.value(as: Double.self) }
            .map { Date(timeIntervalSinceReferenceDate: $0) }
    }

    func remove(forKey key: String) {
        SecItemDelete(query(forKey: key) as CFDictionary)
    }

    func removeAll(keys: [String]) {
        keys.forEach { remove(forKey: $0) }
    }

    // MARK: - Private

    private func set(_ data: Data, forKey key: String) {
        let base = query(forKey: key)
        if SecItemCopyMatching(base as CFDictionary, nil) == errSecSuccess {
            SecItemUpdate(base as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        } else {
            var item = base
            item[kSecValueData as String] = data
            SecItemAdd(item as CFDictionary, nil)
        }
    }

    private func data(forKey key: String) -> Data? {
        var item = query(forKey: key)
        item[kSecReturnData as String] = true
        item[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(item as CFDictionary, &result) == errSecSuccess else { return nil }
        return result as? Data
    }

    private func query(forKey key: String) -> [String: Any] {
        [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
    }
}

// MARK: - Data helpers

private extension Data {
    init<T>(bytes value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }

    func value<T>(as type: T.Type) -> T? {
        guard count >= MemoryLayout<T>.size else { return nil }
        return withUnsafeBytes { $0.load(as: T.self) }
    }
}
