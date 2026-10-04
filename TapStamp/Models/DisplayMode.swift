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
        case .frequency: return "回数・頻度"
        case .interval: return "間隔"
        }
    }

    var caption: String {
        switch self {
        case .frequency: return "1日に何回あったかを見る"
        case .interval: return "前回からどれくらい経ったかを見る"
        }
    }
}
