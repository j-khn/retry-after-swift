import Foundation

public enum RetryAfterSource: String, Sendable, Equatable {
    case deltaSeconds
    case httpDate
}

public struct RetryDelay: Sendable, Equatable {
    public let seconds: TimeInterval
    public let source: RetryAfterSource

    public init(seconds: TimeInterval, source: RetryAfterSource) {
        self.seconds = seconds
        self.source = source
    }
}

public enum RetryAfterParser {
    /// Parses one Retry-After field value. Pass the current wall clock
    /// explicitly in tests so date-based values are deterministic.
    public static func parse(_ field: String, now: Date = Date()) -> RetryDelay? {
        let value = field.trimmingCharacters(in: CharacterSet(charactersIn: " \t"))
        guard !value.isEmpty else { return nil }

        let bytes = Array(value.utf8)
        if bytes.allSatisfy({ $0 >= 48 && $0 <= 57 }) {
            var seconds: Int64 = 0
            for byte in bytes {
                let digit = Int64(byte - 48)
                guard seconds <= (Int64.max - digit) / 10 else { return nil }
                seconds = seconds * 10 + digit
            }
            return RetryDelay(seconds: TimeInterval(seconds), source: .deltaSeconds)
        }

        guard let date = parseHTTPDate(value) else { return nil }
        return RetryDelay(seconds: max(0, date.timeIntervalSince(now)), source: .httpDate)
    }

    private static func parseHTTPDate(_ value: String) -> Date? {
        let formats = [
            "EEE, dd MMM yyyy HH:mm:ss zzz",
            "EEEE, dd-MMM-yy HH:mm:ss zzz",
            "EEE MMM d HH:mm:ss yyyy"
        ]

        for format in formats {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.isLenient = false
            formatter.dateFormat = format
            if let date = formatter.date(from: value) {
                return date
            }
        }
        return nil
    }
}

// Exercise changed-source selection in the mutation action.
