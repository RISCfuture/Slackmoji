import Foundation
import Glob

/// Creates an async stream that yields the contents of all emoji data files.
///
/// Reads all files matching `emoji-data/build/data_emoji_names*.txt` from the submodule
/// and yields their contents as strings.
///
/// - Returns: An async throwing stream of file contents.
func emojiData() -> AsyncThrowingStream<String, Error> {
  AsyncThrowingStream { continuation in
    do {
      for file in Glob(pattern: "emoji-data/build/data_emoji_names*.txt") {
        let url = URL(filePath: file, directoryHint: .notDirectory)
        let data = try Data(contentsOf: url)
        let contents = String(data: data, encoding: .ascii)!
        continuation.yield(contents)
      }
    } catch {
      continuation.finish(throwing: error)
    }
    continuation.finish()
  }
}
