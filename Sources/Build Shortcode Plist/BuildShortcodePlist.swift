import ArgumentParser
import Foundation

/// Command-line tool that generates emoji mapping plist files from emoji-data repository files.
///
/// This tool reads the `data_emoji_names*.txt` files from the emoji-data submodule, parses the
/// shortcode definitions including skin tone and gender variations, expands all combinations,
/// and writes bidirectional mapping dictionaries as property list files.
///
/// Run from the project root directory after initializing the emoji-data submodule.
@main
struct BuildShortcodePlist: AsyncParsableCommand {
  /// Path to the output file for emoji-to-shortcode mappings.
  @Option(
    completion: .file(extensions: ["plist"]),
    transform: { .init(filePath: $0, directoryHint: .notDirectory) }
  )
  var emojiToSlackmojiFile = URL(
    filePath: "Sources/Slackmoji/Resources/EmojiToSlackmoji.plist",
    directoryHint: .notDirectory
  )

  /// Path to the output file for shortcode-to-emoji mappings.
  @Option(
    completion: .file(extensions: ["plist"]),
    transform: { .init(filePath: $0, directoryHint: .notDirectory) }
  )
  var slackmojiToEmojiFile = URL(
    filePath: "Sources/Slackmoji/Resources/SlackmojiToEmoji.plist",
    directoryHint: .notDirectory
  )

  /// Runs the plist generation process.
  ///
  /// Reads all emoji data files, parses and expands variations, then writes the output plists.
  mutating func run() async throws {
    var aliases = [String: Set<String>]()

    for try await contents in emojiData() {
      contents.enumerateLines { line, _ in
        guard !line.isEmpty && !line.starts(with: "#") else { return }

        let parts = line.split(separator: ";")
        let slackmoji = makeSlackmoji(codepoints: parts[0], shortcodes: parts[1])

        for slackmoji in slackmoji {
          for (shortcode, unicodeValues) in slackmoji.allExpansions {
            if var existingValues = aliases[shortcode] {
              for value in unicodeValues {
                existingValues.insert(value)
              }
            } else {
              aliases[shortcode] = Set(unicodeValues)
            }
          }
        }
      }
    }

    try writeSlackmojiToEmoji(aliases: aliases)
    try writeEmojiToSlackmoji(aliases: aliases)
  }
}
