//
//  API.swift
//  Blue_Archive_studentsQize
//
//  Created by Shinya Ikehara on 2026/01/09.
//

import Foundation

enum APIError: Error, LocalizedError {
    case badURL
    case badStatus(Int)
    case decoding
    
    var errorDescription: String?{
        switch self {
        case .badURL: return "URLが不正です"
        case let .badStatus(code): return "通信に失敗しました（HTTP \(code)"
        case .decoding: return "データ形式の解析に失敗しました"
        }
    }
}

struct BlueArchiveAPI {
    
    let baseURL = URL(string: "https://bluearchive-api.skyia.jp")!
    
    func fetchStudents(limit: Int? = nil) async throws -> [Student] {
        var urlcomps = URLComponents(url: baseURL.appendingPathComponent("/api/students"),
                                     resolvingAgainstBaseURL: false)
        
        if let limit {
            urlcomps?.queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        }
        
        guard let url = urlcomps?.url else {throw APIError.badURL }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let (data,response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else{ throw APIError.badStatus(0)}
        
        guard (200..<300).contains(http.statusCode) else { throw APIError.badStatus(http.statusCode)}
        
        do {
            let response = try JSONDecoder().decode(StudentsResponse.self, from: data)
            return response.data
        }catch{
            throw APIError.decoding
        }
    }
}
