import Foundation

/// ふりかえり画面の表示方法。
enum DisplayMode: String, CaseIterable, Codable, Sendable, Identifiable {
    /// 回数を見たいもの（トイレ、薬、くしゃみ など）
    case frequency
    /// 間隔を見たいもの（シーツ交換、歯ブラシ交換 など）
    case interval

    var id: String { rawValue }

    var title: String {
        switch self {
        case .frequency: return "回数を見る"
        case .interval: return "間隔を見る"
        }
    }

    var caption: String {
        switch self {
        case .frequency: return "今日の回数、日別の回数、時間帯の傾向を表示します。"
        case .interval: return "前回から何日経ったか、平均の間隔を表示します。"
        }
    }
}
