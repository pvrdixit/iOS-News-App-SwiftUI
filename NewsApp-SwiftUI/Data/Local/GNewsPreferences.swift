import Foundation

/// Stores the user-selected GNews country and language codes between app launches.
enum GNewsPreferences {
    private static let countryCodeKey = "gnews.selectedCountryCode"
    private static let languageCodeKey = "gnews.selectedLanguageCode"

    static func countryCode(default fallback: String, userDefaults: UserDefaults = .standard) -> String {
        userDefaults.string(forKey: countryCodeKey) ?? fallback
    }

    static func languageCode(default fallback: String, userDefaults: UserDefaults = .standard) -> String {
        userDefaults.string(forKey: languageCodeKey) ?? fallback
    }

    static func setCountryCode(_ code: String, userDefaults: UserDefaults = .standard) {
        userDefaults.set(code, forKey: countryCodeKey)
    }

    static func setLanguageCode(_ code: String, userDefaults: UserDefaults = .standard) {
        userDefaults.set(code, forKey: languageCodeKey)
    }
}
