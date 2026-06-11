# App Flow

## 画面遷移

```text
StartView
  -> QuizView
  -> ResultView
      -> Retry
      -> Back to Start

RankingSheetView
  -> ranking list
  -> score submit result
```

## StartView

クイズ開始前の入口です。開始操作を受け取り、問題取得と初期状態の準備につなげます。

## QuizView

クイズ本体の画面です。

- 現在の問題を表示
- ヒントを段階的に開く
- 解答を入力する
- 正解、不正解、パスを表示する
- 次の問題へ進む

## ResultView

クイズ終了後の結果画面です。

- 合計スコア表示
- リトライ導線
- ランキング表示・投稿への導線

## RankingSheetView

Supabase からランキングを取得し、スコア投稿も扱います。

## 状態の流れ

```text
startGame()
  -> fetch students
  -> shuffle / select questions
  -> reset state

submitAnswer()
  -> judge answer
  -> update score or show message

goNext()
  -> reset current question state
  -> finish when last question ends
```
