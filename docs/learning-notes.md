# Learning Notes

## 詰まった点

- `URLComponents` と query parameter の組み立て方
- `URLSession` の非同期処理と SwiftUI の状態更新
- JSON の構造と Swift model の対応
- `@Published` の状態が画面へ反映される流れ
- ランキング取得・投稿の責務分離

## 改善した点

- API 通信を View から切り離した
- loading / error / result を ViewModel の状態として管理した
- クイズの進行、スコア、ヒント開放を関数に分けた
- ランキング処理を `RankingAPI` として分離した

## 学んだこと

- SwiftUI では画面そのものより、状態をどう持つかが重要
- API 通信では URL 作成、HTTP status、decode、エラーを分けると説明しやすい
- 外部サービス連携では、公開できる値と公開してはいけない値を分ける必要がある
- ポートフォリオでは、完成度だけでなく「何を考えて作ったか」も伝える必要がある

## 面接で説明できるポイント

- ViewModel に状態を集約した理由
- `@MainActor` を使った理由
- `URLComponents` を使う利点
- Supabase の anon key と service role key の違い
- エラー処理とローディング状態の扱い
