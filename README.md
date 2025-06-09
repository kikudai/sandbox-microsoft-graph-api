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

スクリプトを実行する際は、ユーザーのUPN（User Principal Name）を引数として指定します：

```powershell
.\Reset-UserPassword.ps1 -UserPrincipalName "user@example.com"
```

## 機能

- 指定されたユーザーのパスワードをランダムな16文字のパスワードにリセット
- 次回のサインイン時にパスワードの変更を強制
- 新しいパスワードを画面に表示

## 注意事項

- スクリプトを実行するには、適切な権限（User.ReadWrite.All）が必要です
- 初回実行時は、Microsoft Graphへの認証が必要です
- 生成されたパスワードは画面に表示されるため、セキュアな環境で実行してください 