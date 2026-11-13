// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RetryAfterSwift",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "RetryAfter", targets: ["RetryAfter"])
    ],
    targets: [
        .target(name: "RetryAfter"),
        .testTarget(name: "RetryAfterTests", dependencies: ["RetryAfter"])
    ]
)
