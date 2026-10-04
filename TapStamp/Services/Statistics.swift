import Foundation

/// 1 日分の回数。
struct DayCount: Identifiable, Equatable {
    /// その日の 0:00
    let date: Date
    let count: Int
    var id: Date { date }
}

/// 曜日 × 時間帯 の 1 マス。
struct HeatmapCell: Identifiable, Equatable {
    /// `Calendar.component(.weekday)` と同じ。1 = 日曜 … 7 = 土曜
    let weekday: Int
    /// 0 ... 23
    let hour: Int
    let count: Int
    var id: Int { weekday * 100 + hour }
}

/// 間隔の要約。
struct IntervalSummary: Equatable {
    let average: TimeInterval?
    let shortest: TimeInterval?
    let longest: TimeInterval?
    /// 計算に使った間隔の数
    let sampleCount: Int

    static let empty = IntervalSummary(average: nil, shortest: nil, longest: nil, sampleCount: 0)
}

/// 集計ロジック。SwiftData に依存せず `[Date]` を入力にする純粋関数の集まり。
enum Statistics {
    // MARK: - 回数

    /// `now` と同じ日の件数。
    static func todayCount(_ timestamps: [Date], now: Date = .now, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: now)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return 0 }
        return timestamps.filter { $0 >= start && $0 < end }.count
    }

    /// 今日を含む直近 `days` 日の件数。
    static func recentDaysCount(_ timestamps: [Date], days: Int, now: Date = .now, calendar: Calendar = .current) -> Int {
        dailyCounts(timestamps, days: days, now: now, calendar: calendar).reduce(0) { $0 + $1.count }
    }

    /// 今日を含む直近 `days` 日の日別件数。古い日から順、件数 0 の日も含む。
    static func dailyCounts(_ timestamps: [Date], days: Int = 7, now: Date = .now, calendar: Calendar = .current) -> [DayCount] {
        let today = calendar.startOfDay(for: now)
        guard days > 0,
              let first = calendar.date(byAdding: .day, value: -(days - 1), to: today) else { return [] }

        var buckets: [Date: Int] = [:]
        for timestamp in timestamps where timestamp >= first {
            buckets[calendar.startOfDay(for: timestamp), default: 0] += 1
        }

        return (0..<days).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: first) else { return nil }
            return DayCount(date: day, count: buckets[day] ?? 0)
        }
    }

    /// 今日を含む直近 `weeks` 週の 曜日 × 時間帯 件数。常に 7 × 24 = 168 マス返す。
    static func weekdayHourCounts(_ timestamps: [Date], weeks: Int = 4, now: Date = .now, calendar: Calendar = .current) -> [HeatmapCell] {
        let today = calendar.startOfDay(for: now)
        guard weeks > 0,
              let start = calendar.date(byAdding: .day, value: -(weeks * 7 - 1), to: today) else { return [] }

        var counts = [Int](repeating: 0, count: 7 * 24)
        for timestamp in timestamps where timestamp >= start {
            let components = calendar.dateComponents([.weekday, .hour], from: timestamp)
            guard let weekday = components.weekday, let hour = components.hour,
                  (1...7).contains(weekday), (0..<24).contains(hour) else { continue }
            counts[(weekday - 1) * 24 + hour] += 1
        }

        var cells: [HeatmapCell] = []
        cells.reserveCapacity(7 * 24)
        for weekday in 1...7 {
            for hour in 0..<24 {
                cells.append(HeatmapCell(weekday: weekday, hour: hour, count: counts[(weekday - 1) * 24 + hour]))
            }
        }
        return cells
    }

    // MARK: - 間隔

    /// 連続する記録どうしの間隔（秒）。古い順。
    static func intervals(_ timestamps: [Date]) -> [TimeInterval] {
        let sorted = timestamps.sorted()
        guard sorted.count >= 2 else { return [] }
        return zip(sorted.dropFirst(), sorted).map { later, earlier in
            later.timeIntervalSince(earlier)
        }
    }

    /// 直近 `recentLimit` 個の間隔から平均・最短・最長を出す。
    static func intervalSummary(_ timestamps: [Date], recentLimit: Int = 10) -> IntervalSummary {
        let recent = Array(intervals(timestamps).suffix(max(0, recentLimit)))
        guard !recent.isEmpty else { return .empty }
        return IntervalSummary(
            average: recent.reduce(0, +) / Double(recent.count),
            shortest: recent.min(),
            longest: recent.max(),
            sampleCount: recent.count
        )
    }

    /// `date` から `now` までの暦日の差（23:00 → 翌 1:00 なら 1）。
    static func daysSince(_ date: Date, now: Date = .now, calendar: Calendar = .current) -> Int {
        let from = calendar.startOfDay(for: date)
        let to = calendar.startOfDay(for: now)
        return calendar.dateComponents([.day], from: from, to: to).day ?? 0
    }

    /// 最新の日時。
    static func latest(_ timestamps: [Date]) -> Date? {
        timestamps.max()
    }
}
