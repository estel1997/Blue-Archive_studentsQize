//
//  View_Quiz.swift
//  Blue_Archive_studentsQize
//
//  Created by Shinya Ikehara on 2026/01/09.
//

import SwiftUI

struct QuizView: View {

    @StateObject private var vm = QuizViewModel(questionCount: 5, fetchLimitForDev: nil)
    @Environment(\.dismiss) private var dismiss
    @State private var resultScore: Int? = nil

    var body: some View {
        Group {
            if vm.isLoading {
                LoadingView()
            } else if let msg = vm.errorMessage {
                ErrorView(message: msg) {
                    Task { await vm.startGame() }}
            } else if let student = vm.currentStudent {
                QuizContentView(student: student, vm: vm)
            } else {
                LoadingView()
            }
        }
        .navigationTitle("生徒当てクイズ")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.startIfNeeded()
        }
        .onChange(of: vm.showResult) {
            if vm.showResult {
                resultScore = vm.totalScore
            }
        }
        
        .navigationDestination(item: $resultScore) { score in
            ResultView(
                score: score,
                onRetry: {
                    resultScore = nil
                    Task { await vm.startGame()
                    }
                },
                onExit: {
                    resultScore = nil
                    DispatchQueue.main.async{
                        dismiss()
                    }
                }
            )
        }
    }
}

private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("データ取得中…")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

private struct ErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("読み込みに失敗しました")
                .font(.headline)
                .foregroundColor(.red)
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("再試行", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct QuizContentView: View {
    let student: Student
    @ObservedObject var vm: QuizViewModel

    var body: some View {
        ZStack {
            Color(.systemTeal).opacity(0.06)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                header
                
                VStack(spacing: 8) {
                    RowHeader3(left: "クラス", mid: "タイプ", right: "遮蔽物")
                    RowCells3(
                        left:VStack(spacing: 8) {
                            hintSlot(.roleClass)
                            hintSlot(.weaponType)
                        },
                        mid: VStack(spacing: 8) {
                            hintSlot(.attackType)
                            hintSlot(.defenseType)
                        },
                        right: hintSlot(.weaponCover)
                    )
                }
                
                VStack(spacing: 8) {
                    RowHeader3(left: "市街地", mid: "屋外", right: "屋内")
                    RowCells3(
                        left: hintSlot(.city),
                        mid: hintSlot(.outdoor),
                        right: hintSlot(.indoor)
                    )
                }
                
                HStack(spacing: 12) {
                    hintSlot(.position)
                    hintSlot(.rarity)
                }
                
                HStack(spacing: 12) {
                    hintSlot(.roleType)
                    hintSlot(.school)
                }
                
                answerArea
                if let toast = vm.toastMessage {
                    Text(toast)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .foregroundColor(.red)
                }
                Spacer(minLength: 0)
            }
            .padding(20)
            
            .overlay {
                if let popup = vm.resultPopup, let student = vm.currentStudent {
                    ResultPopupOverlay(
                        kind: popup,
                        student: student,
                        onNext: {
                            vm.resultPopup = nil
                            vm.revealedAnswerName = nil
                            vm.goNext()
                        }
                    )
                }else{
                    EmptyView()
                }
            }
        }
    }
    private var header: some View {
        HStack {
            Text("Q\(vm.currentIndex + 1) / \(vm.questions.count)")
                .font(.headline)
            Spacer()
            Text("合計: \(vm.totalScore)点")
                .font(.headline)
        }
    }

    private var answerArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("キャラクター名を入力", text: $vm.answerText)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("回答") { vm.submitAnswer() }
                    .buttonStyle(.borderedProminent)

                Button("パス") { vm.pass() }
                    .buttonStyle(.bordered)

                Spacer()

                Text("この問題を正解で \(vm.currentQuestionScore)点")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func hintSlot(_ key: HintKey) -> some View {
        let isRevealed = vm.revealedHints.contains(key)
        let isLocked = (!key.isInitiallyRevealed)
        && (key.requiredExtraReveals > 0)
        && !vm.isUnlocked(key: key)

        return HintSlot(
            title: key.title,
            isRevealed: isRevealed,
            isLocked: isLocked,
            lockedText: vm.lockedText(for: key),
            value: vm.hintValue(for: key, student: student),
            onTap: { vm.reveal(key: key) }
        )
    }
}

private struct HintSlot: View {
    let title: String
    let isRevealed: Bool
    let isLocked: Bool
    let lockedText: String?
    let value: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if isLocked {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.red)
                        Text(lockedText ?? "ロック中")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                } else if isRevealed {
                    Text(value)
                        .font(.headline)
                } else {
                    Text("（ヒントを確認する）")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .frame(minHeight: 64, alignment: .topLeading)
        }
        .buttonStyle(.plain)
    }
}

private struct ResultPopupOverlay: View {
    let kind: ResultPopup
    let student: Student
    let onNext: () -> Void
    
    var titleText: String {
        switch kind {
        case .correct:
            return "正解です！！"
        case .passed:
            return "正解は\(student.name)でした！！"
        }
    }
    
    var body: some View {
            GeometryReader { geo in
                    VStack(spacing:16) {
                        Text(titleText)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.thinMaterial)
                            .frame(width: 300)
                            .frame(height: 380)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "画像をあとからつける")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.secondary)
                                    Text("ここに画像を追加する")
                                        .font(Font.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            )
                        Button(action: onNext) {
                            Text("次の問題へ")
                                .frame(width: 100)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(18)
                    .frame(width: 360)
                    .frame(height: geo.size.height * 0.8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(RoundedRectangle(cornerRadius: 24)
                        .stroke(.quaternary))
                    .padding(.horizontal,20)
                }
            }
        }

private struct RowHeader3: View {
    let left: String
    let mid: String
    let right: String

    var body: some View {
        HStack(spacing: 0) {
            headerCell(left)
            headerCell(mid)
            headerCell(right)
        }
    }

    private func headerCell(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.bold())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.thinMaterial)
            .overlay(Rectangle().stroke(.quaternary))
    }
}


private struct RowCells3<L: View, M: View, R: View>: View {
    let left: L
    let mid: M
    let right: R

    var body: some View {
        HStack(spacing: 0) {
            left.frame(maxWidth: .infinity)
                .overlay(Rectangle().stroke(.quaternary))
            mid.frame(maxWidth: .infinity)
                .overlay(Rectangle().stroke(.quaternary))
            right.frame(maxWidth: .infinity)
                .overlay(Rectangle().stroke(.quaternary))
        }
        .background(.ultraThinMaterial)
    }
}

#Preview {
    QuizView()
}
