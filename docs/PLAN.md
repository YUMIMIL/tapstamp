# TapStamp 実装計画（フェーズ1：MVP）

「タップしたら今の日時を記録する」だけのiPhoneアプリ。
設定不要・アカウントなし・データは端末内のみ。

- 対象: iOS 17.0以上
- 技術: SwiftUI / SwiftData / Swift Charts、外部ライブラリなし
- UI言語: 日本語
- 開発の分担: Claudeが Swift ファイルを書いて push → あなたが pull して Xcode でビルド・実機確認。
  Claude の環境には Xcode も Swift コンパイラもないため、コンパイルエラーはあなたから貼ってもらって直します。

---

## 1. 進め方（ステップ）

| Step | 内容 | 誰が | 完了の目安 |
|---|---|---|---|
| 0 | Xcodeプロジェクト作成・pushする（手順: `docs/XCODE_GUIDE.md`） | あなた | `TapStamp.xcodeproj` がリポジトリに入り、シミュレータで空アプリが起動する |
| 1 | データモデル・ModelContainer・集計ロジック（純粋関数）・単体テスト | Claude | ビルドが通り、テストが緑 |
| 2 | 記録画面（丸ボタン、ラベルのページ切替、取り消しトースト） | Claude | タップ→保存→取り消し が動く |
| 3 | ふりかえり画面（頻度／間隔の2モード、棒グラフ、ヒートマップ、一覧の削除・時刻修正） | Claude | 実データで表示が崩れない |
| 4 | ラベル編集（追加・改名・色・並べ替え・削除・表示モード）とテンプレート選択（初回起動） | Claude | 初回起動→テンプレ選択→記録 まで一気通貫 |
| 5 | 仕上げ（Dynamic Type、ダークモード、VoiceOver ラベル、空状態の文言） | Claude | 実機で違和感なし |

Step 1 以降は 1 Step ごとに push し、あなたのビルド結果を待ってから次へ進みます。

---

## 2. ファイル構成

Xcode 16 以降のプロジェクトは「同期フォルダ（synchronized folder）」方式なので、
`TapStamp/` 配下にファイルを置けば Xcode 側で自動的に認識されます（手動で「Add Files」する必要なし）。

```
tapstamp/
├── .gitignore
├── README.md
├── docs/
│   ├── PLAN.md               ← この文書
│   └── XCODE_GUIDE.md        ← Xcode の画面操作手順（随時追記）
├── TapStamp.xcodeproj/       ← Step 0 であなたが作成
├── TapStamp/                 ← アプリ本体（同期フォルダ）
│   ├── TapStampApp.swift             @main。ModelContainer を生成して注入
│   ├── Assets.xcassets/              Xcode が生成（アイコン・AccentColor）
│   │
│   ├── Models/                       ★ SwiftUI 非依存。将来 Widget / App Intents と共有する
│   │   ├── Schema/
│   │   │   ├── TapStampSchemaV1.swift    VersionedSchema（モデル定義の「版」）
│   │   │   └── TapStampMigrationPlan.swift  SchemaMigrationPlan（今は V1 のみ）
│   │   ├── TapLabel.swift            typealias で現行版を指す（下記 3.1）
│   │   ├── TapRecord.swift           同上
│   │   ├── DisplayMode.swift         enum frequency / interval（String rawValue）
│   │   └── LabelColor.swift          プリセット8色（hex と表示名）
│   │
│   ├── Services/                     ★ SwiftUI 非依存
│   │   ├── ModelContainerFactory.swift  保存先 URL を一箇所で決める（将来 App Group へ移行しやすく）
│   │   ├── RecordStore.swift         記録・取り消し・削除・時刻修正（ModelContext 操作を集約）
│   │   ├── LabelStore.swift          ラベルの追加・改名・並べ替え・削除
│   │   ├── Statistics.swift          今日の回数、前回からの経過、日別回数、曜日×時間帯、平均間隔（純粋関数）
│   │   └── TemplateCatalog.swift     初回テンプレートの定義
│   │
│   ├── Features/
│   │   ├── Root/
│   │   │   └── RootTabView.swift         タブ（記録／ふりかえり）＋初回テンプレート表示の制御
│   │   ├── Record/
│   │   │   ├── RecordView.swift          TabView(.page) でラベルをページ切替
│   │   │   ├── RecordPageView.swift      1ページ分（ラベル名・今日◯回・前回◯分前・丸ボタン）
│   │   │   ├── TapButton.swift           直径240ptの丸ボタン、縮むアニメ、触覚
│   │   │   ├── PageDots.swift            ページドット（ラベル色に追従）
│   │   │   └── UndoToast.swift           「◯◯を記録しました 14:32｜取り消す」4秒表示
│   │   ├── Review/
│   │   │   ├── ReviewView.swift          ラベル切替＋モードで分岐
│   │   │   ├── FrequencyReviewView.swift 経過時間・今日の回数・棒グラフ・ヒートマップ・一覧
│   │   │   ├── IntervalReviewView.swift  「前回から◯日」大表示・平均間隔・一覧
│   │   │   ├── DailyCountChart.swift     直近7日の棒グラフ（Swift Charts）
│   │   │   ├── WeekdayHourHeatmap.swift  直近4週間 曜日×24時間（Swift Charts RectangleMark）
│   │   │   ├── RecordListSection.swift   記録一覧（スワイプ削除・タップで時刻修正）
│   │   │   └── RecordEditSheet.swift     DatePicker で時刻修正
│   │   ├── Labels/
│   │   │   ├── LabelListView.swift       一覧・並べ替え・削除（EditButton）
│   │   │   ├── LabelEditView.swift       名前・色・表示モード
│   │   │   └── LabelColorPicker.swift    8色のプリセット選択
│   │   └── Onboarding/
│   │       └── TemplatePickerView.swift  初回のテンプレート選択（スキップ可）
│   │
│   └── Shared/
│       ├── Color+Hex.swift
│       ├── Date+Helpers.swift        startOfDay、同日判定 など
│       ├── RelativeTimeFormatter.swift 「3分前」「2時間前」「昨日」「5日前」
│       └── Haptics.swift             .sensoryFeedback のラッパ
│
└── TapStampTests/                    ← Step 0 で Testing System = Swift Testing を選ぶと生成
    ├── StatisticsTests.swift
    └── RelativeTimeFormatterTests.swift
```

`Models/` と `Services/` は **`import SwiftUI` を書かない** ルールにします。
フェーズ2で Widget Extension や App Intents から同じコードを使うとき、
そのままターゲットに追加（またはローカル Swift Package に切り出し）できるようにするためです。

---

## 3. データモデル（SwiftData）

### 3.1 型名について（確認事項 A）

ご指定は `Label` / `Record` ですが、`Label` は SwiftUI の `Label` ビューと名前が衝突し、
あらゆる View ファイルで `SwiftUI.Label` / `TapStamp.Label` と書き分ける羽目になります。
そのため **`TapLabel` / `TapRecord`** という型名を提案します（画面上の文言は「ラベル」「記録」のまま）。

### 3.2 定義

```swift
enum TapStampSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [TapLabel.self, TapRecord.self] }

    @Model final class TapLabel {
        @Attribute(.unique) var id: UUID
        var name: String
        var colorHex: String          // 例 "#E5484D"
        var sortOrder: Int
        var displayModeRaw: String    // DisplayMode.rawValue（enum 直保存より移行に強い）
        var createdAt: Date
        @Relationship(deleteRule: .nullify, inverse: \TapRecord.label)
        var records: [TapRecord] = []
    }

    @Model final class TapRecord {
        @Attribute(.unique) var id: UUID
        var timestamp: Date
        var label: TapLabel?          // nil = 「とりあえず記録」
        var createdAt: Date           // 記録操作をした時刻（timestamp を後から修正しても残る）
        // フェーズ2以降の追加予定（今回は作らない）:
        //   var note: String?
        //   var intensity: Int?      // 1〜5
        //   var sourceRaw: String?   // app / widget / controlCenter / actionButton
    }
}

typealias TapLabel  = TapStampSchemaV1.TapLabel
typealias TapRecord = TapStampSchemaV1.TapRecord
```

### 3.3 設計上のポイント

- **VersionedSchema を最初から使う**: 後で `note` / `intensity` を足すとき `SchemaV2` を追加し、
  軽量マイグレーション（Optional の追加はデータ移行コード不要）で済みます。
  「とりあえず @Model だけ」で始めると、後から版管理を導入するときに既存ユーザーのストアを壊しやすいので、最初から入れます。
- **`displayMode` は String で保存**: enum を直接保存すると値の追加・改名時に読めなくなるリスクがあるため。
  型安全に使うための computed property `displayMode: DisplayMode` を用意します。
- **`createdAt` を Record にも持たせる**（ご指定にはない追加。確認事項 B）:
  時刻修正しても「いつ押したか」が残り、将来の CSV 書き出しやデバッグに役立ちます。不要なら外します。
- **ラベル削除時の記録の扱い**（確認事項 C → 決定: 選べるようにする）:
  `deleteRule: .nullify` を基本にし、削除時の確認ダイアログで次の 2 つから選べるようにします。
  - 「ラベルだけ削除」: 記録 N 件は「とりあえず記録」に残る（既定）
  - 「記録 N 件も削除」: 赤字の破壊的ボタン。`LabelStore.delete(label:deletingRecords: true)` が先に記録を消してからラベルを消す
  記録が 0 件のラベルは確認なしで削除します。
- **並び順**: `sortOrder` は 0 始まり、並べ替えのたびに全件振り直し（件数が少ないので単純な方法で十分）。
- **保存先**: `ModelContainerFactory` が URL を決めます。フェーズ1はアプリ既定の場所。
  フェーズ2で Widget と共有するために App Group コンテナへ移す際、
  初回起動時にストアファイルをコピーする処理をここに足します。

---

## 4. 画面仕様の具体化

### 4.1 記録画面（RecordView）

- `TabView` + `.tabViewStyle(.page(indexDisplayMode: .never))`。ページドットは自作（ラベル色に追従させるため）。
- ページ構成: 1ページ目「とりあえず記録」（label = nil、色はグレー系）、以降 `sortOrder` 順にラベル。
- 1ページの縦構成:
  1. 上部: ラベル名（title2）、その下に「今日 3回 ・ 前回 12分前」（secondary）。記録がなければ「まだ記録がありません」。
  2. 中央: `TapButton`（直径 240pt、ラベル色、内側に白文字「記録」）。
     - タップ: `RecordStore.record(label:)` → `.sensoryFeedback(.impact(weight: .medium), trigger:)` → `scaleEffect` 0.92 に 0.08秒で縮んで戻る。
  3. 下部: ページドット。
- 記録直後: `UndoToast` を画面下（タブバーの上）に 4 秒表示。「薬 を記録しました 14:32 ｜ 取り消す」。
  - 取り消す: その記録を削除し、トーストを「取り消しました」に差し替えて 1.5 秒で消す。
  - 連打した場合: トーストの内容と 4 秒タイマーを最新の記録でリセット（取り消せるのは常に最新 1 件）。
- 右上: ラベル編集ボタン（`NavigationStack` の toolbar、SF Symbol `tag`）→ `LabelListView` をシート表示。
- 統計表示は `@Query` ではなく、ページ表示時と記録時に `Statistics` を呼んで更新（ページ数×`@Query` を避けるため）。

### 4.2 ふりかえり画面（ReviewView）

- 上部: ラベル切替。
  **確認事項 D**: 標準の `Picker(.segmented)` はラベルが 4〜5 個を超えると文字が潰れます。
  見た目はセグメント風のまま、横スクロールできる自作チップ列を推奨します（ラベル 1〜3 個なら標準セグメントと見分けがつきません）。
  1 つ目は「とりあえず記録」。
- `displayMode == .frequency`:
  1. 大きく「前回から 1時間12分」
  2. 「今日 4回」「今週 23回」
  3. 直近7日の日別回数（`BarMark`、x = 日付「月/日」、今日を強調色）
  4. 直近4週間の 曜日×時間帯 ヒートマップ（`RectangleMark`、7行×24列、回数 0 は薄いグレー、多いほどラベル色を濃く）
  5. 記録一覧（日付ごとにセクション、新しい順、直近 100 件 + 「もっと見る」）
- `displayMode == .interval`:
  1. 大きく「前回から 12日」（1 日未満なら「今日」）
  2. 「平均間隔 14.2日（直近 10 回）」「最短 9日 / 最長 21日」
  3. 記録一覧（各行に「前回から ◯日」を併記）
- 記録一覧の行: スワイプで削除、タップで `RecordEditSheet`（`DatePicker` で日時修正、未来の時刻は不可）。
- 「とりあえず記録」は displayMode を持たないので frequency 扱い。

### 4.3 ラベル編集（LabelListView / LabelEditView）

- 一覧: ドラッグで並べ替え（`.onMove`）、スワイプ削除（確認ダイアログ付き、3.3 参照）、「＋ ラベルを追加」「テンプレートから追加」。
- 編集: 名前（必須、前後空白除去、重複可）、色（8 色プリセット）、表示モード（「回数を見る」／「間隔を見る」のセグメントと短い説明文）。
- プリセット 8 色（案）: 赤・オレンジ・黄・緑・ティール・青・紫・ピンク。hex は実装時に提示します。

### 4.4 初回テンプレート（TemplatePickerView）

- 初回起動時（`UserDefaults` の `hasCompletedOnboarding` が false）にフルスクリーンで表示。複数選択 → 「この内容ではじめる」／「あとで設定する」。
- テンプレート案（名前 / 色 / モード）:
  薬（青 / 回数）、痛み（赤 / 回数）、トイレ（ティール / 回数）、タバコ（グレー寄り紫 / 回数）、
  くしゃみ（黄 / 回数）、水分補給（青 / 回数）、シーツ交換（緑 / 間隔）、歯ブラシ交換（オレンジ / 間隔）。
- 同じ画面を「ラベル編集 → テンプレートから追加」からも開けるようにします。

### 4.5 文言ルール

- 「記録」「ふりかえり」「回数」「間隔」「経過」など中立的な語のみ。
- 「診断」「治療」「症状」「管理」「改善」「健康」など医療・効果を連想させる語は UI に使いません。
  テンプレート名「痛み」「薬」は単なるラベル名として扱い、説明文も付けません。

---

## 5. フェーズ2を見据えた設計上の手当（今回はコードを書かない）

| フェーズ2の機能 | 今回入れておく手当 |
|---|---|
| ロック画面・ホーム画面ウィジェット | `Models/` `Services/` を SwiftUI 非依存に保つ。`ModelContainerFactory` で保存先を一元化（App Group へ移行可能に） |
| コントロールセンターのボタン / アクションボタン（App Intents） | 記録処理を `RecordStore.record(labelID:at:)` という View 非依存の関数にする。Intent からはこれを呼ぶだけ |
| CSV 書き出し | `TapRecord` に必要な列（id, timestamp, createdAt, label名）が全部ある。`CSVExporter` を Services に足し、`ShareLink` で出すだけ |
| メモ・強さ(1〜5) | `SchemaV2` を追加して Optional 列を足す。長押しジェスチャは `TapButton` に `onLongPressGesture` を追加 |

---

## 6. 決定事項（2026-10-04 確認済み）

- **A. 型名**: `TapLabel` / `TapRecord`（UI 文言は「ラベル」「記録」）。
- **B. `TapRecord.createdAt`**: 追加する。
- **C. ラベル削除時**: 「ラベルだけ削除（記録は残す）」「記録も削除」をダイアログで選べるようにする。
- **D. ふりかえりのラベル切替**: 横スクロールできる自作チップ列。
- **E. テスト**: Swift Testing を使い、集計ロジックに単体テストを付ける。
- **F. Apple Developer Program**: 加入済み。App Groups / TestFlight / App Store 配布が使える。

---

## 7. ビルド・リリース環境の選択肢（Xcode は必須か）

結論: **ネイティブ iOS アプリをコンパイル・署名するには、どこかに macOS + Xcode が必要**です。
ただし「あなたの手元の Mac で Xcode の画面を操作する」以外の方法もあります。

| 方式 | Mac | Xcode の画面操作 | 開発中の確認 | リリース |
|---|---|---|---|---|
| ① Xcode（計画どおり） | 必要 | プロジェクト作成と ⌘R のみ | シミュレータ／USB 実機、即時 | Xcode の Archive → App Store Connect |
| ② Mac + ターミナルのみ | 必要 | ほぼなし（Xcode はインストールだけ） | `xcodebuild` でシミュレータ／実機、即時 | `xcodebuild -exportArchive` または fastlane |
| ③ Mac なし：GitHub Actions の macOS ランナー | 不要 | なし | push → CI ビルド（5〜10 分）→ TestFlight で iPhone にインストール | 同じ CI から App Store Connect へアップロード |
| ④ Expo / Flutter などに乗り換え | 不要 | なし | クラウドビルド | クラウドビルド |

- ①②③ はどれも Claude 側の作業（Swift を書いて push）は同じです。
- ③ では Claude が CI ログを自分で読めるので、コンパイルエラーを貼ってもらう手間が減ります。
  一方、動作確認のたびに CI 待ち＋TestFlight インストールが挟まり、1 回のサイクルが 10〜15 分になります。
  証明書・プロビジョニングプロファイルの準備（Apple Developer サイトでの Web 操作）も最初に必要です。
- ④ は本当に Xcode 不要ですが、SwiftUI / SwiftData / Swift Charts の指定と相反し、
  フェーズ2のウィジェット・コントロールセンター・アクションボタンがほぼ実現できなくなるため推奨しません。
- **Mac をお持ちなら ① を推奨**し、追加で ③ の CI ビルド（ビルド＋テストだけ）を Claude が用意すると、
  手元の確認は即時、コンパイル確認は Claude が自分で行える、という組み合わせになります。
