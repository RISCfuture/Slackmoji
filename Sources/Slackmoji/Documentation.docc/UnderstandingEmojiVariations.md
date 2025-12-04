# Understanding Emoji Variations

Learn how Slackmoji handles skin tones, gender variants, and complex emoji sequences.

## Overview

Modern emoji are surprisingly complex. What appears as a single character might actually be multiple Unicode code points joined together. Slackmoji handles this complexity transparently, but understanding it helps explain why ``Slackmoji/Slackmoji/shortcodeToEmoji(_:)`` returns a `Set` rather than a single string.

## Skin Tone Modifiers

Many human emoji support five skin tone variations, represented by modifier code points that follow the base emoji:

| Modifier | Name |
|----------|------|
| 🏻 | Light skin tone |
| 🏼 | Medium-light skin tone |
| 🏽 | Medium skin tone |
| 🏾 | Medium-dark skin tone |
| 🏿 | Dark skin tone |

When you request a shortcode like `thumbsup`, Slackmoji returns all six variants (the base yellow and five skin tones):

```swift
let emoji = try converter.shortcodeToEmoji("thumbsup")
// Returns: ["👍", "👍🏻", "👍🏼", "👍🏽", "👍🏾", "👍🏿"]
```

> Note: The reverse conversion with ``Slackmoji/Slackmoji/emojiToShortcodes(_:)`` maps all skin-toned variants back to the same base shortcode. Skin tone information is not preserved in shortcodes.

## Gender Variants

Some emoji have gendered variants using different shortcode patterns:

### Man/Woman Variants

Emoji representing people often have explicit gender variants:

```swift
try converter.shortcodeToEmoji("man_technologist")  // 👨‍💻
try converter.shortcodeToEmoji("woman_technologist") // 👩‍💻
```

### Gender-Neutral Base Forms

Some shortcodes represent a gender-neutral base form that maps to multiple gendered emoji:

```swift
try converter.shortcodeToEmoji("person_shrugging")
// May return both 🤷‍♂️ and 🤷‍♀️
```

## Zero-Width Joiner Sequences

Complex emoji like families, couples, and professions are built by joining simpler emoji with the Zero-Width Joiner (ZWJ, U+200D) character:

```
👨 + ZWJ + ❤️ + ZWJ + 👨 = 👨‍❤️‍👨 (couple with heart: man, man)
```

Slackmoji handles these sequences automatically. The shortcode `couple_with_heart_man_man` correctly maps to the joined sequence.

### Multi-Person Skin Tones

For emoji with multiple people, each person can have a different skin tone. This creates many permutations:

```swift
try converter.shortcodeToEmoji("couple_with_heart_woman_man")
// Returns dozens of variants with different skin tone combinations
```

## Working with Sets

Because of these variations, conversion methods return `Set<String>`:

### Getting Any Emoji

When you just need one emoji (any variant is acceptable):

```swift
if let emoji = try converter.shortcodeToEmoji("wave").first {
    print("Hello \(emoji)")
}
```

### Getting the Base Emoji

The base (unmodified) emoji is typically the yellow version without skin tones:

```swift
let variants = try converter.shortcodeToEmoji("wave")
// The base emoji is usually included in the set
```

### Message Conversion

``Slackmoji/Slackmoji/messageWithShortcodesToEmoji(_:)`` automatically picks one variant, making it ideal for most use cases:

```swift
try converter.messageWithShortcodesToEmoji("Hello :wave:")
// Returns a consistent result like "Hello 👋"
```

## Emoji Data Currency

The emoji mappings are generated from the [iamcal/emoji-data](https://github.com/iamcal/emoji-data) repository at build time. New emoji added to Unicode may not be immediately available. See <doc:DataGeneration> for information on updating the emoji data.
