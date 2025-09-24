import Foundation

let encoder: PropertyListEncoder = {
  let encoder = PropertyListEncoder()
  encoder.outputFormat = .xml
  return encoder
}()

func writeSlackmojiToEmoji(aliases: [String: Set<String>]) throws {
  let plistData = try encoder.encode(aliases)
  try plistData.write(
    to: URL(
      filePath: "Sources/Slackmoji/Resources/SlackmojiToEmoji.plist",
      directoryHint: .notDirectory
    )
  )
}

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
