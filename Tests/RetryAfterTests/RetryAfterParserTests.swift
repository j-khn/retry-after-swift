import Foundation
import XCTest
import RetryAfter

final class RetryAfterParserTests: XCTestCase {
    private func date(_ value: String) -> Date {
        ISO8601DateFormatter().date(from: value)!
    }

    func testDeltaSecondsTrimsWhitespaceAndRejectsOverflow() {
        let now = date("2015-10-21T07:27:00Z")
        XCTAssertEqual(RetryAfterParser.parse("  12	", now: now)?.seconds, 12)
        XCTAssertNil(RetryAfterParser.parse("-1", now: now))
        XCTAssertNil(RetryAfterParser.parse("9223372036854775808", now: now))
    }

    func testAllHTTPDateFormsUseInjectedClock() {
        let now = date("2015-10-21T07:27:00Z")
        let fields = [
            "Wed, 21 Oct 2015 07:28:00 GMT",
            "Wednesday, 21-Oct-15 07:28:00 GMT",
            "Wed Oct 21 07:28:00 2015"
        ]
        for field in fields {
            XCTAssertEqual(RetryAfterParser.parse(field, now: now)?.seconds, 60, field)
        }
    }

    func testPastDateClampsToZeroAndMalformedDateIsRejected() {
        let now = date("2015-10-21T07:29:00Z")
        XCTAssertEqual(
            RetryAfterParser.parse("Wed, 21 Oct 2015 07:28:00 GMT", now: now)?.seconds,
            0
        )
        XCTAssertNil(RetryAfterParser.parse("not a date", now: now))
    }
}
