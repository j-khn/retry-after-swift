# Retry-After Swift

> **Status:** Early-stage reference implementation; APIs may change.

A tiny Foundation-only parser for the HTTP Retry-After response field.

Retry timing looks simple until a server sends an HTTP date, a past date, whitespace, or an integer too large to fit. This package parses a single field value, reports how it was represented, and lets callers inject the current time for deterministic behavior.

## ✨ Example

~~~swift
let now = Date(timeIntervalSince1970: 1_700_000_000)

let delay = RetryAfterParser.parse("Wed, 21 Oct 2015 07:28:00 GMT", now: now)
print(delay?.seconds) // 0.0: the advertised date has already passed

let shortDelay = RetryAfterParser.parse("12", now: now)
print(shortDelay?.seconds) // 12.0
~~~

Malformed values return nil. Past dates clamp to zero. Delta-seconds are parsed with overflow checks.

## Supported date forms

The parser accepts the three HTTP-date forms specified for HTTP recipients: IMF-fixdate, obsolete RFC 850, and obsolete asctime. It trims optional spaces and tabs around a field value.

## Install

~~~swift
.package(url: "https://github.com/j-khn/retry-after-swift.git", branch: "main")
~~~

Then import RetryAfter.

## Scope and limits

This package parses one field value; it does not combine duplicate header fields, schedule retries, choose backoff, or decide whether a response is retryable. Point-Free’s [swift-clocks](https://github.com/pointfreeco/swift-clocks) provides controllable clocks for async code, a different layer of the retry problem. Keep retry policy in the HTTP client that knows the request and server.

## Compatibility

Swift 6.0+, iOS 15+, and macOS 12+.

## License

MIT.
