import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

enum Theme {

    // MARK: - Color Tokens

    static let primary = Color(hex: "#EA580C")
    static let secondary = Color(hex: "#F97316")
    static let success = Color(hex: "#059669")
    static let background = Color(hex: "#0F172A")
    static let foreground = Color.white
    static let card = Color(hex: "#192134")
    static let muted = Color(hex: "#201C27")
    static let mutedForeground = Color(hex: "#94A3B8")
    static let border = Color.white.opacity(0.08)
    static let destructive = Color(hex: "#DC2626")
    static let ring = Color(hex: "#EA580C")
    static let repInProgress = Color(hex: "#3B82F6")
    static let repNotStarted = Color(hex: "#374151")

    // MARK: - Typography

    static var repCounter: Font {
        .system(size: 64, weight: .bold, design: .rounded)
    }

    static var stateLabel: Font {
        .title.weight(.semibold)
    }

    static var paceDisplay: Font {
        .system(size: 32, weight: .medium, design: .monospaced)
    }

    static var buttonText: Font {
        .title2.weight(.bold)
    }

    static var secondaryLabel: Font {
        .callout
    }
}
