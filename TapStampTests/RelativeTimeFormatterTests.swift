import Foundation
import Testing
@testable import TapStamp

@Suite("RelativeTimeFormatter")
struct RelativeTimeFormatterTests {
    let calendar = makeTestCalendar()

    private func date(_ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0, _ second: Int = 0) -> Date {
        makeDate(2026, month, day, hour, minute, second, calendar: calendar)
    }

    @Test("〜前 の表現")
    func ago() {
        let now = date(10, 4, 15, 0)
        #expect(RelativeTimeFormatter.ago(from: date(10, 4, 14, 59, 30), to: now, calendar: calendar) == "たった今")
        #expect(RelativeTimeFormatter.ago(from: date(10, 4, 14, 57), to: now, calendar: calendar) == "3分前")
        #expect(RelativeTimeFormatter.ago(from: date(10, 4, 13, 0), to: now, calendar: calendar) == "2時間前")
        #expect(RelativeTimeFormatter.ago(from: date(10, 3, 14, 0), to: now, calendar: calendar) == "昨日")
        #expect(RelativeTimeFormatter.ago(from: date(9, 29, 15, 0), to: now, calendar: calendar) == "5日前")
        #expect(RelativeTimeFormatter.ago(from: date(8, 1, 15, 0), to: now, calendar: calendar) == "2か月前")
    }

    @Test("経過時間の表現")
    func elapsed() {
        let now = date(10, 4, 15, 0)
        #expect(RelativeTimeFormatter.elapsed(from: date(10, 4, 14, 59, 50), to: now) == "1分未満")
        #expect(RelativeTimeFormatter.elapsed(from: date(10, 4, 14, 15), to: now) == "45分")
        #expect(RelativeTimeFormatter.elapsed(from: date(10, 4, 13, 48), to: now) == "1時間12分")
        #expect(RelativeTimeFormatter.elapsed(from: date(10, 4, 13, 0), to: now) == "2時間")
        #expect(RelativeTimeFormatter.elapsed(from: date(10, 1, 11, 0), to: now) == "3日4時間")
    }

    @Test("時刻は 24 時間表記")
    func clock() {
        #expect(RelativeTimeFormatter.clock(date(10, 4, 14, 32)) == "14:32")
        #expect(RelativeTimeFormatter.clock(date(10, 4, 9, 5)) == "09:05")
    }

    @Test("秒数の短い表現")
    func duration() {
        #expect(RelativeTimeFormatter.duration(14.2 * 86_400) == "14.2日")
        #expect(RelativeTimeFormatter.duration(3.5 * 3_600) == "3.5時間")
        #expect(RelativeTimeFormatter.duration(40 * 60) == "40分")
    }
}
