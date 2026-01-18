//
//  Model.swift
//  Blue_Archive_studentsQize
//
//  Created by Shinya Ikehara on 2026/01/09.
//

import Foundation

struct StudentsResponse: Decodable {
    let message: String
    let total: Int?
    let count: Int?
    let data: [Student]
}

struct Student: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let rarity: Int
    let weapon: Weapon
    let role: Role
    let school: String
    let combat: Combat
    let terrainAdaptation: TerrainAdaptation
}

struct Weapon: Decodable, Hashable {
    let type: String
    let cover: Bool
}

struct Role: Decodable, Hashable {
    let type: String
    let roleClass: String
    let position: String

    enum CodingKeys: String, CodingKey {
        case type
        case roleClass = "class"
        case position
    }
}

struct Combat: Decodable, Hashable {
    let attackType: String
    let defenseType: String
}

struct TerrainAdaptation: Decodable, Hashable {
    let city: String
    let outdoor: String
    let indoor: String
}


enum ResultPopup: Equatable {
    case correct
    case passed
}

enum HintKey: String, CaseIterable, Identifiable, Hashable {

    case attackType, defenseType
    case weaponType
    case city, outdoor, indoor

    case weaponCover
    case roleClass
    case position
    case rarity
    case roleType
    case school

    var id: String { rawValue }

    var title: String {
        switch self {
        case .attackType: return "攻撃タイプ"
        case .defenseType: return "防御タイプ"
        case .weaponType: return "武器種"
        case .city: return "市街地"
        case .outdoor: return "屋外"
        case .indoor: return "屋内"
        case .weaponCover: return "遮蔽物"
        case .roleClass: return "クラス"
        case .position: return "ポジション"
        case .rarity: return "レア度"
        case .roleType: return "STRIKER/SPECIAL"
        case .school: return "学校"
        }
    }

    var isInitiallyRevealed: Bool {
        switch self {
        case .attackType, .defenseType, .weaponType, .city, .outdoor, .indoor:
            return true
        default:
            return false
        }
    }

    var requiredExtraReveals: Int {
        switch self {
        case .roleType: return 1
        case .school: return 3
        default: return 0
        }
    }

    static var initialHints: [HintKey] {
        HintKey.allCases.filter { Key in Key.isInitiallyRevealed }
    }
}

struct QuizScoringRule {
    let maxPerQuestion: Int
    let penaltyPerExtraHint: Int

    static let normal = QuizScoringRule(maxPerQuestion: 10, penaltyPerExtraHint: 2)

    func score(extraRevealsCount: Int) -> Int {
        max(0, maxPerQuestion - extraRevealsCount * penaltyPerExtraHint)
    }
}

enum AnswerJudgeResult: Equatable {
    case correct
    case wrong
    case needVariant(variant: String)
}

struct AnswerJudgeRule {
    static let normal = AnswerJudgeRule()

    func judge(input: String, correctName: String) -> AnswerJudgeResult {
        let inputN = normalizeForJudge(input)

        let (base, variant) = splitBaseAndVariant(from: correctName)
        let baseN = normalizeForJudge(base)

        guard inputN.contains(baseN) else { return .wrong }

        if let variant, !variant.isEmpty {
            let variantN = normalizeForJudge(variant)
            return inputN.contains(variantN) ? .correct : .needVariant(variant: variant)
        } else {
            return .correct
        }
    }

    private func splitBaseAndVariant(from name: String) -> (base: String, variant: String?) {
        let s = name
            .replacingOccurrences(of: "（", with: "(")
            .replacingOccurrences(of: "）", with: ")")

        guard let l = s.firstIndex(of: "("),
              let r = s[l...].firstIndex(of: ")"),
              l < r else {
            return (name, nil)
        }

        let base = String(s[..<l])
        let variant = String(s[s.index(after: l)..<r])
        return (base, variant)
    }

    private func normalizeForJudge(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "　", with: "")
            .replacingOccurrences(of: "（", with: "")
            .replacingOccurrences(of: "）", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "・", with: "")
            .lowercased()
    }
}

extension Student {
    func hintValue(for key: HintKey) -> String {
        switch key {
        case .attackType: return combat.attackType
        case .defenseType: return combat.defenseType
        case .weaponType: return weapon.type
        case .city: return terrainAdaptation.city
        case .outdoor: return terrainAdaptation.outdoor
        case .indoor: return terrainAdaptation.indoor

        case .weaponCover: return weapon.cover ? "⭕️" : "❌"
        case .roleClass: return role.roleClass
        case .position: return role.position
        case .rarity: return "★\(rarity)"

        case .roleType: return role.type
        case .school: return school
        }
    }
}
