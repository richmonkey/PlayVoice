import UIKit

// MARK: - Design tokens matching the UI spec (§3 – Modern Sci-Fi / Minimal Tech)

enum AppTheme {

    // ── Colors ─────────────────────────────────────────────────────────────

    enum Color {
        // Backgrounds
        static let background   = dynamic(light: 0xF6F7FA, dark: 0x0F1118)
        static let card         = dynamic(light: 0xFFFFFF, dark: 0x1C1F2E)
        static let cardAlt      = dynamic(light: 0xF0F4FF, dark: 0x232741)
        static let overlay      = UIColor.black.withAlphaComponent(0.52)

        // Brand
        static let brand        = dynamic(light: 0x2570FF, dark: 0x3B82FF)
        static let brandLight   = dynamic(light: 0xE8F0FF, dark: 0x1A2545)
        static let brandMid     = dynamic(light: 0x4D8DFF, dark: 0x5B9BFF)

        // Semantic
        static let success      = dynamic(light: 0x00C48C, dark: 0x0ECC96)
        static let warning      = dynamic(light: 0xFF9500, dark: 0xFFAA00)
        static let danger       = dynamic(light: 0xF53F3F, dark: 0xF75656)
        static let dangerLight  = dynamic(light: 0xFFF0F0, dark: 0x2D1616)

        // Text
        static let textPrimary   = dynamic(light: 0x1D2129, dark: 0xFFFFFF)
        static let textSecondary = dynamic(light: 0x4E5969, dark: 0xC9CDD4)
        static let textTertiary  = dynamic(light: 0x86909C, dark: 0x6B7480)

        // Borders / dividers
        static let border        = dynamic(light: 0xE5E6EB, dark: 0x2C2F3E)
        static let borderFocus   = dynamic(light: 0x2570FF, dark: 0x3B82FF)

        // Navigation bar
        static let navBar        = dynamic(light: 0xFFFFFF, dark: 0x13161F)

        private static func dynamic(light: UInt32, dark: UInt32) -> UIColor {
            UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(hex: dark)
                : UIColor(hex: light) }
        }
    }

    // ── Typography ─────────────────────────────────────────────────────────

    enum Font {
        static func largeTitle()  -> UIFont { .systemFont(ofSize: 24, weight: .bold) }
        static func title1()      -> UIFont { .systemFont(ofSize: 20, weight: .bold) }
        static func title2()      -> UIFont { .systemFont(ofSize: 17, weight: .semibold) }
        static func headline()    -> UIFont { .systemFont(ofSize: 15, weight: .semibold) }
        static func body()        -> UIFont { .systemFont(ofSize: 15, weight: .regular) }
        static func callout()     -> UIFont { .systemFont(ofSize: 14, weight: .regular) }
        static func subheadline() -> UIFont { .systemFont(ofSize: 13, weight: .regular) }
        static func footnote()    -> UIFont { .systemFont(ofSize: 12, weight: .regular) }
        static func caption()     -> UIFont { .systemFont(ofSize: 11, weight: .regular) }
        static func captionMed()  -> UIFont { .systemFont(ofSize: 11, weight: .medium) }
    }

    // ── Layout ─────────────────────────────────────────────────────────────

    enum Radius {
        static let card:   CGFloat = 12
        static let button: CGFloat = 8
        static let chip:   CGFloat = 6
        static let avatar: CGFloat = 10
    }

    enum Shadow {
        static func card(on view: UIView) {
            view.layer.shadowColor   = UIColor.black.cgColor
            view.layer.shadowOffset  = CGSize(width: 0, height: 2)
            view.layer.shadowRadius  = 8
            view.layer.shadowOpacity = 0.06
            view.layer.masksToBounds = false
        }
        static func elevated(on view: UIView) {
            view.layer.shadowColor   = UIColor.black.cgColor
            view.layer.shadowOffset  = CGSize(width: 0, height: 4)
            view.layer.shadowRadius  = 16
            view.layer.shadowOpacity = 0.10
            view.layer.masksToBounds = false
        }
    }

    enum Spacing {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // ── Helpers ────────────────────────────────────────────────────────────

    static func applyNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor        = Color.navBar
        appearance.titleTextAttributes    = [
            .foregroundColor: Color.textPrimary,
            .font: Font.title2()
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: Color.textPrimary,
            .font: Font.largeTitle()
        ]
        appearance.shadowColor = Color.border
        UINavigationBar.appearance().standardAppearance   = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance    = appearance
        UINavigationBar.appearance().tintColor            = Color.brand
    }
}
