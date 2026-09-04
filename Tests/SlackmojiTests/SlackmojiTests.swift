import Testing

@testable import Slackmoji

@Suite
enum SlackmojiTests {
  @Suite
  struct ShortcodeToEmoji {
    let slackmoji = Slackmoji()

    @Test
    func `returns a shortcode for a single match`() throws {
      #expect(try slackmoji.shortcodeToEmoji("heart") == Set(["❤️"]))
    }

    @Test
    func `handles gender discriminators`() throws {
      #expect(try slackmoji.shortcodeToEmoji("older_man") == Set(["👴"]))
      #expect(try slackmoji.shortcodeToEmoji("older_woman") == Set(["👵"]))
      #expect(try slackmoji.shortcodeToEmoji("older_adult") == Set(["🧓"]))
    }

    @Test
    func `handles skin tone discriminators`() throws {
      #expect(
        try slackmoji.shortcodeToEmoji("office_worker")
          == Set(["🧑‍💼", "🧑🏻‍💼", "🧑🏿‍💼", "🧑🏾‍💼", "🧑🏽‍💼", "🧑🏼‍💼"])
      )
    }

    @Test
    func `handles gender and skin tone discriminators combined`() throws {
      #expect(
        try slackmoji.shortcodeToEmoji("white_haired_man")
          == Set(["👨🏽‍🦳", "👨‍🦳", "👨🏾‍🦳", "👨🏿‍🦳", "👨🏻‍🦳", "👨🏼‍🦳"])
      )
      #expect(
        try slackmoji.shortcodeToEmoji("white_haired_woman")
          == Set(["👩🏻‍🦳", "👩🏽‍🦳", "👩‍🦳", "👩🏿‍🦳", "👩🏾‍🦳", "👩🏼‍🦳"])
      )
      #expect(
        try slackmoji.shortcodeToEmoji("white_haired_person")
          == Set(["🧑🏼‍🦳", "🧑🏽‍🦳", "🧑🏻‍🦳", "🧑🏾‍🦳", "🧑‍🦳", "🧑🏿‍🦳"])
      )
    }

    @Test
    func `handles permutable skin tone discriminators`() throws {
      #expect(
        try slackmoji.shortcodeToEmoji("woman-heart-man")
          == Set([
            "👩‍❤️‍👨🏻", "👩🏽‍❤️‍👨🏾", "👩🏿‍❤️‍👨🏼", "👩🏼‍❤️‍👨🏾", "👩‍❤️‍👨🏿", "👩🏼‍❤️‍👨🏿", "👩🏽‍❤️‍👨🏼",
            "👩🏿‍❤️‍👨🏻", "👩🏾‍❤️‍👨🏻", "👩🏼‍❤️‍👨🏻", "👩🏻‍❤️‍👨🏾", "👩🏿‍❤️‍👨🏾", "👩🏽‍❤️‍👨🏿", "👩🏾‍❤️‍👨🏿",
            "👩‍❤️‍👨🏼", "👩🏾‍❤️‍👨🏼", "👩🏽‍❤️‍👨🏻", "👩🏿‍❤️‍👨🏽", "👩🏻‍❤️‍👨🏿", "👩🏾‍❤️‍👨🏽", "👩🏻‍❤️‍👨🏼",
            "👩‍❤️‍👨🏽", "👩🏼‍❤️‍👨🏽", "👩‍❤️‍👨🏾", "👩🏻‍❤️‍👨🏽"
          ])
      )
    }
  }

  @Suite
  struct EmojiToShortcodes {
    let slackmoji = Slackmoji()

    @Test
    func `returns a shortcode for a single match`() throws {
      #expect(try slackmoji.emojiToShortcodes("❤️") == Set(["heart"]))
    }

    @Test
    func `returns shortcodes for multiple matches`() throws {
      #expect(try slackmoji.emojiToShortcodes("🏃") == Set(["runner", "running"]))
    }

    @Test
    func `handles gender and skin tone discriminators`() throws {
      #expect(try slackmoji.emojiToShortcodes("👩🏻‍🦳") == Set(["white_haired_woman"]))
      #expect(try slackmoji.emojiToShortcodes("👨🏿‍🦳") == Set(["white_haired_man"]))
    }
  }

  @Suite
  struct MessageWithShortcodesToEmoji {
    let slackmoji = Slackmoji()

    @Test
    func `converts shortcodes in a message to emoji`() throws {
      #expect(
        try slackmoji.messageWithShortcodesToEmoji("I :heart: N7:heart: :tada:!")
          == "I ❤️ N7❤️ 🎉!"
      )
    }
  }

  //  @Suite
  //  struct MessageWithEmojiToShortcodes {
  //    let slackmoji = Slackmoji()
  //
  //    @Test
  //    func `converts emoji in a message to shortcodes`() throws {
  //      #expect(
  //        try slackmoji.messageWithEmojiToShortcodes("I ❤️ N7❤️ 🎉!")
  //          == "I :heart: N7:heart: :tada:!"
  //      )
  //    }
  //  }
}
