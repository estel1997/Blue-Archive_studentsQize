//
//  Untitled.swift
//  Blue_Archive_studentsQize
//
//  Created by Shinya Ikehara on 2026/01/27.
//

import Foundation

struct LocalScoreEntry: Codable, Identifiable, Hashable {
    let id: UUID
    let playerName: String
    let score: Int
    let date: Date
    
    init(playerName: String, score: Int, date: Date = Date()){
        self.id = UUID()
        self.playerName = playerName
        self.score = score
        self.date = date
    }
}

final class LocalRankingRepository {
    private enum Keys {
        static let playerName = "playerName"
        static let localScores = "localScores"
    }
    
    func playerName() -> String {
        UserDefaults.standard.string(forKey: Keys.playerName) ?? ""
    }
    
    func save(playerName: String){
        UserDefaults.standard.set(playerName, forKey: Keys.playerName)
    }
    
    func scores() -> [LocalScoreEntry] {
        guard let data = UserDefaults.standard.data(forKey: Keys.localScores) else {return []}
        return (try? JSONDecoder().decode([LocalScoreEntry].self, from: data)) ?? []
    }
    
    func save(scores: [LocalScoreEntry]) {
        guard let data = try? JSONEncoder().encode(scores) else {return}
        UserDefaults.standard.set(data, forKey: Keys.localScores)
    }
    
    func add(playerName: String, score: Int, keepTop: Int = 5) -> [LocalScoreEntry] {
        var list = scores()
        list.append(LocalScoreEntry(playerName: playerName, score: score))
        list.sort { $0.score > $1.score }
        list = Array(list.prefix(keepTop))
        save(scores: list)
        return list
    }
    
}

