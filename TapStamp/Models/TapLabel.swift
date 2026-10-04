import Foundation

/// 現行スキーマのラベル型。画面やサービスからはこの名前で使う。
typealias TapLabel = TapStampSchemaV1.TapLabel

extension TapLabel {
    var displayMode: DisplayMode {
        get { DisplayMode(rawValue: displayModeRaw) ?? .frequency }
        set { displayModeRaw = newValue.rawValue }
    }

    var labelColor: LabelColor {
        LabelColor(hex: colorHex) ?? .blue
    }
}
