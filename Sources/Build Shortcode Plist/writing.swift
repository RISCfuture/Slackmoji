import Foundation

let encoder: PropertyListEncoder = {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml
    return encoder
}()

func writeSlackmojiToEmoji(aliases: Dictionary<String, Set<String>>) {
    let plistData = try! encoder.encode(aliases)
    try! plistData.write(to: URL(fileURLWithPath: "Sources/Slackmoji/Resources/SlackmojiToEmoji.plist"))
}

func writeEmojiToSlackmoji(aliases: Dictionary<String, Set<String>>) {
    var reversed = Dictionary<String, Set<String>>()
    
    for (slackmoji, emojis) in aliases {
        for emoji in emojis {
            if reversed[emoji] == nil {
                reversed[emoji] = Set()
            }
            reversed[emoji]!.insert(slackmoji)
        }
    }
    
    let plistData = try! encoder.encode(reversed)
    try! plistData.write(to: URL(fileURLWithPath: "Sources/Slackmoji/Resources/EmojiToSlackmoji.plist"))
}
