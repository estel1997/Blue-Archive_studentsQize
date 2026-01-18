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
    
    var body: some View {
        ZStack {
            Color(.systemTeal).opacity(0.06)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Text("結果")
                    .font(.largeTitle.bold())
                
                Text("スコア: \(score)点")
                    .font(.title2)
                
                HStack(spacing: 12) {
                    Button("もう一度", action: onRetry)
                        .buttonStyle(.borderedProminent)
                    
                    Button("タイトルへ", action: onExit)
                        .buttonStyle(.bordered)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
}
