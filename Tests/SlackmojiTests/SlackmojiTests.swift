import Testing

@testable import Slackmoji

@Suite
enum SlackmojiTests {
  @Suite
  struct ShortcodeToEmoji {
    let slackmoji = Slackmoji()

    @Test
    func returnsAShortcodeForASingleMatch() throws {
      #expect(try slackmoji.shortcodeToEmoji("heart") == Set(["❤️"]))
    }

    @Test
    func handlesGenderDiscriminators() throws {
      #expect(try slackmoji.shortcodeToEmoji("older_man") == Set(["👴"]))
      #expect(try slackmoji.shortcodeToEmoji("older_woman") == Set(["👵"]))
      #expect(try slackmoji.shortcodeToEmoji("older_adult") == Set(["🧓"]))
    }

    @Test
    func handlesSkinToneDiscriminators() throws {
      #expect(
        try slackmoji.shortcodeToEmoji("office_worker")
          == Set(["🧑‍💼", "🧑🏻‍💼", "🧑🏿‍💼", "🧑🏾‍💼", "🧑🏽‍💼", "🧑🏼‍💼"])
      )
    }

    @Test
    func handlesGenderAndSkinToneDiscriminatorsCombined() throws {
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
    func handlesPermutableSkinToneDiscriminators() throws {
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
    func returnsAShortcodeForASingleMatch() throws {
      #expect(try slackmoji.emojiToShortcodes("❤️") == Set(["heart"]))
    }

    @Test
    func returnsShortcodesForMultipleMatches() throws {
      #expect(try slackmoji.emojiToShortcodes("🏃") == Set(["runner", "running"]))
    }

    @Test
    func handlesGenderAndSkinToneDiscriminators() throws {
      #expect(try slackmoji.emojiToShortcodes("👩🏻‍🦳") == Set(["white_haired_woman"]))
      #expect(try slackmoji.emojiToShortcodes("👨🏿‍🦳") == Set(["white_haired_man"]))
    }
  }

  @Suite
  struct MessageWithShortcodesToEmoji {
    let slackmoji = Slackmoji()

    @Test
    func convertsShortcodesInAMessageToEmoji() throws {
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
  //    func convertsEmojiInAMessageToShortcodes() throws {
  //      #expect(
  //        try slackmoji.messageWithEmojiToShortcodes("I ❤️ N7❤️ 🎉!")
  //          == "I :heart: N7:heart: :tada:!"
  //      )
  //    }
  //  }
}
