# TapStamp

タップしたら、とりあえず今の日時を記録する iPhone アプリ。
設定不要・アカウントなし・データは端末内のみ。

- iOS 17以上 / SwiftUI / SwiftData / Swift Charts
- 外部ライブラリなし

## 開発の流れ（Mac なし構成）

1. Swift のソースを `TapStamp/` 配下に置く（Xcode プロジェクトは `project.yml` から CI 上で生成）
2. push すると GitHub Actions（`CI`）がシミュレータでビルドとテストを実行
3. Actions タブの `TestFlight` ワークフローを手動実行すると、TestFlight にアップロードされる

Mac で開く場合: `brew install xcodegen && xcodegen generate` で `TapStamp.xcodeproj` が生成されます。

## ドキュメント

- [実装計画](docs/PLAN.md)
- [TestFlight 配布ガイド（Apple / GitHub 側の設定手順）](docs/TESTFLIGHT_GUIDE.md)
- [Xcode 操作ガイド（Mac を使う場合の参考）](docs/XCODE_GUIDE.md)
