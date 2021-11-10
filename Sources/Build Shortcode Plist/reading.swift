import Foundation
import Glob

func emojiData(callback: ((String) -> Void)) {
    for file in Glob(pattern: "emoji-data/build/data_emoji_names*.txt") {
        let url = URL(fileURLWithPath: file)
        let data = try! Data(contentsOf: url)
        let contents = String(data: data, encoding: .ascii)!
        callback(contents)
    }
}
