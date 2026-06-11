# API Design

## 外部 API 取得

生徒データは API client で取得します。

```text
URLComponents
  -> URLRequest
  -> URLSession
  -> HTTP status check
  -> JSONDecoder
  -> Student models
```

## URLComponents の役割

`URLComponents` は query parameter を安全に組み立てるために使っています。

例:

- limit を query item として付与
- URL の生成失敗時は `badURL` として扱う

## URLSession の役割

`URLSession.shared.data(for:)` を使い、非同期で API から data と response を取得します。

確認していること:

- response が HTTPURLResponse か
- status code が 2xx か
- JSON decode に成功するか

## JSONDecoder の役割

API から返った JSON を Swift の model に変換します。decode に失敗した場合は、アプリ側のエラーとして表示できる形に変換します。

## Supabase Ranking

ランキングでは REST API を利用しています。

主な処理:

- score 順のランキング取得
- name / score の投稿
- date decode
- API エラーの分類

## セキュリティメモ

- service role key はクライアントアプリに置かない
- README / docs に key の実値を書かない
- anon key を使う場合も、RLS と公開範囲を確認する
- 公開 repo に個人情報や private seed data を置かない
