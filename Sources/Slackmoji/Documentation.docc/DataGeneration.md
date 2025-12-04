# Data Generation

Understand how emoji mapping data is generated and kept up to date.

## Overview

Slackmoji's emoji mappings are pre-generated from the [iamcal/emoji-data](https://github.com/iamcal/emoji-data) repository and bundled as property list files. This approach provides fast runtime performance with zero network dependencies.

## Bundled Resources

The library includes two plist files in `Sources/Slackmoji/Resources/`:

| File | Size | Description |
|------|------|-------------|
| `SlackmojiToEmoji.plist` | ~170 KB | Maps shortcodes to emoji character sets |
| `EmojiToSlackmoji.plist` | ~220 KB | Maps emoji characters to shortcode sets |

These files are processed resources, bundled into your application at compile time via Swift Package Manager's resource handling.

## The Build Tool

The **Build Shortcode Plist** executable target generates these plist files. It's included in the package but not part of the library product—it's only used during development.

### Running the Generator

From the project root:

```bash
# Ensure the emoji-data submodule is current
git submodule update --init --remote

# Generate the plist files
swift run "Build Shortcode Plist"
```

### What It Does

The tool:

1. Reads `data_emoji_names*.txt` files from the emoji-data submodule
2. Parses shortcode definitions including variation markers
3. Expands skin tone and gender combinations
4. Writes bidirectional mapping dictionaries as XML plists

See the Build Shortcode Plist documentation for technical details on the pipeline.

## Updating Emoji Data

When new emoji are added to Unicode and subsequently to the emoji-data repository:

1. **Update the submodule**:
   ```bash
   git submodule update --remote emoji-data
   ```

2. **Regenerate the plists**:
   ```bash
   swift run "Build Shortcode Plist"
   ```

3. **Verify the changes**:
   ```bash
   git diff Sources/Slackmoji/Resources/
   ```

4. **Test the new mappings**:
   ```bash
   swift test
   ```

5. **Commit the updates**:
   ```bash
   git add Sources/Slackmoji/Resources/*.plist emoji-data
   git commit -m "Update emoji data"
   ```

## Data Format

The plist files use a simple dictionary structure:

```xml
<!-- SlackmojiToEmoji.plist -->
<dict>
    <key>heart</key>
    <array>
        <string>❤️</string>
    </array>
    <key>thumbsup</key>
    <array>
        <string>👍</string>
        <string>👍🏻</string>
        <!-- ... more skin tone variants -->
    </array>
</dict>
```

Each shortcode maps to an array of possible emoji strings. The reverse mapping (`EmojiToSlackmoji.plist`) has the same structure but with emoji as keys and shortcode arrays as values.

## Version Compatibility

The plist format is stable and doesn't require library changes when emoji data is updated. Applications using Slackmoji will automatically use the emoji data that was current when the library was built.

To get newer emoji support, update your Slackmoji dependency to a version built with more recent emoji-data.
