//
//  RootView.swift
//  Blue_Archive_studentsQize
//
//  Created by Shinya Ikehara on 2026/02/13.
//
import SwiftUI

struct RootView: View {
    @Binding var appState: AppState

    var body: some View {
        switch appState {
        case .start:
            StartView(
                onStart: { appState = .quiz }
            )

        case .quiz:
            QuizView(
                onFinish: { score in appState = .result(score: score) },
                onExitToTitle: { appState = .start }
            )

        case .result(let score):
            ResultView(
                score: score,
                onRetry: { appState = .quiz },
                onExit: { appState = .start }
            )
        }
    }
}
