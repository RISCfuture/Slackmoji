# ``Build_Shortcode_Plist``

A command-line tool that generates emoji mapping plist files from the emoji-data repository.

@Metadata {
    @DisplayName("Build Shortcode Plist")
    @PageColor(purple)
}

## Overview

The **Build Shortcode Plist** tool parses emoji shortcode data from the [iamcal/emoji-data](https://github.com/iamcal/emoji-data) repository and generates the property list files used by the ``Slackmoji`` library at runtime.

This tool handles the complex task of expanding emoji variations, including:

- **Skin tone modifiers**: Generating all five skin tone variations for applicable emoji
- **Gender variants**: Creating separate entries for gendered emoji (man/woman, male/female)
- **Zero-width joiner sequences**: Properly handling compound emoji like family compositions

## Prerequisites

Before running this tool, ensure the `emoji-data` submodule is initialized:

```bash
git submodule update --init
```

## Usage

Run the tool from the project root directory:

```bash
swift run "Build Shortcode Plist"
```

This generates two plist files in `Sources/Slackmoji/Resources/`:

| File | Description |
|------|-------------|
| `SlackmojiToEmoji.plist` | Maps shortcodes to their possible emoji representations |
| `EmojiToSlackmoji.plist` | Maps emoji to their possible shortcodes |

### Command-Line Options

The tool accepts optional arguments to customize output paths:

```bash
swift run "Build Shortcode Plist" \
    --emoji-to-slackmoji-file /path/to/EmojiToSlackmoji.plist \
    --slackmoji-to-emoji-file /path/to/SlackmojiToEmoji.plist
```

| Option | Default | Description |
|--------|---------|-------------|
| `--emoji-to-slackmoji-file` | `Sources/Slackmoji/Resources/EmojiToSlackmoji.plist` | Output path for emoji-to-shortcode mappings |
| `--slackmoji-to-emoji-file` | `Sources/Slackmoji/Resources/SlackmojiToEmoji.plist` | Output path for shortcode-to-emoji mappings |

## Topics

### Understanding the Tool

- <doc:HowItWorks>
