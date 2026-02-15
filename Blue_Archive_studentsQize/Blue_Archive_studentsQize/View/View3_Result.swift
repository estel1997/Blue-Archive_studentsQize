//
//  View_Result.swift
//  Blue_Archive_studentsQize
//
//  Created by Shinya Ikehara on 2026/01/09.
//

import SwiftUI

struct ResultView: View {
    let score: Int
    let onRetry: () -> Void
    let onExit: () -> Void
    
    @EnvironmentObject private var rankingVM: RankingViewModel
    
    var body: some View {
        ZStack {
            Color(.systemTeal).opacity(0.06)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Text("結果")
                    .font(.largeTitle.bold())
                
                Text("あなたのスコア: \(score)点")
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack{
                        Text("ユーザーランキング").font(.headline)
                        Spacer()
                        if rankingVM.isLoadingUserRanking {
                            ProgressView().scaleEffect(0.9)
                        } else {
                            Button("更新") {
                                Task { await rankingVM.loadUserRanking() }
                            }
                            .font(.subheadline)
                        }
                    }
                    
                    if let msg = rankingVM.userRankingError {
                        Text(msg).foregroundStyle(.red).font(.footnote)
                    }
                    
                    List(Array(rankingVM.userRanking.prefix(10).enumerated()), id: \.element.id) { idx, item in
                        HStack {
                            Text("\(idx + 1)位").frame(width: 44, alignment: .leading)
                            Text("\(item.score)点")
                                .monospacedDigit()
                                .padding(.trailing, 16)
                            Text(item.name)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                        }
                    }
                    .frame(height: 260)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("自己ベストランキング").font(.headline)
                    
                    if rankingVM.localRanking.isEmpty {
                        Text("まだ記録がありません").font(.footnote).foregroundStyle(.secondary)
                    } else {
                        VStack(spacing: 6) {
                            ForEach(Array(rankingVM.localRanking.enumerated()), id: \.element.id) { idx, entry in
                                HStack {
                                    Text("\(idx + 1)位").frame(width: 44, alignment: .leading)
                                    Text("\(entry.score)点")
                                          .monospacedDigit()
                                          .padding(.trailing, 16)
                                    Text(entry.playerName)
                                                    .font(.subheadline.weight(.semibold))
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                
                .padding(.horizontal)
                
                HStack(spacing: 12) {
                    Button("もう一度", action: onRetry)
                        .buttonStyle(.borderedProminent)
                    
                    Button("タイトルへ", action: onExit)
                        .buttonStyle(.bordered)
                }
                .padding(.top, 8)
            }
            .padding(.vertical)
        }
        .task {
            rankingVM.recordLocalScore(score)
            
            await rankingVM.submitScoreAndRefreshUserRanking(score)
        }
    }
}
