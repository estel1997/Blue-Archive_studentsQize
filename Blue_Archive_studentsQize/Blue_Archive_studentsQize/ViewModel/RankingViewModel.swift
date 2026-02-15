//
//  RankingModel.swift
//  Blue_Archive_studentsQize
//
//  Created by Shinya Ikehara on 2026/01/27.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class RankingViewModel: ObservableObject {

    @Published var playerName: String = ""
    @Published private(set) var localRanking: [LocalScoreEntry] = []
    @Published private(set) var userRanking: [RankingEntry] = []
    
    @Published private(set) var isLoadingUserRanking: Bool = false
    @Published private(set) var userRankingError: String? = nil

    private let localRepo: LocalRankingRepository
    private let api: RankingAPI
    private let topLimit: Int

    init(
        localRepo: LocalRankingRepository? = nil,
        api: RankingAPI? = nil,
        topLimit: Int = 10
    ) {
        self.localRepo = localRepo ?? LocalRankingRepository()
        self.api = api ?? RankingAPI()
        self.topLimit = topLimit
    }
    
    func updatePlayerName(_ name: String) {
        playerName = name
        localRepo.save(playerName: name)
    }

    var displayName: String {
        let trimmed = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "匿名先生" : trimmed
    }

    func recordLocalScore(_ score: Int) {
        localRanking = localRepo.add(playerName: displayName, score: score, keepTop: 5)
    }
    
    func loadUserRanking() async {
        isLoadingUserRanking = true
        userRankingError = nil
        do{
            userRanking = try await api.fetchTop(limit: topLimit)
            isLoadingUserRanking = false
        } catch{
            isLoadingUserRanking = false
            userRankingError = (error as? LocalizedError)?.errorDescription ?? "ユーザーランキングの取得に失敗しました。"
        }
    }
    
    func submitScoreAndRefreshUserRanking(_ score: Int) async{
        isLoadingUserRanking = true
        userRankingError = nil
        do{
            //返り値を使っていないとの警告が出ていたので、”_ =”で意図的に捨てる事を明示
            _ = try await api.postScore(name: displayName, score: score)
            userRanking = try await api.fetchTop(limit: topLimit)
            isLoadingUserRanking = false
        } catch{
            isLoadingUserRanking = false
            userRankingError = (error as? LocalizedError)?.errorDescription ?? "ランキングの更新に失敗しました。"
        }
    }
    
}

