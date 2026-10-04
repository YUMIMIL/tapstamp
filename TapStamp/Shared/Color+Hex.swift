import SwiftUI

extension Color {
    /// "#RRGGBB" / "RRGGBB" から生成。解釈できなければ nil。
    init?(hex: String) {
        var text = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("#") { text.removeFirst() }
        guard text.count == 6, let value = UInt32(text, radix: 16) else { return nil }
        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }

    init(_ labelColor: LabelColor) {
        self = Color(hex: labelColor.hex) ?? .blue
    }

    /// ラベルなし（とりあえず記録）の色。
    static var unlabeled: Color {
        Color(hex: LabelColor.unlabeledHex) ?? .gray
    }
}

extension TapLabel {
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}
