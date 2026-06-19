import UIKit

enum ThemeMode: String, CaseIterable {
    case system = "system"
    case light  = "light"
    case dark   = "dark"

    var displayName: String {
        switch self {
        case .system: return "Follow System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

final class ThemeManager {
    static let shared = ThemeManager()
    static let didChangeNotification = Notification.Name("ThemeManagerDidChange")

    private let key = "app_theme_mode"

    var current: ThemeMode {
        get {
            let raw = UserDefaults.standard.string(forKey: key) ?? ThemeMode.system.rawValue
            return ThemeMode(rawValue: raw) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
            apply(newValue)
            NotificationCenter.default.post(name: Self.didChangeNotification, object: newValue)
        }
    }

    func apply(_ mode: ThemeMode? = nil) {
        let m = mode ?? current
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .forEach { $0.overrideUserInterfaceStyle = m.interfaceStyle }
    }
}
