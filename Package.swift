// swift-tools-version:6.0

import PackageDescription

let package = Package(
  name: "Slackmoji",
  platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1)],
  products: [
    .library(
      name: "Slackmoji",
      targets: ["Slackmoji"]
    ),
    .executable(name: "Build Shortcode Plist", targets: ["Build Shortcode Plist"])
  ],
  dependencies: [
    .package(url: "https://github.com/Bouke/Glob.git", branch: "master"),
    .package(url: "https://github.com/Peter-Schorn/RegularExpressions.git", branch: "master"),
    .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
    .package(url: "https://github.com/Quick/Nimble.git", from: "13.7.1"),
    .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.4.3"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0")
  ],
  targets: [
    .target(
      name: "Slackmoji",
      dependencies: ["RegularExpressions"],
      resources: [
        .process("Resources/EmojiToSlackmoji.plist"),
        .process("Resources/SlackmojiToEmoji.plist")
      ]
    ),
    .executableTarget(
      name: "Build Shortcode Plist",
      dependencies: [
        "Glob",
        "RegularExpressions",
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]
    ),
    .testTarget(
      name: "SlackmojiTests",
      dependencies: ["Slackmoji", "Quick", "Nimble"]
    )
  ],
  swiftLanguageModes: [.v5, .v6]
)
