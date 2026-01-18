//
//  View_title.swift
//  Blue_Archive_studentsQize
//
//  Created by Shinya Ikehara on 2026/01/09.
//

import SwiftUI

struct StartView: View {
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                Color(.systemTeal).opacity(0.15)
                    .ignoresSafeArea()
                
                VStack(spacing: 10){
                    
                    Image("2.title")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                    Text("ブルーアーカイブ\n生徒当てクイズ！")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    NavigationLink{
                        QuizView()
                    }label:{
                        Text("ゲームスタート！！")
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                            .frame(width: 300, height: 48)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                }
            }
        }
    }
}
#Preview {
    StartView()
}
