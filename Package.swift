// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Slackmoji",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "Slackmoji",
            targets: ["Slackmoji"]),
        .executable(name: "Build Shortcode Plist", targets: ["Build Shortcode Plist"])
    ],
    dependencies: [
        .package(url: "https://github.com/Bouke/Glob", branch: "master"),
        .package(url: "https://github.com/Peter-Schorn/RegularExpressions", branch: "master"),
        .package(url: "https://github.com/Quick/Quick.git", from: "4.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.1.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Slackmoji",
            dependencies: ["RegularExpressions"],
        resources: [
            .process("Resources/EmojiToSlackmoji.plist"),
            .process("Resources/SlackmojiToEmoji.plist"),
        ]),
        .executableTarget(
            name: "Build Shortcode Plist",
            dependencies: ["Glob", "RegularExpressions"]
        ),
        .testTarget(
            name: "SlackmojiTests",
            dependencies: ["Slackmoji", "Quick", "Nimble"]),
    ],
    swiftLanguageVersions: [.v5]
)
