# ``Slackmoji/Slackmoji``

## Overview

Create a ``Slackmoji`` instance to convert between Slack emoji shortcodes and Unicode emoji. The converter loads emoji mapping data lazily on first use, so instantiation is lightweight.

```swift
let converter = Slackmoji()
```

The same instance can be reused for multiple conversions. Each method call reloads the mapping data, so there's no benefit to caching the instance for data freshness—but also no penalty.

## Topics

### Creating a Converter

- ``init()``

### Converting Shortcodes to Emoji

- ``shortcodeToEmoji(_:)``
- ``messageWithShortcodesToEmoji(_:)``

### Converting Emoji to Shortcodes

- ``emojiToShortcodes(_:)``
