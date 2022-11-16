# ``Slackmoji``

A Swift package that converts between Slackmoji shortcodes and Unicode emoji
characters.

## Overview

This library is a shortcode-to-Unicode converter for Slack emoji. It is able to
convert between (e.g.) `:heart:` and ❤️. Note that Slack shortcodes can be
different from shortcodes used by other software such as GitHub.

## Requirements

This library requires Swift Package Manager v5.3 or newer, since it uses bundled
resources.

## Usage

Simply include this repository in your `Package.swift` file and mark it as a
dependency for your project. That will give you access to two functions:

* ``Slackmoji/Slackmoji/shortcodeToEmoji(_:)``
* ``Slackmoji/Slackmoji/emojiToShortcodes(_:)``

``` swift
import Slackmoji

let slackmoji = Slackmoji()
slackmoji.shortcodeToEmoji("heart") //-> ["❤️"]
slackmoji.emojiToShortcodes("❤️") //-> ["heart"]
```

Note that adding/removing the leading and trailing colons is your
responsibility.

You can also convert emoji inline within strings:

* ``Slackmoji/Slackmoji/messageWithShortcodesToEmoji(_:)``

## The plist data files

Slackmoji shortcodes are generated from
[this repository](https://github.com/iamcal/emoji-data), which is included as a
submodule. The **Build Shortcode Plist** file is an executable target that
parses the `emoji-data/build/data_emoji_names*.txt` files and generates the
property list file that is included as a bundled resource for this library.

To regenerate this plist file, simply run the **Build Shortcode Plist** target
from the project root directory.

## Tests

Unit tests can be run with `swift test`.
