import Foundation
import Security

/// API Key 的唯一存取入口。保存在 iOS 钥匙串（kSecClassGenericPassword），
/// 绝不写入 UserDefaults 或数据库。key 以服务商 id 区分。
enum KeychainService {
    private static let service = "com.glasschat.apikey"

    static func saveKey(_ key: String, for providerID: String) {
        let data = Data(key.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: providerID,
        ]
        let update: [String: Any] = [kSecValueData as String: data]
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == errSecSuccess {
            SecItemUpdate(query as CFDictionary, update as CFDictionary)
        } else {
            SecItemAdd(query.merging(update) { $1 } as CFDictionary, nil)
        }
    }

    static func loadKey(for providerID: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: providerID,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func deleteKey(for providerID: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: providerID,
        ]
        SecItemDelete(query as CFDictionary)
    }

    /// 展示用：只露尾 4 位
    static func maskedKey(_ key: String?) -> String {
        guard let key, key.count > 8 else { return "未配置" }
        return "sk-••••" + String(key.suffix(4))
    }
}
