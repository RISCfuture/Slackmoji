# Getting Started with Slackmoji

Add emoji conversion capabilities to your Swift application.

## Overview

Slackmoji provides a simple API for converting between Slack-style emoji shortcodes and Unicode emoji characters. This guide covers installation and basic usage patterns.

## Installation

Add Slackmoji to your Swift package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/RISCfuture/Slackmoji.git", from: "3.0.0")
]
```

Then add it as a dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["Slackmoji"]
)
```

### Platform Requirements

Slackmoji requires:
- Swift 5.3+ (uses bundled resources)
- macOS 13+, iOS 16+, tvOS 16+, watchOS 9+, or visionOS 1+

## Basic Usage

Import the module and create a converter instance:

```swift
import Slackmoji

let converter = Slackmoji()
```

### Converting a Single Shortcode

Use ``Slackmoji/Slackmoji/shortcodeToEmoji(_:)`` to convert a shortcode to its emoji representation. Pass the shortcode **without** the surrounding colons:

```swift
let emoji = try converter.shortcodeToEmoji("thumbsup")
// emoji contains: ["👍", "👍🏻", "👍🏼", "👍🏽", "👍🏾", "👍🏿"]
```

> Important: The method returns a `Set<String>` because many shortcodes map to multiple emoji variants (different skin tones, for example). See <doc:UnderstandingEmojiVariations> for details.

### Converting Emoji to Shortcodes

Use ``Slackmoji/Slackmoji/emojiToShortcodes(_:)`` to find shortcodes for an emoji:

```swift
let shortcodes = try converter.emojiToShortcodes("🎉")
// shortcodes contains: ["tada"]
```

### Processing Messages

For converting shortcodes embedded in text, use ``Slackmoji/Slackmoji/messageWithShortcodesToEmoji(_:)``:

```swift
let message = "Great job! :thumbsup: :tada:"
let converted = try converter.messageWithShortcodesToEmoji(message)
// converted: "Great job! 👍 🎉"
```

This method finds all `:shortcode:` patterns and replaces them with the corresponding emoji. When multiple emoji variants exist for a shortcode, the first one is chosen.

## Error Handling

All conversion methods are marked `throws` because they load emoji data from bundled resources. In practice, these methods only throw if the bundled plist files are corrupted or missing, which should never happen in a properly built application.

```swift
do {
    let emoji = try converter.shortcodeToEmoji("heart")
    print(emoji)
} catch {
    // Handle unlikely resource loading error
    print("Failed to load emoji data: \(error)")
}
```

## Common Use Cases

### Chat Applications

Convert user-typed shortcodes to emoji for display:

```swift
func formatMessage(_ input: String) throws -> String {
    let converter = Slackmoji()
    return try converter.messageWithShortcodesToEmoji(input)
}
```

### Emoji Pickers

Build an emoji picker by iterating over known shortcodes:

```swift
let converter = Slackmoji()
let popularShortcodes = ["heart", "thumbsup", "smile", "tada", "fire"]

for shortcode in popularShortcodes {
    if let emoji = try? converter.shortcodeToEmoji(shortcode).first {
        print("\(shortcode): \(emoji)")
    }
}
```

### Accessibility

Provide text alternatives for emoji:

```swift
func describeEmoji(_ emoji: String) throws -> String? {
    let converter = Slackmoji()
    return try converter.emojiToShortcodes(emoji).first
}

// describeEmoji("❤️") returns "heart"
```
