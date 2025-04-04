import Foundation
import RegularExpressions

struct ParsedCodepoints {
    var prunedCodepoints: [Slackmoji.Codepoint]
    var genderInsertion: GenderInsertion?
    var skinInsertions: [Slackmoji.SkinInsertion]

    init() {
        prunedCodepoints = []
        genderInsertion = nil
        skinInsertions = []
    }

    struct GenderInsertion {
        let type: Slackmoji.GenderInsertion.CodepointType
        let index: Int
    }
}

struct ParsedShortcode {
    var shortcodeParts: [Slackmoji.ShortcodePart]
    var genderInsertion: GenderInsertion?

    init() {
        shortcodeParts = []
        genderInsertion = nil
    }

    struct GenderInsertion {
        let phrase: Slackmoji.GenderInsertion.ShortcodePhrase
        let index: Int
    }
}

private let codepointSpecialChars = CharacterSet(charactersIn: "-{")
private let shortcodeSpecialChars = CharacterSet(charactersIn: "{/")
private let emojiDecorator = Unicode.Scalar(UInt32(0xFE0F))!
private let zwj = 0x200D

private func parseCodepoints(codepoints: Substring) -> ParsedCodepoints {
    var parsed = ParsedCodepoints()
    var lastSkinInsertionIndex = 0

    let scanner = Scanner(string: String(codepoints))
    while !scanner.isAtEnd {
        let str = scanner.scanUpToCharacters(from: codepointSpecialChars)
        if let str {
            let int = Int(str, radix: 16)!
            let scalar = Unicode.Scalar(int)!
            parsed.prunedCodepoints.append(.codepoint(scalar))
        }
        guard !scanner.isAtEnd else { break }

        switch scanner.scanCharacter() {
            case Character("{"):
                guard let token = scanner.scanUpToString("}") else {
                    fatalError("Empty token: \(codepoints.debugDescription)")
                }

                switch token {
                    case "MAN/WOMAN", "M/W":
                        guard parsed.genderInsertion == nil else {
                            fatalError("Can't have multiple gender insertions in a single codepoint")
                        }
                        parsed.genderInsertion = .init(type: .manWoman, index: parsed.prunedCodepoints.endIndex)
                        parsed.prunedCodepoints.append(.genderInsertion)
                    case "MALE/FEMALE", "GENDER":
                        guard parsed.genderInsertion == nil else {
                            fatalError("Can't have multiple gender insertions in a single codepoint")
                        }
                        parsed.genderInsertion = .init(type: .maleFemale, index: parsed.prunedCodepoints.endIndex)
                        parsed.prunedCodepoints.append(.genderInsertion)
                    case "SKIN", "SKIN2":
                        parsed.skinInsertions.append(.init(optional: true, exclusive: false))
                        parsed.prunedCodepoints.append(.skinInsertion(index: lastSkinInsertionIndex))
                        lastSkinInsertionIndex += 1
                    case "SKIN!":
                        parsed.skinInsertions.append(.init(optional: false, exclusive: false))
                        parsed.prunedCodepoints.append(.skinInsertion(index: lastSkinInsertionIndex))
                        lastSkinInsertionIndex += 1
                    case "SKIN2x":
                        parsed.skinInsertions.append(.init(optional: true, exclusive: true))
                        parsed.prunedCodepoints.append(.skinInsertion(index: lastSkinInsertionIndex))
                        lastSkinInsertionIndex += 1
                    default:
                        fatalError("Unrecognized shortcode token \(token)")
                }

                precondition(scanner.scanCharacter() == "}", "Expected to scan '}'")
            case Character("-"):
                continue
            default:
                preconditionFailure("Unexpected scan result")
        }
    }

    if parsed.prunedCodepoints.count == 1 {
        switch parsed.prunedCodepoints[0] {
            case .codepoint(let scalar):
                if scalar.value >= 0x2000 && scalar.value < 0x3000 {
                    parsed.prunedCodepoints.append(.codepoint(emojiDecorator))
                }
            default: break
        }
    }

    return parsed
}

private func parseShortcode(shortcodes: Substring) -> [ParsedShortcode] {
    var parsedShortcodes = [ParsedShortcode]()
    var currentParsed = ParsedShortcode()

    let scanner = Scanner(string: String(shortcodes))
    while !scanner.isAtEnd {
        let str = scanner.scanUpToCharacters(from: shortcodeSpecialChars)
        if let str {
            currentParsed.shortcodeParts.append(.string(str))
        }
        guard !scanner.isAtEnd else { break }

        switch scanner.scanCharacter() {
            case Character("{"):
                guard let token = scanner.scanUpToString("}") else {
                    fatalError("Empty token: \(shortcodes.debugDescription)")
                }

                switch token {
                    case "MAN/WOMAN", "M/W":
                        guard currentParsed.genderInsertion == nil else {
                            fatalError("Can't have multiple gender insertions in a single codepoint")
                        }
                        currentParsed.genderInsertion = .init(phrase: .manWoman, index: currentParsed.shortcodeParts.endIndex)
                        currentParsed.shortcodeParts.append(.genderInsertion)
                    case "MALE/FEMALE", "GENDER":
                        guard currentParsed.genderInsertion == nil else {
                            fatalError("Can't have multiple gender insertions in a single codepoint")
                        }
                        currentParsed.genderInsertion = .init(phrase: .maleFemale, index: currentParsed.shortcodeParts.endIndex)
                        currentParsed.shortcodeParts.append(.genderInsertion)
                    default:
                        fatalError("Unrecognized shortcode token \(token)")
                }

                precondition(scanner.scanCharacter() == "}", "Expected to scan '}'")
            case Character("/"):
                parsedShortcodes.append(currentParsed)
                currentParsed = ParsedShortcode()
            default:
                preconditionFailure("Unexpected scan result")
        }
    }

    if !currentParsed.shortcodeParts.isEmpty { parsedShortcodes.append(currentParsed) }
    return parsedShortcodes
}

func makeSlackmoji(codepoints: Substring, shortcodes: Substring) -> [Slackmoji] {
    let parsedCodepoints = parseCodepoints(codepoints: codepoints)
    let parsedShortcodes = parseShortcode(shortcodes: shortcodes)

    return parsedShortcodes.map { parsedShortcode in
        var slackmoji = Slackmoji()
        slackmoji.shortcodeParts = parsedShortcode.shortcodeParts
        slackmoji.codepoints = parsedCodepoints.prunedCodepoints

        if let shortcodeGenderInsertion = parsedShortcode.genderInsertion {
            guard let codepointGenderInsertion = parsedCodepoints.genderInsertion else {
                fatalError("Gender insertion in shortcode must have corresponding gender insertion in codepoint")
            }
            slackmoji.genderInsertion = .init(codepointType: codepointGenderInsertion.type, shortcodePhrase: shortcodeGenderInsertion.phrase)
        } else {
            guard parsedCodepoints.genderInsertion == nil else {
                fatalError("Gender insertion in shortcode must have corresponding gender insertion in codepoint")
            }
        }

        slackmoji.skinInsertions = parsedCodepoints.skinInsertions

        return slackmoji
    }
}
