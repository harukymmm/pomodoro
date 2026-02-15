# Pomodoro

macOS / iOS 対応のポモドーロタイマーアプリ。SwiftUI + SwiftData で構築。外部依存なし。

## 機能

### タイマー

- 作業（25分）→ 小休憩（5分）→ 作業 → ... → 大休憩（15分）のサイクルを自動管理
- 延長機能: 作業タイマー終了後もそのまま作業を続けられる。終了時に延長分を記録に含めるか選択可能
- セッションごとにタイトルを設定可能
- 一時停止 / 再開 / スキップ対応

### 集中モード（macOS のみ）

- 作業フェーズ中に指定したアプリを自動終了してブロック
- `/Applications` からインストール済みアプリを選択してブロックリストを管理
- ブロック時に通知で「集中時間中です — [アプリ名] を終了しました」と表示

### 統計

- 今日 / 今週の作業時間の合計
- 完了セッション数
- 直近7日間の日別作業時間チャート

### 設定

- 作業・小休憩・大休憩の時間（1〜60分）
- 大休憩までのセット数（1〜8、デフォルト 4）
- 1日の目標セット数（1〜20、デフォルト 8）
- 休憩 / 作業の自動開始
- タイマーフォントの選択（8種類）

### プラットフォーム別

| | macOS | iOS |
|---|---|---|
| メニューバー常駐 | ○ | - |
| メインウィンドウ | ○ | ○ |
| 集中モード（アプリブロック） | ○ | - |
| 触覚フィードバック | - | ○ |

## 動作要件

- macOS 14.0 以上
- iOS 17.0 以上
- Xcode 15.0 以上

## ビルド

```bash
# macOS
xcodebuild -scheme Pomodoro -project Pomodoro/Pomodoro.xcodeproj -destination 'platform=macOS' build

# iOS（シミュレータ）
xcodebuild -scheme Pomodoro-iOS -project Pomodoro/Pomodoro.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## 技術スタック

- **UI**: SwiftUI
- **データ永続化**: SwiftData（セッション履歴）、UserDefaults（設定）
- **通知**: UserNotifications
- **非同期処理**: Combine
