//
//  ViewModel.swift
//  Blue_Archive_studentsQize
//
//  Created by Shinya Ikehara on 2026/01/09.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class QuizViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var toastMessage: String?

    @Published var questions: [Student] = []
    @Published var currentIndex: Int = 0
    @Published var revealedHints: Set<HintKey> = []
    @Published var totalScore: Int = 0

    @Published var resultPopup: ResultPopup? = nil
    @Published var revealedAnswerName: String? = nil

    @Published var answerText: String = ""
    @Published var showResult: Bool = false

    private let api = BlueArchiveAPI()

    private let questionCount: Int
    private let fetchLimitForDev: Int?

    private let scoringRule: QuizScoringRule
    private let judgeRule: AnswerJudgeRule

    init(
        questionCount: Int = 5,
        fetchLimitForDev: Int? = nil,
        scoringRule: QuizScoringRule? = nil,
        judgeRule: AnswerJudgeRule? = nil
    ) {
        self.questionCount = questionCount
        self.fetchLimitForDev = fetchLimitForDev
        self.scoringRule = scoringRule ?? .normal
        self.judgeRule = judgeRule ?? .normal
    } // ?? ニル演算子 (左が nilじゃないなら左を使う。 左が nilなら右を使う)

    var currentStudent: Student? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    private var initialHints: [HintKey] {
        HintKey.initialHints
    }

    var extraRevealsCount: Int {
        max(0, revealedHints.subtracting(initialHints).count)
    }
    //subtracting　全体集合に()の値を除いた差集合
    //max 呼び出した値から一番大きな値を取るための関数
    
    func remainingToUnlock(for key: HintKey) -> Int {
        max(0, key.requiredExtraReveals - extraRevealsCount)
    }
    
    func lockedText(for key: HintKey) -> String? {
        guard (!key.isInitiallyRevealed),
              key.requiredExtraReveals > 0,
              !isUnlocked(key: key) else { return nil }

        let remaining = remainingToUnlock(for: key)
        return "あと\(remaining)個ヒントを開けたら解除"
    }

    var currentQuestionScore: Int {
        scoringRule.score(extraRevealsCount: extraRevealsCount)
    }

    func startIfNeeded() async {
        if !questions.isEmpty || isLoading { return }
        await startGame()
    }

    func startGame() async {
        isLoading = true
        errorMessage = nil
        toastMessage = nil
        resultPopup = nil
        revealedAnswerName = nil
        showResult = false
        
        do {
            let all = try await api.fetchStudents(limit: fetchLimitForDev)
            questions = Array(all.shuffled().prefix(questionCount))

            currentIndex = 0
            totalScore = 0
            answerText = ""
            resetForNewQuestion()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "不明なエラー"
        }
    }

    func resetForNewQuestion() {
        revealedHints = Set(initialHints)
        toastMessage = nil
        resultPopup = nil
        revealedAnswerName = nil
    }

    func isUnlocked(key: HintKey) -> Bool {
        extraRevealsCount >= key.requiredExtraReveals
    }

    func reveal(key: HintKey) {

        if key.isInitiallyRevealed {
            revealedHints.insert(key)
            return
        }

        if key.requiredExtraReveals > 0 && !isUnlocked(key: key) {
            toastMessage = "ロック解除に必要な条件を達成していません"
            return
        } // && 左と右の条件がtrueなら動作する

        revealedHints.insert(key)
        toastMessage = nil
    }

    func submitAnswer() {
        guard let student = currentStudent else { return }

        switch judgeRule.judge(input: answerText, correctName: student.name) {
        case .correct:
            totalScore += currentQuestionScore
            resultPopup = .correct
            toastMessage = nil

        case .needVariant(let variant):
            toastMessage = "衣装名（\(variant)）まで入力してください"

        case .wrong:
            toastMessage = "入力と問題の生徒の名前が一致しませんでした"
        }
    }

    func pass() {
        guard let student = currentStudent else { return }
        revealedAnswerName = student.name
        resultPopup = .passed
        toastMessage = nil
    }

    func goNext() {
        answerText = ""
        toastMessage = nil

        resultPopup = nil
        revealedAnswerName = nil

        currentIndex += 1

        if currentIndex >= questions.count {
            print("END -> showResult = true")
            DispatchQueue.main.async{
                self.showResult = true
                // ユーザーランキングの更新などでタイマー、リアルタイム購読などがある場合はasync{ [weak self] in...などにするらしい。
            }
            return
        } else {
            resetForNewQuestion()
        }
    }

    func hintValue(for key: HintKey, student: Student) -> String {
        student.hintValue(for: key)
    }
}
