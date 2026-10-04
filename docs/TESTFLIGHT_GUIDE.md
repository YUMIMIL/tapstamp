# TestFlight 配布ガイド（Mac なし構成）

ビルドは GitHub Actions の macOS ランナーで行い、TestFlight 経由で iPhone にインストールします。
あなたの作業はすべて Web ブラウザと iPhone 上で完結します。

```
あなた: Web で API キー発行・アプリ登録 → GitHub に Secrets 登録
Claude: Swift を書いて push → CI（ビルド＋テスト）が自動で走る
あなた: GitHub の Actions タブで「TestFlight」を Run workflow
      → 10〜30 分後に iPhone の TestFlight アプリに現れる → インストール
```

---

## 1. 一度だけ行う準備

### 1-1. App Store Connect API キーを発行する

1. https://appstoreconnect.apple.com にサインイン。
2. 上部メニュー **ユーザとアクセス** → タブ **統合（Integrations）** → 左の **App Store Connect API** → **チームキー**。
   - 初めての場合「アクセスをリクエスト」ボタンが出るので押して同意する。
3. **＋（キーを生成）** を押し、名前 `GitHub Actions`、アクセス **Admin** を選んで **生成**。
   （クラウド署名で証明書を自動作成するために Admin 権限が必要です）
4. 生成後の一覧で次の 3 つを控える:
   - **Issuer ID**（一覧の上に表示される UUID 形式の文字列）
   - **キー ID**（10 桁程度の英数字）
   - **API キーをダウンロード** → `AuthKey_XXXXXXXXXX.p8` ファイル。**ダウンロードは 1 回しかできません。** 失くしたら再発行。

### 1-2. Team ID を控える

1. https://developer.apple.com/account にサインイン。
2. 下にスクロールして **Membership details** にある **Team ID**（10 桁の英数字）を控える。

### 1-3. Bundle ID を登録する

1. https://developer.apple.com/account/resources/identifiers/list を開く。
2. **＋** → **App IDs** → Continue → **App** → Continue。
3. Description: `TapStamp`、Bundle ID: **Explicit** で `com.loreclinic.tapstamp` を入力。
   - 別の ID にしたい場合は、`project.yml` の `PRODUCT_BUNDLE_IDENTIFIER` と `bundleIdPrefix` も変える必要があるので Claude に伝えてください。
4. Capabilities は今は何もチェックせず **Continue** → **Register**。

### 1-4. App Store Connect にアプリを作る

1. https://appstoreconnect.apple.com → **マイ App** → **＋** → **新規 App**。
2. 入力:
   - プラットフォーム: **iOS**
   - 名前: `TapStamp`（App Store 全体で一意である必要があります。取られていたら `TapStamp - タップで記録` などに変更可。あとで変えられます）
   - プライマリ言語: **日本語**
   - バンドル ID: 1-3 で登録した `com.loreclinic.tapstamp`
   - SKU: `tapstamp`
   - ユーザアクセス: フルアクセス
3. **作成**。

### 1-5. GitHub に Secrets を登録する

1. https://github.com/YUMIMIL/tapstamp/settings/secrets/actions を開く。
2. **New repository secret** で次の 4 つを追加:

   | Name | Value |
   |---|---|
   | `ASC_KEY_ID` | 1-1 のキー ID |
   | `ASC_ISSUER_ID` | 1-1 の Issuer ID |
   | `ASC_PRIVATE_KEY` | `.p8` ファイルをテキストエディタで開いた中身全部（`-----BEGIN PRIVATE KEY-----` から `-----END PRIVATE KEY-----` まで） |
   | `APPLE_TEAM_ID` | 1-2 の Team ID |

### 1-6. iPhone 側の準備

1. App Store から **TestFlight** アプリをインストール。
2. App Store Connect → **マイ App → TapStamp → TestFlight** タブ → 左の **内部テスト** の **＋** → グループ名 `Internal` → 作成。
3. そのグループの **テスター** の **＋** で自分（App Store Connect のユーザ）を追加。
   - 自分が一覧に出ない場合は **ユーザとアクセス** で自分のアカウントの役割に「App Manager」以上があるか確認。

---

## 2. 毎回のビルドと配布

### 2-1. ビルド＋テスト（自動）

Claude が push するたびに **CI** ワークフローが走ります。
https://github.com/YUMIMIL/tapstamp/actions で緑のチェックが付いていれば OK。失敗したら Claude がログを読んで直します。

### 2-2. TestFlight へ送る（手動）

1. https://github.com/YUMIMIL/tapstamp/actions/workflows/testflight.yml を開く。
2. 右の **Run workflow** → ブランチ `claude/iphone-record-app-swiftui-xa61o8` を選んで **Run workflow**。
3. 10〜15 分でワークフローが完了。その後 Apple 側の処理に 10〜30 分かかります。
4. iPhone の TestFlight アプリに「TapStamp」が現れたら **インストール**。
   - 初回だけ、App Store Connect の TestFlight 画面でビルドに「輸出コンプライアンス」の質問が出ることがあります。
     `ITSAppUsesNonExemptEncryption = false` を設定済みなので通常は出ませんが、出た場合は「いいえ」を選択。
5. 2 回目以降は、TestFlight アプリに「アップデート」が出るので押すだけです。

### 2-3. 期限について

- TestFlight のビルドは **90 日間** 有効です。それを過ぎると起動できなくなるので、再度 2-2 を実行してください。
- App Store に公開（審査あり）すれば期限はなくなります。公開はフェーズ1 完成後に別途案内します。

---

## 3. 困ったとき

| 症状 | 見るところ |
|---|---|
| TestFlight ワークフローが `Missing GitHub secrets` で止まる | 1-5 の 4 つが登録されているか |
| `No profiles for 'com.loreclinic.tapstamp' were found` / `No signing certificate` | API キーの権限が Admin か（1-1）。1-3 の Bundle ID が登録済みか |
| `ITMS-90xxx` で始まるエラー | Apple 側の検証エラー。ログを Claude に見せてください（Claude も GitHub から読めます） |
| TestFlight に 1 時間たっても現れない | App Store Connect → TestFlight タブで「処理中」になっていないか。1-6 でテスターに自分が入っているか |
