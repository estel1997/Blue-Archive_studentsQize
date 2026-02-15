//
//  Ranking.swift
//  Blue_Archive_studentsQize
//
//  Created by Shinya Ikehara on 2026/01/27.
//

import Foundation

struct RankingEntry: Codable, Identifiable, Hashable {
    let id: UUID?
    let created_at: Date?
    let name: String
    let score: Int
}

struct RankingInsert: Codable {
    let name: String
    let score: Int
}

enum RankingAPIError: Error, LocalizedError {
    case badURL
    case badStatus(Int)
    case decoding(Error)
    
    var errorDescription: String? {
        switch self {
        case .badURL:
            return "ランキングURLが不正です"
        case .badStatus(let code):
            return "ランキング通信に失敗しました。ステータスコード:\(code)"
        case .decoding:
            return "ランキングの解析に失敗しました"
        }
    }
}

struct RankingAPI {
    
    private let base = URL(string: "https://nkgjmvgdpesnlezshwlw.supabase.co")!
    private let anonKey = "sb_publishable_hCw8XzOggSPSAlOiFni-Zg_AmbBBY-B"
    
    private var endpoint: URL {
        base.appendingPathComponent("/rest/v1/UserRanking")
    }
    
    func fetchTop(limit: Int) async throws -> [RankingEntry] {
        var comps = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        comps?.queryItems = [
            URLQueryItem(name: "select", value: "*"),
            URLQueryItem(name: "order", value: "score.desc,created_at.asc"),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        guard let url = comps?.url else {
            throw RankingAPIError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RankingAPIError.badStatus(0)
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw RankingAPIError.badStatus(httpResponse.statusCode)
        }
        
        do{
            let dec = JSONDecoder()
            dec.dateDecodingStrategy = .iso8601
            return try dec.decode([RankingEntry].self, from: data)
        } catch{
            throw RankingAPIError.decoding(error)
        }
    }
    
    func postScore(name: String, score: Int) async throws -> [RankingEntry] {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        
        let body = [RankingInsert(name: name, score: score)]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RankingAPIError.badStatus(0)
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw RankingAPIError.badStatus(httpResponse.statusCode)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([RankingEntry].self, from: data)
    }
}
