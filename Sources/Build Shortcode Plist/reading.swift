import Foundation
import Glob

func emojiData() -> AsyncThrowingStream<String, Error> {
    AsyncThrowingStream { continuation in
        do {
            for file in Glob(pattern: "emoji-data/build/data_emoji_names*.txt") {
                let url = URL(filePath: file, directoryHint: .notDirectory),
                    data = try Data(contentsOf: url),
                    contents = String(data: data, encoding: .ascii)!
                continuation.yield(contents)
            }
        } catch {
            continuation.finish(throwing: error)
        }
        continuation.finish()
    }
}
