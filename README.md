# Slackmoji

[![CI](https://github.com/RISCfuture/Slackmoji/actions/workflows/ci.yml/badge.svg)](https://github.com/RISCfuture/Slackmoji/actions/workflows/ci.yml)
[![Documentation](https://github.com/RISCfuture/Slackmoji/actions/workflows/doc.yml/badge.svg)](https://riscfuture.github.io/Slackmoji/)
[![Swift 6.0+](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20|%20iOS%20|%20tvOS%20|%20watchOS%20|%20visionOS-blue.svg)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

This library is a shortcode-to-Unicode converter for Slack emoji. It is able to
convert between (e.g.) `:heart:` and ❤️. Note that Slack shortcodes can be
different from shortcodes used by other software such as GitHub.

## Requirements

This library requires Swift Package Manager v5.3 or newer, since it uses bundled
resources.

## Usage

Simply include this repository in your `Package.swift` file and mark it as a
dependency for your project. That will give you access to two functions:

```swift
import Slackmoji

let slackmoji = Slackmoji()
slackmoji.shortcodeToEmoji("heart") //-> ["❤️"]
slackmoji.emojiToShortcodes("❤️") //-> ["heart"]
```

Note that adding/removing the leading and trailing colons is your
responsibility.

## The plist data files

Slackmoji shortcodes are generated from
[this repository](https://github.com/iamcal/emoji-data), which is included as a
submodule. The **Build Shortcode Plist** file is an executable target that
parses the `emoji-data/build/data_emoji_names*.txt` files and generates the
property list file that is included as a bundled resource for this library.

To regenerate this plist file, simply run the **Build Shortcode Plist** target
from the project root directory.

## Documentation

Online API and tutorial documentation is available at
https://riscfuture.github.io/Slackmoji/documentation/slackmoji/

DocC documentation is available, including tutorials and API documentation. For
Xcode documentation, you can run

```sh
swift package generate-documentation --target Slackmoji
```

to generate a docarchive at
`.build/plugins/Swift-DocC/outputs/Slackmoji.doccarchive`. You can open this
docarchive file in Xcode for browseable API documentation. Or, within Xcode,
open the Slackmoji package in Xcode and choose **Build Documentation** from the
**Product** menu.

## Tests

Unit tests can be run with `swift test`.
