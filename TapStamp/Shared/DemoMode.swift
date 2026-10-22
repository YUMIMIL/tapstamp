import Foundation
import SwiftData

/// App Store 用スクリーンショットを撮るためのデモ画面。
/// 起動引数 `-demoScene <rawValue>` で指定する。デバッグビルドでのみ有効。
enum DemoScene: String {
    /// 記録画面（薬のページ、取り消しトースト表示）
    case record
    /// ふりかえり（回数・頻度、トイレ）
    case review
    /// ふりかえり（間隔、シーツ交換）
    case interval
    /// ラベル編集（薬）
    case labelEdit
    /// 初回のテンプレート選択
    case onboarding

    var initialTab: AppTab {
        switch self {
        case .review, .interval: return .review
        default: return .record
        }
    }

    var recordLabelName: String? {
        self == .record ? DemoData.medicineName : nil
    }

    var reviewLabelName: String? {
        switch self {
        case .review: return DemoData.toiletName
        case .interval: return DemoData.sheetsName
        default: return nil
        }
    }

    var editLabelName: String? {
        self == .labelEdit ? DemoData.medicineName : nil
    }
}

enum DemoMode {
    static var scene: DemoScene? {
        #if DEBUG
        UserDefaults.standard.string(forKey: "demoScene").flatMap(DemoScene.init(rawValue:))
        #else
        nil
        #endif
    }
}

/// スクリーンショット用のサンプルデータ。直近 4 週間ぶんを現在時刻から逆算して作る。
@MainActor
enum DemoData {
    static let medicineName = "薬"
    static let toiletName = "トイレ"
    static let coffeeName = "コーヒー"
    static let sheetsName = "シーツ交換"

    static func seed(into context: ModelContext, now: Date = .now, calendar: Calendar = .current) {
        var rng = SeededGenerator(seed: 20261022)

        let medicine = TapLabel(name: medicineName, colorHex: LabelColor.green.hex, sortOrder: 0, displayMode: .frequency)
        let toilet = TapLabel(name: toiletName, colorHex: LabelColor.teal.hex, sortOrder: 1, displayMode: .frequency)
        let coffee = TapLabel(name: coffeeName, colorHex: LabelColor.sand.hex, sortOrder: 2, displayMode: .frequency)
        let sheets = TapLabel(name: sheetsName, colorHex: LabelColor.lavender.hex, sortOrder: 3, displayMode: .interval)
        for label in [medicine, toilet, coffee, sheets] {
            context.insert(label)
        }

        func add(_ label: TapLabel?, _ date: Date?) {
            guard let date, date < now else { return }
            context.insert(TapRecord(timestamp: date, label: label, createdAt: date))
        }

        let today = calendar.startOfDay(for: now)
        let toiletHours = [7, 8, 10, 12, 13, 15, 17, 19, 21, 22, 23]

        for dayOffset in 0..<28 {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            func at(_ hour: Int, _ minute: Int) -> Date? {
                calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day)
            }

            // 薬: 朝と夜。ときどき飲み忘れ。
            if Int.random(in: 0..<10, using: &rng) > 0 {
                add(medicine, at(8, Int.random(in: 0..<40, using: &rng)))
            }
            if dayOffset > 0, Int.random(in: 0..<10, using: &rng) > 1 {
                add(medicine, at(20, Int.random(in: 0..<50, using: &rng)))
            }

            // トイレ: 1 日 5〜8 回。
            let toiletCount = Int.random(in: 5...8, using: &rng)
            for hour in toiletHours.shuffled(using: &rng).prefix(toiletCount) {
                add(toilet, at(hour, Int.random(in: 0..<60, using: &rng)))
            }

            // コーヒー: 午前と午後に 1〜3 杯。
            let coffeeCount = Int.random(in: 1...3, using: &rng)
            for hour in [9, 13, 16].prefix(coffeeCount) {
                add(coffee, at(hour, Int.random(in: 0..<60, using: &rng)))
            }

            // とりあえず記録: たまに。
            if dayOffset > 0, Int.random(in: 0..<3, using: &rng) == 0 {
                add(nil, at(Int.random(in: 9...21, using: &rng), Int.random(in: 0..<60, using: &rng)))
            }
        }

        // 今日の「とりあえず記録」3 回（前回 42 分前）
        add(nil, now.addingTimeInterval(-42 * 60))
        add(nil, now.addingTimeInterval(-3 * 3600 - 10 * 60))
        add(nil, now.addingTimeInterval(-5 * 3600 - 25 * 60))

        // いま記録した薬（記録画面のトースト用）
        add(medicine, now.addingTimeInterval(-30))

        // シーツ交換: 10〜16 日おき、約 5 か月ぶん
        var sheetDate = calendar.date(byAdding: .day, value: -9, to: now)
        for _ in 0..<11 {
            guard let date = sheetDate else { break }
            add(sheets, calendar.date(bySettingHour: 10, minute: Int.random(in: 0..<60, using: &rng), second: 0, of: date))
            sheetDate = calendar.date(byAdding: .day, value: -Int.random(in: 10...16, using: &rng), to: date)
        }

        try? context.save()
    }
}

/// 毎回同じ並びになる乱数（SplitMix64）。
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
