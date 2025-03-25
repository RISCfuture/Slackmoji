import Foundation
import RegexBuilder

/**
 This class contains methods for converting between Slack emoji shortcodes
 (e.g., `":heart:"`) and emoji (e.g., `"❤️"`). Emoji shortcode data is
 statically linked as an embedded property list and lazy-loaded upon first use.
 */

public final class Slackmoji {

    private let decoder = PropertyListDecoder()

    private var emojiToSlackmoji: [String: Set<String>] {
        get throws {
            guard let url = Bundle.module.url(forResource: "EmojiToSlackmoji", withExtension: "plist") else {
                fatalError("No EmojiToSlackmoji.plist file")
            }
            let data = try Data(contentsOf: url)
            return try decoder.decode(Dictionary<String, Set<String>>.self, from: data)
        }
    }

    private var slackmojiToEmoji: [String: Set<String>] {
        get throws {
            guard let url = Bundle.module.url(forResource: "SlackmojiToEmoji", withExtension: "plist") else {
                fatalError("No SlackmojiToEmoji.plist file")
            }
            let data = try Data(contentsOf: url)
            return try decoder.decode(Dictionary<String, Set<String>>.self, from: data)
        }
    }

    private let shortcodeRef = Reference<Substring>()

    private lazy var shortcodeRx = Regex {
        ":"
        Capture(as: shortcodeRef) {
            OneOrMore {
                CharacterClass(.word, .anyOf("-_"))
            }
        }
        ":"
    }

    /**
     Creates a new Slackmoji instance.
     */

    public init() {}

    /**
     Given a Slack emoji shortcode, returns all possible emoji that the
     shortcode can map to. A single shortcode can map to multiple emoji because
     of differences in skin tone and other discriminators.
     
     - Parameter shortcode: A Slack shortcode. Do not include the colons (i.e.,
       pass `"heart"`, not `":heart:"`).
     - Returns: All matching emoji as plain strings. If the string does not
       match a known shortcode, an empty set is returned.
     */

    public func shortcodeToEmoji(_ shortcode: String) throws -> Set<String> {
        try slackmojiToEmoji[shortcode] ?? Set()
    }

    /**
     Given a string containing a single emoji, returns all possible Slack
     shortcodes that would produce that emoji. Note that this is not a
     completely lossless conversion, as skin tone discriminators are lost in the
     output.
     
     - Parameter character: A string containing a single emoji. The emoji can
       be represented as a single codepoint or a group of codepoints
       concatenated by zero-width joiners.
     - Returns: All shortcodes that would produce that emoji. If `character`
       does not contain an emoji or contains multiple characters, an empty set
       is returned.
     */

    public func emojiToShortcodes(_ character: String) throws -> Set<String> {
        try emojiToSlackmoji[character] ?? Set()
    }

    /**
     Given a string containing Slack shortcodes (surrounded by colons), returns
     a string with those shortcodes converted to emoji. For example, given the
     string `"I :heart: :bubble_tea:"`, this method would return "I ❤️ 🧋".
     
     Note that in some cases, a shortcode can resolve to multiple possible
     emoji. In these situations, the first matching emoji is chosen. For more
     control over which emoji to use for a given shortcode, use
     ``shortcodeToEmoji(_:)``.
     
     - Parameter message: The message containing shortcodes.
     - Returns: The same message, with shortcodes converted to emoji.
     */

    public func messageWithShortcodesToEmoji(_ message: String) throws -> String {
        try message.replacing(shortcodeRx) { match in
            let shortcode = String(match[shortcodeRef])
            return try shortcodeToEmoji(shortcode).first ?? shortcode
        }
    }

//    private let emojiRx = try! Regex(pattern: #"(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])"#)
//
//    /**
//     Given a string containing emoji, returns a string with the emoji converted
//     to Slack shortcodes (surrounded by colons). For example, given the string
//     "I ❤️ 🧋", this method would return `"I :heart: :bubble_tea:"`.
//
//     - Parameter message: The message containing emoji.
//     - Returns: The same message, with emoji converted to shortcodes.
//     - SeeAlso: ``emojiToShortcodes(_:)``
//     */
//
//    public func messageWithEmojiToShortcodes(_ message: String) throws -> String {
//        try message.regexSub(emojiRx) { _index, match in
//            let emoji = match.fullMatch
//            return emojiToShortcodes(emoji).first ?? emoji
//        }
//    }
}
