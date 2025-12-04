# ``Slackmoji``

Convert between Slack emoji shortcodes and Unicode emoji characters.

@Metadata {
    @PageColor(blue)
}

@Options(scope: local) {
    @AutomaticSeeAlso(enabled)
}

## Overview

**Slackmoji** is a Swift library that converts between Slack-style emoji shortcodes (like `:heart:`) and Unicode emoji characters (like ❤️). The library handles the full complexity of modern emoji, including skin tone modifiers, gender variants, and zero-width joiner sequences.

> Note: Slack shortcodes differ from shortcodes used by other platforms like GitHub. This library specifically targets Slack's emoji naming conventions.

### Key Features

- **Bidirectional conversion**: Convert shortcodes to emoji and emoji back to shortcodes
- **Skin tone support**: Handle all five skin tone variations for supported emoji
- **Gender variants**: Support gendered emoji with correct shortcode mappings
- **Message processing**: Convert shortcodes inline within strings
- **Zero runtime dependencies**: All emoji data is bundled at compile time

### Quick Example

```swift
import Slackmoji

let converter = Slackmoji()

// Convert a shortcode to emoji
try converter.shortcodeToEmoji("heart")  // Returns: ["❤️"]

// Convert emoji to shortcodes
try converter.emojiToShortcodes("❤️")    // Returns: ["heart"]

// Process inline shortcodes in a message
try converter.messageWithShortcodesToEmoji("I :heart: :bubble_tea:")
// Returns: "I ❤️ 🧋"
```

## Topics

### Essentials

- <doc:GettingStarted>
- ``Slackmoji/Slackmoji``

### Understanding Emoji

- <doc:UnderstandingEmojiVariations>
- <doc:DataGeneration>
