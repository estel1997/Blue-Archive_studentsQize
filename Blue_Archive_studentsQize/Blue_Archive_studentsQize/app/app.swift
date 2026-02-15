//
//  app.swift
//  Blue_Archive_studentsQize
//
//  Created by Shinya Ikehara on 2026/01/15.
//

import SwiftUI

@main
@MainActor
struct Blue_Archive_studentsQizeApp: App {
    @ObservedObject private var rankingViewModel = RankingViewModel()
    @State private var appState: AppState = .start

    var body: some Scene {
        WindowGroup {
            RootView(appState: $appState)
                .environmentObject(rankingViewModel)
        }
    }
}
