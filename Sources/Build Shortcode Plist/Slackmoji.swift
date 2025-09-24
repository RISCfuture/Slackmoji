let skinTones: Set<Unicode.Scalar> = Set(
  [UInt32(0x1F3FB), UInt32(0x1F3FC), UInt32(0x1F3FD), UInt32(0x1F3FE), UInt32(0x1F3FF)].map {
    Unicode.Scalar($0)!
  }
)

enum Gender: CaseIterable {
  case male, female
}

struct Slackmoji {
  var codepoints: [Codepoint]
  var shortcodeParts: [ShortcodePart]

  var genderInsertion: GenderInsertion?
  var skinInsertions: [SkinInsertion]

  private var codepointOffsetForGenderInsertion: Int? {
    codepoints.firstIndex { codepoint in
      switch codepoint {
        case .genderInsertion:
          return true
        default:
          return false
      }
    }
  }

  private var shortcodeOffsetForGenderInsertion: Int? {
    shortcodeParts.firstIndex { codepoint in
      switch codepoint {
        case .genderInsertion:
          return true
        default:
          return false
      }
    }
  }

  var allExpansions: [String: [String]] {
    if let genderInsertion {
      return Gender.allCases.reduce(into: Dictionary()) { dict, gender in
        var shortcodeParts = Array(shortcodeParts)
        let shortcodeValue = genderInsertion.shortcodePhrase.values[gender]!
        shortcodeParts[shortcodeOffsetForGenderInsertion!] = .string(shortcodeValue)
        let shortcode =
          shortcodeParts
          .map { part -> String in
            switch part {
              case .string(let value): return value
              case .genderInsertion: fatalError("Leftover gender insertion placeholder")
            }
          }
          .joined()

        var codepoints = Array(codepoints)
        let codepointValue = genderInsertion.codepointType.values[gender]!.map {
          Codepoint.codepoint($0)
        }
        let replaceIndex = codepointOffsetForGenderInsertion!
        codepoints.replaceSubrange(replaceIndex...replaceIndex, with: codepointValue)

        let unicodeValues = skinExpansions(codepoints: codepoints).map { codepoints -> String in
          codepointsToString(codepoints)
        }

        dict[shortcode] = unicodeValues
      }
    }

    let unicodeValues = skinExpansions(codepoints: codepoints).map { codepoints -> String in
      codepointsToString(codepoints)
    }
    let parts = unwrapShortcodeParts(self.shortcodeParts)
    return [parts.joined(): unicodeValues]
  }

  init() {
    shortcodeParts = []
    codepoints = []
    genderInsertion = nil
    skinInsertions = []
  }

  private func unwrapCodepoints(_ codepoints: [Codepoint]) -> [Unicode.Scalar] {
    codepoints.map { part -> Unicode.Scalar in
      switch part {
        case .codepoint(let scalar): return scalar
        default: fatalError("Leftover insertion placeholder")
      }
    }
  }

  private func unwrapShortcodeParts(_ parts: [ShortcodePart]) -> [String] {
    parts.map { part in
      switch part {
        case .string(let string): return string
        default: fatalError("Leftover insertion placeholder")
      }
    }
  }

  private func skinExpansions(codepoints: [Codepoint]) -> [[Unicode.Scalar]] {
    return skinExpansions(
      codepoints: codepoints,
      insertions: .init(skinInsertions.reversed()),
      availableSkins: .init(skinTones)
    )
  }

  private func skinsToUse(insertion: SkinInsertion, availableSkins: Set<Unicode.Scalar>) -> Set<
    Unicode.Scalar?
  > {
    var skinsToUse = Set<Unicode.Scalar?>(insertion.exclusive ? availableSkins : skinTones)
    if insertion.optional { skinsToUse.insert(nil) }
    return skinsToUse
  }

  private func skinExpansions(
    codepoints: [Codepoint],
    insertions: [SkinInsertion],
    availableSkins: Set<Unicode.Scalar>
  ) -> [[Unicode.Scalar]] {
    guard let insertion = insertions.last else {
      return [unwrapCodepoints(codepoints)]
    }
    let codepointIndex = insertions.count - 1

    return skinsToUse(insertion: insertion, availableSkins: availableSkins).reduce(into: []) {
      expansions,
      skinCodepoint in
      var codepointsWithSkin = Array(codepoints)
      let insertionOffset = findCodepointOffsetForSkinInsertion(index: codepointIndex)!

      if let skinCodepoint {
        codepointsWithSkin[insertionOffset] = .codepoint(skinCodepoint)
      } else {
        codepointsWithSkin.remove(at: insertionOffset)
      }

      let skins = skinExpansions(
        codepoints: codepointsWithSkin,
        insertions: insertions.dropLast(),
        availableSkins: availableSkins.filter { $0 != skinCodepoint }
      )
      expansions.append(contentsOf: skins)
    }
  }

  private func findCodepointOffsetForSkinInsertion(index: Int) -> Int? {
    codepoints.firstIndex { part in
      switch part {
        case .skinInsertion(let thisIndex): return thisIndex == index
        default: return false
      }
    }
  }

  private func codepointsToString(_ codepoints: [Unicode.Scalar]) -> String {
    var unicode = ""
    unicode.unicodeScalars.append(contentsOf: codepoints)
    return unicode
  }

  enum Codepoint {
    case codepoint(_ scalar: Unicode.Scalar)
    case genderInsertion
    case skinInsertion(index: Int)
  }

  enum ShortcodePart {
    case string(_ string: String)
    case genderInsertion
  }

  struct GenderInsertion {
    let codepointType: CodepointType
    let shortcodePhrase: ShortcodePhrase

    func codepointValues(gender: Gender) -> [Unicode.Scalar] {
      codepointType.values[gender]!
    }

    enum CodepointType {
      case manWoman
      case maleFemale

      var values: [Gender: [Unicode.Scalar]] { Self.values[self]! }

      static let values: [Self: [Gender: [Unicode.Scalar]]] = [
        .manWoman: [
          .male: [Unicode.Scalar(UInt32(0x1F468))!],
          .female: [Unicode.Scalar(UInt32(0x1F469))!]
        ],
        .maleFemale: [
          .male: [Unicode.Scalar(UInt32(0x2642))!, Unicode.Scalar(UInt32(0xFE0F))!],
          .female: [Unicode.Scalar(UInt32(0x2640))!, Unicode.Scalar(UInt32(0xFE0F))!]
        ]
      ]
    }

    enum ShortcodePhrase {
      case manWoman
      case maleFemale

      var values: [Gender: String] { Self.values[self]! }

      static let values: [Self: [Gender: String]] = [
        .manWoman: [.male: "man", .female: "woman"],
        .maleFemale: [.male: "male", .female: "female"]
      ]
    }
  }

  struct SkinInsertion {
    let optional: Bool
    let exclusive: Bool
  }

  private struct Expansion {
    let shortcode: String
    let codepoints: [Unicode.Scalar]
  }
}
