import Quick
import Nimble
@testable import Slackmoji
import Build_Shortcode_Plist

class SlackmojiSpec: QuickSpec {
    override func spec() {
        let slackmoji = Slackmoji()
        
        describe("#shortcodeToEmoji") {
            it("returns a shortcode for a single match") {
                expect(slackmoji.shortcodeToEmoji("heart")).to(equal(Set(["❤️"])))
            }
            
            it("handles gender discriminators") {
                expect(slackmoji.shortcodeToEmoji("older_man")).to(equal(Set(["👴"])))
                expect(slackmoji.shortcodeToEmoji("older_woman")).to(equal(Set(["👵"])))
                expect(slackmoji.shortcodeToEmoji("older_adult")).to(equal(Set(["🧓"])))
            }
            
            it("handles skin tone discriminators") {
                expect(slackmoji.shortcodeToEmoji("office_worker"))
                    .to(equal(Set(["🧑‍💼", "🧑🏻‍💼", "🧑🏿‍💼", "🧑🏾‍💼", "🧑🏽‍💼", "🧑🏼‍💼"])))
            }
            
            it("handles gender and skin tone discriminators combined") {
                expect(slackmoji.shortcodeToEmoji("white_haired_man"))
                    .to(equal(Set(["👨🏽‍🦳", "👨‍🦳", "👨🏾‍🦳", "👨🏿‍🦳", "👨🏻‍🦳", "👨🏼‍🦳"])))
                expect(slackmoji.shortcodeToEmoji("white_haired_woman"))
                    .to(equal(Set(["👩🏻‍🦳", "👩🏽‍🦳", "👩‍🦳", "👩🏿‍🦳", "👩🏾‍🦳", "👩🏼‍🦳"])))
                expect(slackmoji.shortcodeToEmoji("white_haired_person"))
                    .to(equal(Set(["🧑🏼‍🦳", "🧑🏽‍🦳", "🧑🏻‍🦳", "🧑🏾‍🦳", "🧑‍🦳", "🧑🏿‍🦳"])))
            }
            
            it("handles permutable skin tone discriminators") {
                expect(slackmoji.shortcodeToEmoji("woman-heart-man"))
                    .to(equal(Set(["👩‍❤️‍👨🏻", "👩🏽‍❤️‍👨🏾", "👩🏿‍❤️‍👨🏼", "👩🏼‍❤️‍👨🏾", "👩‍❤️‍👨🏿", "👩🏼‍❤️‍👨🏿", "👩🏽‍❤️‍👨🏼",
                                   "👩🏿‍❤️‍👨🏻", "👩🏾‍❤️‍👨🏻", "👩🏼‍❤️‍👨🏻", "👩🏻‍❤️‍👨🏾", "👩🏿‍❤️‍👨🏾", "👩🏽‍❤️‍👨🏿", "👩🏾‍❤️‍👨🏿",
                                   "👩‍❤️‍👨🏼", "👩🏾‍❤️‍👨🏼", "👩🏽‍❤️‍👨🏻", "👩🏿‍❤️‍👨🏽", "👩🏻‍❤️‍👨🏿", "👩🏾‍❤️‍👨🏽", "👩🏻‍❤️‍👨🏼",
                                   "👩‍❤️‍👨🏽", "👩🏼‍❤️‍👨🏽", "👩‍❤️‍👨🏾", "👩🏻‍❤️‍👨🏽"])))
            }
        }
        
        describe("#emojiToShortcodes") {
            it("returns a shortcode for a single match") {
                expect(slackmoji.emojiToShortcodes("❤️"))
                    .to(equal(Set(["heart"])))
            }
            it("returns shortcodes for multiple matches") {
                expect(slackmoji.emojiToShortcodes("🏃"))
                    .to(equal(Set(["runner", "running"])))
            }
            
            it("handles gender and skin tone discriminators") {
                expect(slackmoji.emojiToShortcodes("👩🏻‍🦳"))
                    .to(equal(Set(["white_haired_woman"])))
                expect(slackmoji.emojiToShortcodes("👨🏿‍🦳"))
                    .to(equal(Set(["white_haired_man"])))
            }
        }
    }
}
