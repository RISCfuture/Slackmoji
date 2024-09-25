// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Slackmoji",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "Slackmoji",
            targets: ["Slackmoji"]),
        .executable(name: "Build Shortcode Plist", targets: ["Build Shortcode Plist"])
    ],
    dependencies: [
        .package(url: "https://github.com/Bouke/Glob.git", branch: "master"),
        .package(url: "https://github.com/Peter-Schorn/RegularExpressions.git", branch: "master"),
        .package(url: "https://github.com/Quick/Quick.git", from: "4.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.1.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.0.0")
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
    swiftLanguageModes: [.v5, .v6]
)
