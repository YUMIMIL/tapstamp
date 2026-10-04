import Foundation

/// ラベルに選べるプリセット色。rawValue は保存用の hex 文字列。
enum LabelColor: String, CaseIterable, Identifiable, Sendable {
    case red = "#E5484D"
    case orange = "#F76B15"
    case amber = "#D08700"
    case green = "#30A46C"
    case teal = "#12A594"
    case blue = "#3E63DD"
    case purple = "#8E4EC6"
    case pink = "#D6409F"

    var id: String { rawValue }
    var hex: String { rawValue }

    var name: String {
        switch self {
        case .red: return "レッド"
        case .orange: return "オレンジ"
        case .amber: return "アンバー"
        case .green: return "グリーン"
        case .teal: return "ティール"
        case .blue: return "ブルー"
        case .purple: return "パープル"
        case .pink: return "ピンク"
        }
    }

    /// 「とりあえず記録」（ラベルなし）に使うグレー。
    static let unlabeledHex = "#6B7280"

    init?(hex: String) {
        self.init(rawValue: hex.uppercased())
    }
}
