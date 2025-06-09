# Entra ID ユーザーパスワードリセットスクリプト

このスクリプトは、Microsoft Graph PowerShellを使用してEntra IDユーザーのパスワードをリセットするためのものです。

## 前提条件

- PowerShell 7.0以上
- Microsoft.Graph.Users モジュールがインストールされていること

## インストール方法

1. Microsoft.Graph.Users モジュールをインストールします：

```powershell
Install-Module Microsoft.Graph.Users -Scope CurrentUser
```

## 使用方法

### 単一ユーザーのパスワードリセット

1. Microsoft Graphに接続します：

```powershell
Connect-MgGraph -Scopes "User.ReadWrite.All"
```

```powershell
# 接続状態確認
Get-MgContext

# 接続スコープ確認
(Get-MgContext).Scopes
```

2. スクリプトを実行します：

```powershell
.\Reset-UserPassword.ps1 -UserPrincipalName "user@example.com"
```

3. 作業が完了したら、Microsoft Graphから切断します：

```powershell
Disconnect-MgGraph
```

### 複数ユーザーのパスワードリセット（CSVファイル使用）

1. CSVファイルを準備します。以下のような形式でUPNを記載します：

```csv
UPN
user1@example.com
user2@example.com
user3@example.com
```

サンプルファイル `sample_users.csv` が同梱されています。このファイルを参考に、実際のユーザーのUPNを含むCSVファイルを作成してください。

2. Microsoft Graphに接続します（上記の手順1と同様）

3. 以下のコマンドを実行して、CSVファイルからUPNを読み取り、パスワードリセットを実行します：

```powershell
.\Read-UserUPNs.ps1 -CsvPath "users.csv" | ForEach-Object { .\Reset-UserPassword.ps1 -UserPrincipalName $_ }
```

4. 作業が完了したら、Microsoft Graphから切断します

## 機能

- 指定されたユーザーのパスワードをランダムな16文字のパスワードにリセット
- 次回のサインイン時にパスワードの変更を強制
- 新しいパスワードを画面に表示
- CSVファイルからの一括処理に対応
- エラー発生時に処理を即時停止

## 注意事項

- スクリプトを実行するには、適切な権限（User.ReadWrite.All）が必要です
- 接続と切断は手動で行う必要があります
- 生成されたパスワードは画面に表示されるため、セキュアな環境で実行してください
- CSVファイルは必ずUPNカラムを含む必要があります
- 空のUPNが検出された場合、処理は即時停止します
- エラーが発生した場合、残りのUPNの処理は実行されません 