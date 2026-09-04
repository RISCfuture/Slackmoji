// swift-tools-version:6.0

import PackageDescription

let upcomingFeatures: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("ImmutableWeakCaptures"),
  .enableUpcomingFeature("MemberImportVisibility"),
  .enableUpcomingFeature("ExistentialAny"),
  .enableUpcomingFeature("InternalImportsByDefault")
]

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
    .package(url: "https://github.com/Bouke/Glob.git", from: "1.0.5"),
    .package(url: "https://github.com/Peter-Schorn/RegularExpressions.git", from: "2.2.0"),
    .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.5.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.8.2")
  ],
  targets: [
    .target(
      name: "Slackmoji",
      dependencies: ["RegularExpressions"],
      resources: [
        .process("Resources/EmojiToSlackmoji.plist"),
        .process("Resources/SlackmojiToEmoji.plist")
      ],
      swiftSettings: upcomingFeatures
    ),
    .executableTarget(
      name: "Build Shortcode Plist",
      dependencies: [
        "Glob",
        "RegularExpressions",
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
      swiftSettings: upcomingFeatures
    ),
    .testTarget(
      name: "SlackmojiTests",
      dependencies: ["Slackmoji"],
      swiftSettings: upcomingFeatures
    )
  ],
  swiftLanguageModes: [.v5, .v6]
)
