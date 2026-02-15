//
//  RankingSheetView.swift
//  Blue_Archive_studentsQize
//
//  Created by Shinya Ikehara on 2026/02/07.
//

import SwiftUI

struct RankingSheetView: View {
    @EnvironmentObject private var rankingVM: RankingViewModel

    var body: some View {
        NavigationStack {
            Group {
                if rankingVM.isLoadingUserRanking {
                    ProgressView("ランキング取得中...")
                } else if let msg = rankingVM.userRankingError {
                    VStack(spacing: 12) {
                        Text(msg).foregroundStyle(.red)
                        Button("再読み込み") {
                            Task { await rankingVM.loadUserRanking() }
                        }
                    }
                    .padding()
                } else {
                    List(Array(rankingVM.userRanking.enumerated()), id: \.element.id) { idx, item in
                        HStack {
                            Text("#\(idx + 1)")
                                .frame(width: 44, alignment: .leading)
                            Text(item.name)
                            Spacer()
                            Text("\(item.score)")
                                .monospacedDigit()
                        }
                    }
                }
            }
            .navigationTitle("ユーザーランキング")
            .toolbar {
                Button("更新") { Task { await rankingVM.loadUserRanking() } }
            }
            .task {
                if rankingVM.userRanking.isEmpty && !rankingVM.isLoadingUserRanking {
                    await rankingVM.loadUserRanking()
                }
            }
        }
    }
}
