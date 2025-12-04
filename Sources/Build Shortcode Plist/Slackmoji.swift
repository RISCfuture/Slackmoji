/// Set of Unicode scalar values representing the five Fitzpatrick skin tone modifiers.
let skinTones: Set<Unicode.Scalar> = Set(
  [UInt32(0x1F3FB), UInt32(0x1F3FC), UInt32(0x1F3FD), UInt32(0x1F3FE), UInt32(0x1F3FF)].map {
    Unicode.Scalar($0)!
  }
)

/// Represents a binary gender for emoji variants.
enum Gender: CaseIterable {
  case male, female
}

/// Represents a Slack emoji shortcode with its Unicode representation and variation metadata.
///
/// A `Slackmoji` instance holds the parsed data needed to generate all possible expansions
/// of an emoji, including skin tone and gender variants. The `allExpansions` property
/// computes the full set of shortcode-to-emoji mappings.
struct Slackmoji {
  /// The Unicode codepoint sequence with insertion placeholders.
  var codepoints: [Codepoint]
  /// The shortcode segments with insertion placeholders.
  var shortcodeParts: [ShortcodePart]

  /// Gender insertion metadata for generating gendered variants.
  var genderInsertion: GenderInsertion?
  /// Skin tone insertion points for generating skin tone variants.
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

  /// Computes all shortcode-to-emoji mappings for this emoji, including all variations.
  ///
  /// Expands gender and skin tone variations to produce a dictionary mapping each
  /// possible shortcode to its array of Unicode emoji strings.
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

  /// Represents a single element in a codepoint sequence.
  enum Codepoint {
    /// A literal Unicode scalar value.
    case codepoint(_ scalar: Unicode.Scalar)
    /// Placeholder for gender-specific codepoint insertion.
    case genderInsertion
    /// Placeholder for skin tone modifier insertion at the given index.
    case skinInsertion(index: Int)
  }

  /// Represents a single element in a shortcode sequence.
  enum ShortcodePart {
    /// A literal string segment.
    case string(_ string: String)
    /// Placeholder for gender-specific phrase insertion.
    case genderInsertion
  }

  /// Describes how to generate gendered variants of an emoji.
  struct GenderInsertion {
    /// The type of Unicode codepoint to insert for each gender.
    let codepointType: CodepointType
    /// The shortcode phrase pattern to insert for each gender.
    let shortcodePhrase: ShortcodePhrase

    func codepointValues(gender: Gender) -> [Unicode.Scalar] {
      codepointType.values[gender]!
    }

    /// Types of gender-specific Unicode codepoints.
    enum CodepointType {
      /// Man (👨) or Woman (👩) emoji characters.
      case manWoman
      /// Male (♂️) or Female (♀️) symbol characters.
      case maleFemale

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

      var values: [Gender: [Unicode.Scalar]] { Self.values[self]! }
    }

    /// Types of gender-specific shortcode phrases.
    enum ShortcodePhrase {
      /// "man" or "woman" phrases.
      case manWoman
      /// "male" or "female" phrases.
      case maleFemale

      static let values: [Self: [Gender: String]] = [
        .manWoman: [.male: "man", .female: "woman"],
        .maleFemale: [.male: "male", .female: "female"]
      ]

      var values: [Gender: String] { Self.values[self]! }
    }
  }

  /// Describes how to generate skin tone variants at an insertion point.
  struct SkinInsertion {
    /// Whether the skin tone modifier can be omitted (base emoji without skin tone).
    let optional: Bool
    /// Whether the skin tone must differ from other insertions (for multi-person emoji).
    let exclusive: Bool
  }

  private struct Expansion {
    let shortcode: String
    let codepoints: [Unicode.Scalar]
  }
}
