import Foundation

/// Property list encoder configured for XML output format.
let encoder: PropertyListEncoder = {
  let encoder = PropertyListEncoder()
  encoder.outputFormat = .xml
  return encoder
}()

/// Writes the shortcode-to-emoji mapping dictionary to a plist file.
///
/// The output file maps shortcodes to arrays of emoji strings that the shortcode can produce.
///
/// - Parameter aliases: Dictionary mapping shortcodes to their emoji variations.
/// - Throws: An error if the file cannot be written.
func writeSlackmojiToEmoji(aliases: [String: Set<String>]) throws {
  let plistData = try encoder.encode(aliases)
  try plistData.write(
    to: URL(
      filePath: "Sources/Slackmoji/Resources/SlackmojiToEmoji.plist",
      directoryHint: .notDirectory
    )
  )
}

/// Writes the emoji-to-shortcode mapping dictionary to a plist file.
///
/// Reverses the shortcode-to-emoji mappings to create an emoji-keyed dictionary.
/// The output file maps emoji strings to arrays of shortcodes that produce them.
///
/// - Parameter aliases: Dictionary mapping shortcodes to their emoji variations.
/// - Throws: An error if the file cannot be written.
func writeEmojiToSlackmoji(aliases: [String: Set<String>]) throws {
  var reversed = [String: Set<String>]()

  for (slackmoji, emojis) in aliases {
    for emoji in emojis {
      if reversed[emoji] == nil {
        reversed[emoji] = Set()
      }
      reversed[emoji]!.insert(slackmoji)
    }
  }

  let plistData = try encoder.encode(reversed)
  try plistData.write(
    to: URL(
      filePath: "Sources/Slackmoji/Resources/EmojiToSlackmoji.plist",
      directoryHint: .notDirectory
    )
  )
}
