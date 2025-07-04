# 振動テストアプリ

Apple Watchの心拍データと連動する振動アプリの開発における、iPhone振動機能のテスト用アプリです。

## 概要

このアプリは、将来的にApple Watchで取得した心拍データに合わせてiPhoneを振動させる機能の実装に向けた、振動機能のテスト・検証用アプリケーションです。

## 機能

### 1. 単発振動テスト
- 8種類の振動パターンをテスト可能
  - 軽い振動（Light Impact）
  - 中程度の振動（Medium Impact）
  - 強い振動（Heavy Impact）
  - 硬い振動 (Hard Impact)
  - 柔らかい振動 (Soft Impact)
  - 成功通知振動（Success Notification）
  - 警告通知振動（Warning Notification）
  - エラー通知振動（Error Notification）

### 2. 連続振動テスト（心拍シミュレーション）
- BPM（心拍数）を40〜180の範囲で調整可能
- リアルタイムで振動間隔を計算・表示
- 開始/停止ボタンで連続振動を制御
- 設定されたBPMに基づいて一定間隔で振動

### 3. 心拍パターン振動
- 実際の心拍の「ドクン」という2段階の振動を再現
- より自然な心拍感を演出
- 強い振動の後に軽い振動を0.15秒遅らせて実行

## 技術仕様

- **開発言語**: Swift
- **フレームワーク**: SwiftUI
- **対象OS**: iOS 14.0以上
- **必要デバイス**: iPhone（実機テスト必須）

### 使用API
- `UIImpactFeedbackGenerator`: 触覚フィードバック（軽い、中程度、強い, 硬い, 柔らかい）
- `UINotificationFeedbackGenerator`: 通知フィードバック（成功、警告、エラー）
- `Timer`: 定期的な振動実行

## セットアップ

### 前提条件
- Xcode 12.0以上
- iOS 14.0以上の実機（シミュレータでは振動機能は動作しません）
- Apple Developer Account（無料アカウント可）

## 使用方法

### 1. 単発振動のテスト
1. 「振動の強さ」セクションで任意の振動タイプを選択
2. 「振動させる」ボタンをタップ
3. 選択した振動パターンが即座に実行される

### 2. 連続振動のテスト
1. スライダーでBPM（心拍数）を設定（40-180）
2. 「開始」ボタンをタップして連続振動を開始
3. 「停止」ボタンで振動を停止

### 3. 心拍パターンのテスト
1. BPMを設定
2. 「心拍パターン」ボタンをタップ
3. より自然な心拍のような2段階振動が実行される

## 実装の詳細

### 振動間隔の計算
```swift
振動間隔（秒） = 60.0 / BPM
```

### 心拍パターンの実装
```swift
// 1回目の振動（強い）
impactFeedback.impactOccurred()

// 0.15秒後に2回目の振動（軽い）
DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
    lightImpact.impactOccurred()
}
```

## トラブルシューティング

### よくある問題

**Q: 振動が動作しない**
A: 以下を確認してください：
- 実機でテストしているか（シミュレータでは動作しません）
- iPhoneの設定で触覚フィードバックが有効になっているか
  - 設定 > サウンドと触覚 > 触覚フィードバック
- サイレントモードになっていないか

## 参考資料

- [UIImpactFeedbackGenerator](https://developer.apple.com/documentation/uikit/uiimpactfeedbackgenerator)

