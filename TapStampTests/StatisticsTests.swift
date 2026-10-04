import Foundation
import Testing
@testable import TapStamp

@Suite("Statistics")
struct StatisticsTests {
    let calendar = makeTestCalendar()

    private func date(_ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
        makeDate(2026, month, day, hour, minute, calendar: calendar)
    }

    @Test("今日の回数は当日 0:00〜23:59 だけを数える")
    func todayCount() {
        let now = date(10, 4, 15, 0)
        let timestamps = [
            date(10, 4, 0, 0),
            date(10, 4, 23, 59),
            date(10, 3, 23, 59),
            date(10, 5, 0, 0),
        ]
        #expect(Statistics.todayCount(timestamps, now: now, calendar: calendar) == 2)
        #expect(Statistics.todayCount([], now: now, calendar: calendar) == 0)
    }

    @Test("日別回数は 7 日分を 0 埋めで古い順に返す")
    func dailyCounts() {
        let now = date(10, 4, 12, 0)
        let timestamps = [
            date(10, 4, 9, 0), date(10, 4, 10, 0),
            date(10, 1, 8, 0),
            date(9, 28, 23, 59),
            date(9, 27, 23, 59), // 範囲外
        ]
        let counts = Statistics.dailyCounts(timestamps, days: 7, now: now, calendar: calendar)

        #expect(counts.count == 7)
        #expect(counts.first?.date == date(9, 28))
        #expect(counts.last?.date == date(10, 4))
        #expect(counts.map(\.count) == [1, 0, 0, 1, 0, 0, 2])
    }

    @Test("曜日×時間帯は常に 168 マスで、該当マスだけ増える")
    func weekdayHourCounts() {
        let now = date(10, 4, 12, 0) // 2026-10-04 は日曜
        let timestamps = [
            date(10, 4, 9, 30),  // 日曜 9 時
            date(10, 4, 9, 45),  // 日曜 9 時
            date(10, 3, 22, 0),  // 土曜 22 時
            date(9, 1, 9, 0),    // 範囲外（4 週より前）
        ]
        let cells = Statistics.weekdayHourCounts(timestamps, weeks: 4, now: now, calendar: calendar)

        #expect(cells.count == 168)
        #expect(cells.first { $0.weekday == 1 && $0.hour == 9 }?.count == 2)
        #expect(cells.first { $0.weekday == 7 && $0.hour == 22 }?.count == 1)
        #expect(cells.reduce(0) { $0 + $1.count } == 3)
    }

    @Test("間隔は古い順の差分、要約は直近 N 個から計算する")
    func intervals() {
        let timestamps = [
            date(10, 1, 0, 0),
            date(10, 3, 0, 0),  // +2 日
            date(10, 2, 0, 0),  // 順不同で渡しても並べ替える
            date(10, 7, 0, 0),  // +4 日
        ]
        let day: TimeInterval = 86_400
        let intervals = Statistics.intervals(timestamps)
        #expect(intervals == [day, day, 4 * day])

        let summary = Statistics.intervalSummary(timestamps, recentLimit: 2)
        #expect(summary.sampleCount == 2)
        #expect(summary.shortest == day)
        #expect(summary.longest == 4 * day)
        #expect(summary.average == 2.5 * day)

        #expect(Statistics.intervalSummary([date(10, 1)]) == .empty)
    }

    @Test("日付差は暦日で数える")
    func daysSince() {
        #expect(Statistics.daysSince(date(10, 3, 23, 0), now: date(10, 4, 1, 0), calendar: calendar) == 1)
        #expect(Statistics.daysSince(date(10, 4, 0, 0), now: date(10, 4, 23, 59), calendar: calendar) == 0)
        #expect(Statistics.daysSince(date(9, 20), now: date(10, 4), calendar: calendar) == 14)
    }
}
