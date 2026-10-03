# Xcode 操作ガイド（手作業が必要な部分）

Claude の環境には Xcode がないため、以下の操作はお手元の Mac で行ってください。
手順は Xcode 16 以降（Xcode 26 を含む）を前提にしています。メニュー名が少し違う場合は近いものを選んでください。

---

## Step 0-1. Xcode を入れる（済んでいれば飛ばす）

1. Mac App Store で「Xcode」を検索してインストール（数十分かかります）。
2. 初回起動時に「Install additional components」と出たら「Install」。
3. 「Platforms」の選択画面が出たら **iOS** にチェックして Download。
   （出なかった場合: メニュー **Xcode → Settings… → Components** タブで iOS をダウンロード）

## Step 0-2. Apple ID を Xcode に登録する

1. メニュー **Xcode → Settings…**（⌘,）→ **Accounts** タブ。
2. 左下の **＋** → **Apple ID** → 普段使っている Apple ID でサインイン。
3. 右側の Team 欄に「あなたの名前 (Personal Team)」が出れば OK。
   （有料の Developer Program に入っていればそのチーム名も出ます）

## Step 0-3. プロジェクトを作成する

1. Xcode を起動し、Welcome 画面の **Create New Project…**（既に何か開いていれば **File → New → Project…**）。
2. 上部タブ **iOS** → **App** を選び **Next**。
3. 入力欄:

   | 項目 | 入力値 |
   |---|---|
   | Product Name | `TapStamp` |
   | Team | あなたの名前 (Personal Team) または有料チーム |
   | Organization Identifier | `com.<あなたの名前やドメイン>`（例 `com.loreclinic`）半角英小文字と `.` のみ |
   | Interface | **SwiftUI** |
   | Language | **Swift** |
   | Testing System | **Swift Testing**（計画書の確認事項 E。不要なら None） |
   | Storage | **None**（SwiftData を選ぶとサンプルコードが生成されてしまうため。SwiftData 自体は後で使います） |
   | Host in CloudKit | チェックを外す |

   **Next** を押す。

4. 保存場所のダイアログ:
   - このリポジトリを clone したフォルダ（`tapstamp`）を選ぶ。
   - 下部の **Create Git repository on my Mac** のチェックを **外す**（すでに git 管理下のため）。
   - **Create**。

5. この時点でフォルダは次のようになっています（1 段深くなっているのを次の手順で直します）:

   ```
   tapstamp/
   ├── docs/
   └── TapStamp/
       ├── TapStamp.xcodeproj
       ├── TapStamp/          ← ソース
       └── TapStampTests/     ← Swift Testing を選んだ場合
   ```

## Step 0-4. フォルダ階層を 1 段上げる

1. **Xcode をいったん終了**（⌘Q）。
2. ターミナル（アプリケーション → ユーティリティ → ターミナル）で、clone したフォルダに移動して実行:

   ```bash
   cd /path/to/tapstamp            # ← clone した場所に置き換える
   mv TapStamp TapStamp_tmp
   mv TapStamp_tmp/* .
   rmdir TapStamp_tmp
   ls
   # docs  TapStamp  TapStamp.xcodeproj  TapStampTests  (README.md など)
   ```

3. Finder で `TapStamp.xcodeproj` をダブルクリックして開き直す。
   左のナビゲータで `TapStamp` フォルダが **青いフォルダアイコン**（同期フォルダ）になっていることを確認。
   （黄色のグループアイコンだった場合は教えてください。別の手順を案内します）

## Step 0-5. 対応 OS を iOS 17 にする

1. 左のナビゲータ最上段の青い **TapStamp**（プロジェクト）をクリック。
2. 中央の **TARGETS → TapStamp** を選び、**General** タブ。
3. **Minimum Deployments** の iOS を **17.0** にする。
4. 同じ画面の **Supported Destinations** は iPhone だけ残して構いません（iPad / Mac は右クリック→Delete）。
5. **Deployment Info → Device Orientation** は **Portrait** のみチェック（任意。縦固定の方がレイアウトが楽です）。

## Step 0-6. シミュレータで起動確認

1. ウィンドウ上部中央の実行先（「TapStamp › iPhone 16」のような表示）をクリックし、iPhone 系シミュレータを 1 つ選ぶ。
2. **⌘R**（または ▶ ボタン）。初回はシミュレータ起動に 1〜2 分かかります。
3. 「Hello, world!」が表示されれば成功。

## Step 0-7. コミットして push

ターミナルで:

```bash
cd /path/to/tapstamp
git status                      # TapStamp.xcodeproj と TapStamp/ が未追跡で出る
git add -A
git commit -m "Add Xcode project"
git push -u origin claude/iphone-record-app-swiftui-xa61o8
```

push できたら Claude に「Step 0 完了」と伝えてください。Step 1 を書き始めます。

---

## 以降の毎回の流れ（Step 1〜）

1. Claude が push したら、ターミナルで `git pull`。
2. Xcode は同期フォルダなので、新しいファイルは自動で現れます（出ない場合は Xcode を一度閉じて開き直す）。
3. **⌘B** でビルド。赤いエラーが出たら、左のナビゲータの **⚠️ アイコン（Issue navigator）** を開き、
   エラー行を右クリック → **Copy** して Claude に貼ってください。
4. **⌘R** で動作確認。

---

## 実機（お手持ちの iPhone）で動かす

1. iPhone を USB で Mac につなぐ。iPhone 側で「このコンピュータを信頼しますか？」→ **信頼**。
2. iPhone の **設定 → プライバシーとセキュリティ → デベロッパモード** を ON（再起動を求められます）。
   ※ この項目は Xcode につないだ後に現れます。
3. Xcode の実行先をあなたの iPhone に変える（上部中央の実行先 → 一覧に iPhone 名が出る）。
4. **⌘R**。初回は「Signing」エラーが出ることがあります:
   - プロジェクト → TARGETS → TapStamp → **Signing & Capabilities** タブ。
   - **Automatically manage signing** にチェック、**Team** を選び直す。
   - Bundle Identifier が他人と被っていると失敗するので、末尾に数字を足すなどして一意にする。
5. iPhone 側で「信頼されていないデベロッパ」と出たら:
   **設定 → 一般 → VPNとデバイス管理 → あなたの Apple ID → 信頼**。
6. 無料の Personal Team の場合、アプリは **7 日で起動できなくなります**。再度 ⌘R すれば延長されます。
   （有料の Developer Program なら 1 年）

---

## Capabilities を追加するとき（フェーズ2で使用。今は不要）

1. プロジェクト → TARGETS → TapStamp → **Signing & Capabilities** タブ。
2. 左上の **＋ Capability** をクリック。
3. 一覧から目的のもの（例: **App Groups**）をダブルクリック。
4. 必要な設定（App Groups ならグループ ID `group.<Bundle ID>` を ＋ で追加）。
   具体的な値はその時に Claude が指示します。
