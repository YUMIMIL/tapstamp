import Foundation

/// ラベルに選べるプリセット色（くすみ系）。rawValue は保存用の hex 文字列。
enum LabelColor: String, CaseIterable, Identifiable, Sendable {
    case blue = "#6F94C2"
    case green = "#8DAA8E"
    case coral = "#D4857C"
    case lavender = "#A594C9"
    case sand = "#D9A76A"
    case teal = "#7FB8B2"
    case rose = "#C98BA3"
    case slate = "#8A94A6"

    var id: String { rawValue }
    var hex: String { rawValue }

    var name: String {
        switch self {
        case .blue: return "ブルー"
        case .green: return "グリーン"
        case .coral: return "コーラル"
        case .lavender: return "ラベンダー"
        case .sand: return "サンド"
        case .teal: return "ティール"
        case .rose: return "ローズ"
        case .slate: return "スレート"
        }
    }

    /// 「とりあえず記録」（ラベルなし）に使うスチールブルー。
    static let unlabeledHex = "#5B7FA6"

    init?(hex: String) {
        self.init(rawValue: hex.uppercased())
    }
}
