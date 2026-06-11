# Architecture

## 方針

このアプリは SwiftUI の View と ViewModel を分け、画面表示と状態更新を追いやすくする構成にしています。

```text
View
  -> user action
ViewModel
  -> state update / API request
Repository / API Client
  -> External API / Supabase
```

## View

View は画面表示とユーザー操作を担当します。

- `RootView`
- `View1_title`
- `View2_Quiz`
- `View3_Result`
- `RankingSheetView`

View では、ボタン操作や入力を ViewModel に渡し、表示内容は ViewModel の状態を参照します。

## ViewModel

ViewModel はクイズ進行と UI 状態を管理します。

- `QuizViewModel`
- `RankingViewModel`

主な状態:

- loading
- error message
- current question
- revealed hints
- answer text
- total score
- result popup
- ranking list

## API Client / Repository

外部 API と Supabase への通信は、専用の型に分けています。

- `BlueArchiveAPI`
- `RankingAPI`
- `LocalRankingRepository`

## 学習ポイント

- View と通信処理を直接結びつけない
- `@MainActor` で UI 更新の責務を明確にする
- API エラーを ViewModel で表示用メッセージに変換する
- ランキングなど外部連携を専用クラスに分ける
