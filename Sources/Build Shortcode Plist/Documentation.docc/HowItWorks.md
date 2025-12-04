# How It Works

Understand the data pipeline that transforms emoji-data files into plist resources.

## Overview

The Build Shortcode Plist tool implements a multi-stage pipeline that reads raw emoji data, parses shortcode definitions with their variations, expands all possible combinations, and writes optimized property list files.

## The Data Pipeline

The following diagram illustrates the complete data flow:

![Data pipeline showing transformation from emoji-data text files through parsing and expansion to plist output](data-pipeline)

### Stage 1: Reading Source Data

The `emojiData()` function creates an async throwing stream that reads from all `data_emoji_names*.txt` files in the emoji-data submodule. Each file contains lines in the format:

```
CODEPOINTS;shortcode/alternate_shortcode
```

For example:
```
2764-FE0F;heart/red_heart
1F468-{SKIN}-200D-2764-FE0F-200D-1F468-{SKIN2x};couple_with_heart_{M/W}_{M/W}
```

### Stage 2: Parsing

The `makeSlackmoji()` function parses each line into structured data:

- **Codepoints**: Unicode scalar values that form the emoji
- **Shortcode parts**: Text segments and insertion points
- **Skin insertions**: Where skin tone modifiers can be applied
- **Gender insertions**: Where gendered variants are generated

Special tokens in the source data indicate variations:

| Token | Meaning |
|-------|---------|
| `{SKIN}` | Optional skin tone modifier |
| `{SKIN!}` | Required skin tone modifier |
| `{SKIN2x}` | Second skin tone (for multi-person emoji) |
| `{MAN/WOMAN}` | Man/woman emoji character |
| `{MALE/FEMALE}` | Male/female symbol |
| `{M/W}` | Shortcode phrase for man/woman |

### Stage 3: Expansion

The `allExpansions` property on each parsed `Slackmoji` struct generates all valid combinations:

1. **Gender expansion**: Creates separate entries for male and female variants
2. **Skin tone expansion**: Generates all five skin tone variations (or none for base emoji)
3. **Combination handling**: For multi-person emoji, ensures skin tones are correctly paired

A single source line like `couple_with_heart_{M/W}_{M/W}` expands into hundreds of entries covering all gender and skin tone combinations.

### Stage 4: Writing Output

Two writer functions serialize the accumulated mappings:

- **`writeSlackmojiToEmoji()`**: Creates the forward mapping dictionary
- **`writeEmojiToSlackmoji()`**: Reverses the mappings for emoji-to-shortcode lookups

Both output XML property list format for compatibility and debuggability.

## Regenerating the Plist Files

When the upstream emoji-data repository is updated with new emoji:

1. Update the submodule: `git submodule update --remote`
2. Run the tool: `swift run "Build Shortcode Plist"`
3. Verify the changes in the generated plist files
4. Commit the updated resources
