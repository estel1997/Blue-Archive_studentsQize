//
//  View_title.swift
//  Blue_Archive_studentsQize
//
//  Created by Shinya Ikehara on 2026/01/09.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject private var rankingVM: RankingViewModel
    @State private var showRankingSheet = false
    
    let onStart: () -> Void

    var body: some View {
        ZStack {
            Color(.systemTeal).opacity(0.15).ignoresSafeArea()

            VStack(spacing: 16) {
                Text("ブルーアーカイブ\nキャラクタークイズ")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                TextField(
                    "名前（匿名先生）",
                    text: Binding(
                        get: { rankingVM.playerName },
                        set: { rankingVM.updatePlayerName($0) }
                    )
                )
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

                HStack(spacing: 12) {
                    Button("ランキング"){ showRankingSheet = true }
                        .buttonStyle(.bordered)

                    Button("ゲームスタート!!", action: onStart)
                        .frame(width: 220)
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showRankingSheet){
            RankingSheetView()
        }
    }
}
