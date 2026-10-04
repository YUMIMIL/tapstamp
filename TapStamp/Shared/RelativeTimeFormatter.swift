import Foundation

/// 日本語の相対時間表現。
enum RelativeTimeFormatter {
    /// 「たった今」「3分前」「2時間前」「昨日」「5日前」「2か月前」「1年前」
    static func ago(from date: Date, to now: Date = .now, calendar: Calendar = .current) -> String {
        let seconds = now.timeIntervalSince(date)
        if seconds < 60 { return "たった今" }

        let minutes = Int(seconds / 60)
        if minutes < 60 { return "\(minutes)分前" }

        let hours = Int(seconds / 3600)
        if hours < 24 { return "\(hours)時間前" }

        let days = Statistics.daysSince(date, now: now, calendar: calendar)
        if days <= 1 { return "昨日" }
        if days < 30 { return "\(days)日前" }

        let months = days / 30
        if months < 12 { return "\(months)か月前" }
        return "\(days / 365)年前"
    }

    /// 経過時間を「45分」「1時間12分」「3日4時間」のように表す。1 分未満は「1分未満」。
    static func elapsed(from date: Date, to now: Date = .now) -> String {
        let total = max(0, Int(now.timeIntervalSince(date)))
        let days = total / 86_400
        let hours = (total % 86_400) / 3_600
        let minutes = (total % 3_600) / 60

        if days > 0 {
            return hours > 0 ? "\(days)日\(hours)時間" : "\(days)日"
        }
        if hours > 0 {
            return minutes > 0 ? "\(hours)時間\(minutes)分" : "\(hours)時間"
        }
        if minutes > 0 {
            return "\(minutes)分"
        }
        return "1分未満"
    }

    /// 秒数を「14.2日」「3.5時間」「40分」のように表す（平均間隔などに使う）。
    static func duration(_ interval: TimeInterval) -> String {
        let seconds = max(0, interval)
        if seconds >= 86_400 {
            return String(format: "%.1f日", seconds / 86_400)
        }
        if seconds >= 3_600 {
            return String(format: "%.1f時間", seconds / 3_600)
        }
        return "\(Int(seconds / 60))分"
    }

    /// 「14:32」固定（端末の 12/24 時間設定に依存しない）。
    static func clock(_ date: Date) -> String {
        clockFormatter.string(from: date)
    }

    /// 「10月4日(土)」
    static func monthDayWeekday(_ date: Date) -> String {
        monthDayWeekdayFormatter.string(from: date)
    }

    /// 「2026年10月4日(土) 14:32」
    static func full(_ date: Date) -> String {
        fullFormatter.string(from: date)
    }

    private static let clockFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let monthDayWeekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
        return formatter
    }()

    private static let fullFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日(E) HH:mm"
        return formatter
    }()
}
