import Foundation

private let emojiDataDirectory = "emoji-data/build"
private let emojiDataPrefix = "data_emoji_names"
private let emojiDataSuffix = ".txt"

/// Lists the emoji data files in the submodule, in a stable order.
///
/// - Returns: The paths of all files matching `emoji-data/build/data_emoji_names*.txt`.
/// - Throws: If the emoji data directory can't be read.
private func emojiDataFiles() throws -> [String] {
  try FileManager.default.contentsOfDirectory(atPath: emojiDataDirectory)
    .filter { $0.hasPrefix(emojiDataPrefix) && $0.hasSuffix(emojiDataSuffix) }
    .sorted()
    .map { "\(emojiDataDirectory)/\($0)" }
}

/// Creates an async stream that yields the contents of all emoji data files.
///
/// Reads all files matching `emoji-data/build/data_emoji_names*.txt` from the submodule
/// and yields their contents as strings.
///
/// - Returns: An async throwing stream of file contents.
func emojiData() -> AsyncThrowingStream<String, any Error> {
  AsyncThrowingStream { continuation in
    do {
      for file in try emojiDataFiles() {
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
