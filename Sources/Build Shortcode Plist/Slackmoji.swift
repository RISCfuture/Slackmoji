fileprivate let skinTones: Set<Unicode.Scalar> = Set([UInt32(0x1F3FB), UInt32(0x1F3FC), UInt32(0x1F3FD), UInt32(0x1F3FE), UInt32(0x1F3FF)].map { Unicode.Scalar($0)! })

fileprivate enum Gender: CaseIterable {
    case male, female
}

struct Slackmoji {
    var codepoints: Array<Codepoint>
    var shortcodeParts: Array<ShortcodePart>
    
    var genderInsertion: GenderInsertion?
    var skinInsertions: Array<SkinInsertion>
    
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
        
        fileprivate func codepointValues(gender: Gender) -> Array<Unicode.Scalar> {
            codepointType.values[gender]!
        }
        
        enum CodepointType {
            case manWoman
            case maleFemale
            
            fileprivate var values: Dictionary<Gender, Array<Unicode.Scalar>> { Self.values[self]! }
            
            fileprivate static let values: Dictionary<Self, Dictionary<Gender, Array<Unicode.Scalar>>> = [
                .manWoman: [
                    .male: [Unicode.Scalar(UInt32(0x1F468))!],
                    .female: [Unicode.Scalar(UInt32(0x1F469))!]
                ],
                .maleFemale: [
                    .male: [Unicode.Scalar(UInt32(0x2642))!, Unicode.Scalar(UInt32(0xFE0F))!],
                    .female: [Unicode.Scalar(UInt32(0x2640))!, Unicode.Scalar(UInt32(0xFE0F))!],
                ]
            ]
        }
        
        enum ShortcodePhrase {
            case manWoman
            case maleFemale
            
            fileprivate var values: Dictionary<Gender, String> { Self.values[self]! }
            
            fileprivate static let values: Dictionary<Self, Dictionary<Gender, String>> = [
                .manWoman: [.male: "man", .female: "woman"],
                .maleFemale: [.male: "male", .female: "female"]
            ]
        }
    }
    
    struct SkinInsertion {
        let optional: Bool
        let exclusive: Bool
    }
    
    init() {
        shortcodeParts = []
        codepoints = []
        genderInsertion = nil
        skinInsertions = []
    }
    
    private struct Expansion {
        let shortcode: String
        let codepoints: Array<Unicode.Scalar>
    }
    
    private func unwrapCodepoints(_ codepoints: Array<Codepoint>) -> Array<Unicode.Scalar> {
        codepoints.map { part -> Unicode.Scalar in
            switch part {
            case .codepoint(let scalar): return scalar
            default: fatalError("Leftover insertion placeholder")
            }
        }
    }
    
    private func unwrapShortcodeParts(_ parts: Array<ShortcodePart>) -> Array<String> {
        parts.map { part in
            switch part {
            case .string(let string): return string
            default: fatalError("Leftover insertion placeholder")
            }
        }
    }
    
    private func skinExpansions(codepoints: Array<Codepoint>) -> Array<Array<Unicode.Scalar>> {
        return skinExpansions(codepoints: codepoints, insertions: .init(skinInsertions.reversed()), availableSkins: .init(skinTones))
    }
    
    private func skinsToUse(insertion: SkinInsertion, availableSkins: Set<Unicode.Scalar>) -> Set<Unicode.Scalar?> {
        var skinsToUse = Set<Unicode.Scalar?>(insertion.exclusive ? availableSkins : skinTones)
        if insertion.optional { skinsToUse.insert(nil) }
        return skinsToUse
    }
        
    private func skinExpansions(codepoints: Array<Codepoint>, insertions: Array<SkinInsertion>, availableSkins: Set<Unicode.Scalar>) -> Array<Array<Unicode.Scalar>> {
        guard let insertion = insertions.last else {
            return [unwrapCodepoints(codepoints)]
        }
        let codepointIndex = insertions.count - 1
        
        return skinsToUse(insertion: insertion, availableSkins: availableSkins).reduce(into: []) { expansions, skinCodepoint in
            var codepointsWithSkin = Array(codepoints)
            let insertionOffset = findCodepointOffsetForSkinInsertion(index: codepointIndex)!
            
            if let skinCodepoint {
                codepointsWithSkin[insertionOffset] = .codepoint(skinCodepoint)
            } else {
                codepointsWithSkin.remove(at: insertionOffset)
            }

            let skins = skinExpansions(codepoints: codepointsWithSkin, insertions: insertions.dropLast(), availableSkins: availableSkins.filter { $0 != skinCodepoint })
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
    
    private func codepointsToString(_ codepoints: Array<Unicode.Scalar>) -> String {
        var unicode = ""
        unicode.unicodeScalars.append(contentsOf: codepoints)
        return unicode
    }
    
    var allExpansions: Dictionary<String, Array<String>> {
        if let genderInsertion {
            return Gender.allCases.reduce(into: Dictionary()) { dict, gender in
                var shortcodeParts = Array(self.shortcodeParts)
                let shortcodeValue = genderInsertion.shortcodePhrase.values[gender]!
                shortcodeParts[shortcodeOffsetForGenderInsertion!] = .string(shortcodeValue)
                let shortcode = shortcodeParts.map { part -> String in
                    switch part {
                    case .string(let value): return value
                    case .genderInsertion: fatalError("Leftover gender insertion placeholder")
                    }
                }.joined()
                
                var codepoints = Array(self.codepoints)
                let codepointValue = genderInsertion.codepointType.values[gender]!.map { Codepoint.codepoint($0) }
                let replaceIndex = codepointOffsetForGenderInsertion!
                codepoints.replaceSubrange(replaceIndex...replaceIndex, with: codepointValue)
                
                let unicodeValues = skinExpansions(codepoints: codepoints).map { codepoints -> String in
                    codepointsToString(codepoints)
                }
                
                dict[shortcode] = unicodeValues
            }
        } else {
            let unicodeValues = skinExpansions(codepoints: codepoints).map { codepoints -> String in
                codepointsToString(codepoints)
            }
            let shortcodeParts = unwrapShortcodeParts(self.shortcodeParts)
            return [shortcodeParts.joined(): unicodeValues]
        }
    }
}
