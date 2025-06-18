# ユーザー仮パスワードメール送信手順

## 概要
Entra IDユーザーの仮パスワードをメールで送信するためのPowerShellスクリプトです。

## 前提条件
- PowerShell 5.1以上
- Microsoft.Graph モジュール
- Entra ID（旧Azure AD）のユーザーアカウント（メール送信権限が必要）

## 必要なファイル
1. `Read-UserPasswords.ps1` - CSVからユーザー情報を読み込むスクリプト
2. `Send-UserPasswordMail.ps1` - メール送信スクリプト
3. `password_reset_results.csv` - ユーザー情報（UPNと仮パスワード）が記載されたCSVファイル

## CSVファイルの形式
```csv
"UPN","Status","NewPassword","ErrorMessage","Timestamp"
"user1@example.com","Success","P@ssw0rd123","","2025-06-09 12:37:21"
"user2@example.com","Success","P@ssw0rd456","","2025-06-09 12:37:21"
```

## 実行手順

### 1. モジュールのインストール
```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

### 2. Graph APIにサインイン
```powershell
Connect-MgGraph -Scopes "Mail.Send" -UseDeviceAuthentication
```

### 3. スクリプトの実行
```powershell
.\Read-UserPasswords.ps1 -CsvPath "password_reset_results.csv" | `
    .\Send-UserPasswordMail.ps1 -SenderUserId "admin@example.com" | `
    Export-Csv -Path "mail_send_results.csv" -NoTypeInformation -Encoding UTF8
```

### 4. サインアウト
```powershell
Disconnect-MgGraph
```

## 実行結果
- `mail_send_results.csv` に送信結果が記録されます。
- カラム: `Email`, `Status`, `Timestamp`

## 注意事項
- 大量送信時は、Graph APIのレート制限に注意してください。
- パスワードにカンマ（`,`）が含まれる場合、CSVファイルでダブルクォート（`"`）で囲んでください。
- エラー発生時は、`mail_send_results.csv` の `Status` カラムにエラーメッセージが記録されます。

## トラブルシューティング
- **CSVファイルが見つからない場合**  
  - ファイルパスが正しいか確認してください。

- **カラム名が存在しない場合**  
  - CSVファイルに `UPN` と `NewPassword` カラムが存在するか確認してください。

- **空の値が検出された場合**  
  - CSVファイルに空の `UPN` または `NewPassword` が含まれていないか確認してください。

- **メール送信エラー**  
  - Graph APIの権限（`Mail.Send`）が付与されているか確認してください。
  - ユーザーアカウントが有効か確認してください。

## 関連ファイル
- `Read-UserPasswords.ps1` - CSVからユーザー情報を読み込むスクリプト
- `Send-UserPasswordMail.ps1` - メール送信スクリプト
- `password_reset_results.csv` - ユーザー情報（UPNと仮パスワード）が記載されたCSVファイル
- `mail_send_results.csv` - 送信結果が記録されるCSVファイル