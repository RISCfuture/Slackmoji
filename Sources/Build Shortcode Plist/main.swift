import Foundation

var aliases = Dictionary<String, Set<String>>()

emojiData { contents in
    contents.enumerateLines { line, stop in
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

writeSlackmojiToEmoji(aliases: aliases)
writeEmojiToSlackmoji(aliases: aliases)
