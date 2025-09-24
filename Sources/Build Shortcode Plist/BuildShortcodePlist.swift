import ArgumentParser
import Foundation

@main
struct BuildShortcodePlist: AsyncParsableCommand {
  @Option(
    completion: .file(extensions: ["plist"]),
    transform: { .init(filePath: $0, directoryHint: .notDirectory) }
  )
  var emojiToSlackmojiFile = URL(
    filePath: "Sources/Slackmoji/Resources/EmojiToSlackmoji.plist",
    directoryHint: .notDirectory
  )

  @Option(
    completion: .file(extensions: ["plist"]),
    transform: { .init(filePath: $0, directoryHint: .notDirectory) }
  )
  var slackmojiToEmojiFile = URL(
    filePath: "Sources/Slackmoji/Resources/SlackmojiToEmoji.plist",
    directoryHint: .notDirectory
  )

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
