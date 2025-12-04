import Foundation
import RegexBuilder

/// A converter for translating between Slack emoji shortcodes and Unicode emoji characters.
///
/// Use `Slackmoji` to convert shortcodes like `"heart"` to emoji like `"❤️"`, or to process
/// messages containing inline shortcodes surrounded by colons.
///
/// Emoji mapping data is loaded from bundled property list files. The data is loaded lazily
/// on each method call, so creating a `Slackmoji` instance is lightweight.
///
/// ## Example
///
/// ```swift
/// let converter = Slackmoji()
///
/// // Single shortcode conversion
/// let emoji = try converter.shortcodeToEmoji("heart")
/// // emoji: ["❤️"]
///
/// // Message processing
/// let message = try converter.messageWithShortcodesToEmoji("I :heart: Swift")
/// // message: "I ❤️ Swift"
/// ```

public final class Slackmoji {

  private let decoder = PropertyListDecoder()

  private var emojiToSlackmoji: [String: Set<String>] {
    get throws {
      guard let url = Bundle.module.url(forResource: "EmojiToSlackmoji", withExtension: "plist")
      else {
        fatalError("No EmojiToSlackmoji.plist file")
      }
      let data = try Data(contentsOf: url)
      return try decoder.decode(Dictionary<String, Set<String>>.self, from: data)
    }
  }

  private var slackmojiToEmoji: [String: Set<String>] {
    get throws {
      guard let url = Bundle.module.url(forResource: "SlackmojiToEmoji", withExtension: "plist")
      else {
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

  /// Creates a new Slackmoji converter instance.
  ///
  /// The instance is lightweight and can be created as needed. Emoji mapping data is loaded
  /// lazily when conversion methods are called, not during initialization.

  public init() {}

  /// Converts a Slack shortcode to its corresponding emoji characters.
  ///
  /// A single shortcode may map to multiple emoji because of skin tone and gender variations.
  /// For example, the `"thumbsup"` shortcode maps to the base 👍 emoji plus all five
  /// skin-toned variants.
  ///
  /// - Parameter shortcode: The shortcode to convert, **without** surrounding colons.
  ///   For example, pass `"heart"`, not `":heart:"`.
  ///
  /// - Returns: A set of all emoji that match the shortcode. Returns an empty set if the
  ///   shortcode is not recognized.
  ///
  /// - Throws: An error if the bundled emoji data cannot be loaded. This should never occur
  ///   in a properly built application.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let converter = Slackmoji()
  /// let emoji = try converter.shortcodeToEmoji("wave")
  /// // emoji contains: ["👋", "👋🏻", "👋🏼", "👋🏽", "👋🏾", "👋🏿"]
  /// ```
  ///
  /// - SeeAlso: ``messageWithShortcodesToEmoji(_:)`` for processing shortcodes inline in text.

  public func shortcodeToEmoji(_ shortcode: String) throws -> Set<String> {
    try slackmojiToEmoji[shortcode] ?? Set()
  }

  /// Converts an emoji character to its corresponding Slack shortcodes.
  ///
  /// Some emoji have multiple shortcodes. For example, `"❤️"` can be represented by both
  /// `"heart"` and `"red_heart"`.
  ///
  /// - Note: Skin tone information is lost during this conversion. All skin-toned variants
  ///   of an emoji map to the same base shortcode.
  ///
  /// - Parameter character: A string containing a single emoji. The emoji may consist of
  ///   multiple Unicode code points joined by zero-width joiners (ZWJ), such as family
  ///   or profession emoji.
  ///
  /// - Returns: A set of shortcodes that produce the given emoji. Returns an empty set if
  ///   the string is not a recognized emoji.
  ///
  /// - Throws: An error if the bundled emoji data cannot be loaded. This should never occur
  ///   in a properly built application.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let converter = Slackmoji()
  /// let shortcodes = try converter.emojiToShortcodes("🎉")
  /// // shortcodes: ["tada"]
  /// ```

  public func emojiToShortcodes(_ character: String) throws -> Set<String> {
    try emojiToSlackmoji[character] ?? Set()
  }

  /// Converts all shortcodes in a message to their emoji equivalents.
  ///
  /// This method finds all patterns matching `:shortcode:` in the input string and replaces
  /// them with the corresponding emoji. Unrecognized shortcodes are left unchanged.
  ///
  /// When a shortcode maps to multiple emoji variants (due to skin tones or gender), the
  /// first matching emoji is used. For precise control over which variant to use, call
  /// ``shortcodeToEmoji(_:)`` directly and select the desired emoji.
  ///
  /// - Parameter message: The message text containing shortcodes to convert. Shortcodes
  ///   must be surrounded by colons, like `:heart:` or `:thumbsup:`.
  ///
  /// - Returns: The message with recognized shortcodes replaced by emoji. Unrecognized
  ///   shortcodes remain as-is.
  ///
  /// - Throws: An error if the bundled emoji data cannot be loaded. This should never occur
  ///   in a properly built application.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let converter = Slackmoji()
  /// let result = try converter.messageWithShortcodesToEmoji("Great job! :thumbsup: :tada:")
  /// // result: "Great job! 👍 🎉"
  /// ```

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
