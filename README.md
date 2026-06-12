# Blue Archive Students Quiz iOS

SwiftUI で作成した、外部 API から取得した生徒データを使ってヒント表示型のクイズを行う iOS アプリです。

## 制作目的

- SwiftUI で複数画面を持つアプリを作る
- MVVM に近い構成で View と ViewModel の責務を分ける
- `URLSession` / `URLComponents` / `JSONDecoder` を使って外部 API と通信する
- Supabase を使ったランキング取得・投稿を検証する
- ローディング、エラー、リトライ、結果表示を UI に反映する
- README と docs で実装内容を説明できる状態にする

## 対象ユーザー

- Blue Archive のキャラクター情報を使ったクイズで遊びたい人
- ヒントを段階的に開きながら答える形式のクイズを試したい人

## 使用技術

| 区分 | 技術 |
|---|---|
| App | Swift / SwiftUI |
| Architecture | MVVM style |
| State Management | `ObservableObject`, `@Published`, `@MainActor` |
| API | `URLSession`, `URLComponents`, `JSONDecoder` |
| Ranking | Supabase REST API |
| Local Storage | UserDefaults / local repository |
| UI | Navigation, Sheet, Loading, Error, Result views |
| Version Control | Git / GitHub |

## 主な機能

### 実装済み

- Start / Quiz / Result の画面遷移
- 外部 API から生徒データを取得
- ヒントを段階的に開くクイズ UI
- 正解、パス、不正解時の状態管理
- スコア計算
- ローディング状態の表示
- API エラー時のメッセージ表示
- Supabase ランキングの取得・投稿
- ローカルランキング保存の土台

### 検証中・改善予定

- API 失敗時のリトライ導線
- 表記ゆれに強い解答判定
- ランキング送信時の入力制限
- UI の見やすさ改善
- テストコードの追加
- スクリーンショット追加

## 画面構成

```text
RootView
  -> StartView
  -> QuizView
  -> ResultView
  -> RankingSheetView
```

## アーキテクチャ

```text
View
  -> user action
ViewModel
  -> state update / API request
Model / API Client / Repository
  -> External API / Supabase
```

詳しくは [docs/architecture.md](docs/architecture.md) を参照してください。

## API 通信

外部 API から生徒データを取得し、`StudentsResponse` などのモデルへ decode しています。ランキングは Supabase REST API を使い、一覧取得とスコア投稿を分けて実装しています。

API キーや secret の実値は README / docs には記載しません。公開前提の public key を使う場合でも、RLS と公開範囲を確認して運用します。

## 工夫した点

- UI と通信処理を ViewModel / API client に分けた
- `@MainActor` を使い、UI 更新をメインスレッドで扱うようにした
- ローディング、エラー、結果表示を `@Published` な状態として管理した
- `URLComponents` で query parameter を安全に組み立てた
- ランキング取得と投稿を専用 API に分けた

## 苦労した点

- クイズ進行中の状態を破綻させずに画面へ反映すること
- 正誤判定の"緩さ"を扱うときの条件を考えること
- API通信を行うときの処理を理解すること
- 通信失敗時のエラー処理、ローディング処理を考えること

## 学んだこと

- MVVMの責務分けを理解し、エラーが出た際にも、どの担当でエラーが出たのか理解した。
- SwiftUI では View を薄く保ち、状態管理を ViewModel に寄せると見通しが良くなる
- API 通信では URL 作成、リクエスト、レスポンス検証、decode、エラー処理を分けて考える必要がある
- Supabase 連携では anon key と service role key の違い、RLS の重要性を理解する必要がある
- README で構成と学習内容を整理すると、実装の意図を説明しやすくなる

## 起動方法

1. Xcode で `Blue_Archive_studentsQize.xcodeproj` を開く
2. 実行ターゲットを選択する
3. Run でビルド・起動する

## 注意事項

このリポジトリは学習・ポートフォリオ目的の非公式ファン制作物です。画像・音声・ゲーム素材など、権利物の追加は行いません。
