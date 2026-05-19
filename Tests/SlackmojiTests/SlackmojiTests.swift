import Nimble
import Quick

@testable import Slackmoji

final class SlackmojiSpec: QuickSpec {
  override static func spec() {
    var slackmoji: Slackmoji { .init() }

    describe("#shortcodeToEmoji") {
      it("returns a shortcode for a single match") {
        try expect(slackmoji.shortcodeToEmoji("heart")).to(equal(Set(["❤️"])))
      }

      it("handles gender discriminators") {
        try expect(slackmoji.shortcodeToEmoji("older_man")).to(equal(Set(["👴"])))
        try expect(slackmoji.shortcodeToEmoji("older_woman")).to(equal(Set(["👵"])))
        try expect(slackmoji.shortcodeToEmoji("older_adult")).to(equal(Set(["🧓"])))
      }

      it("handles skin tone discriminators") {
        try expect(slackmoji.shortcodeToEmoji("office_worker"))
          .to(equal(Set(["🧑‍💼", "🧑🏻‍💼", "🧑🏿‍💼", "🧑🏾‍💼", "🧑🏽‍💼", "🧑🏼‍💼"])))
      }

      it("handles gender and skin tone discriminators combined") {
        try expect(slackmoji.shortcodeToEmoji("white_haired_man"))
          .to(equal(Set(["👨🏽‍🦳", "👨‍🦳", "👨🏾‍🦳", "👨🏿‍🦳", "👨🏻‍🦳", "👨🏼‍🦳"])))
        try expect(slackmoji.shortcodeToEmoji("white_haired_woman"))
          .to(equal(Set(["👩🏻‍🦳", "👩🏽‍🦳", "👩‍🦳", "👩🏿‍🦳", "👩🏾‍🦳", "👩🏼‍🦳"])))
        try expect(slackmoji.shortcodeToEmoji("white_haired_person"))
          .to(equal(Set(["🧑🏼‍🦳", "🧑🏽‍🦳", "🧑🏻‍🦳", "🧑🏾‍🦳", "🧑‍🦳", "🧑🏿‍🦳"])))
      }

      it("handles permutable skin tone discriminators") {
        try expect(slackmoji.shortcodeToEmoji("woman-heart-man"))
          .to(
            equal(
              Set([
                "👩‍❤️‍👨🏻", "👩🏽‍❤️‍👨🏾", "👩🏿‍❤️‍👨🏼", "👩🏼‍❤️‍👨🏾", "👩‍❤️‍👨🏿", "👩🏼‍❤️‍👨🏿", "👩🏽‍❤️‍👨🏼",
                "👩🏿‍❤️‍👨🏻", "👩🏾‍❤️‍👨🏻", "👩🏼‍❤️‍👨🏻", "👩🏻‍❤️‍👨🏾", "👩🏿‍❤️‍👨🏾", "👩🏽‍❤️‍👨🏿", "👩🏾‍❤️‍👨🏿",
                "👩‍❤️‍👨🏼", "👩🏾‍❤️‍👨🏼", "👩🏽‍❤️‍👨🏻", "👩🏿‍❤️‍👨🏽", "👩🏻‍❤️‍👨🏿", "👩🏾‍❤️‍👨🏽", "👩🏻‍❤️‍👨🏼",
                "👩‍❤️‍👨🏽", "👩🏼‍❤️‍👨🏽", "👩‍❤️‍👨🏾", "👩🏻‍❤️‍👨🏽"
              ])
            )
          )
      }
    }

    describe("#emojiToShortcodes") {
      it("returns a shortcode for a single match") {
        try expect(slackmoji.emojiToShortcodes("❤️"))
          .to(equal(Set(["heart"])))
      }
      it("returns shortcodes for multiple matches") {
        try expect(slackmoji.emojiToShortcodes("🏃"))
          .to(equal(Set(["runner", "running"])))
      }

      it("handles gender and skin tone discriminators") {
        try expect(slackmoji.emojiToShortcodes("👩🏻‍🦳"))
          .to(equal(Set(["white_haired_woman"])))
        try expect(slackmoji.emojiToShortcodes("👨🏿‍🦳"))
          .to(equal(Set(["white_haired_man"])))
      }
    }

    describe("#messageWithShortcodesToEmoji") {
      it("converts shortcodes in a message to emoji") {
        try expect(slackmoji.messageWithShortcodesToEmoji("I :heart: N7:heart: :tada:!"))
          .to(equal("I ❤️ N7❤️ 🎉!"))
      }
    }

    //        describe("#messageWithEmojiToShortcodes") {
    //            it("converts emoji in a message to shortcodes") {
    //                expect(try! slackmoji.messageWithEmojiToShortcodes("I ❤️ N7❤️ 🎉!"))
    //                    .to(equal("I :heart: N7:heart: :tada:!"))
    //            }
    //        }
  }
}
