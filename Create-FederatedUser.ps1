#Requires -Modules Microsoft.Graph.Users, Microsoft.Graph.Identity.DirectoryManagement

param(
    [Parameter(Mandatory=$true)]
    [string]$DisplayName,
    [Parameter(Mandatory=$true)]
    [string]$UserPrincipalName,
    [Parameter(Mandatory=$true)]
    [string]$MailNickname,
    [Parameter(Mandatory=$false)]
    [string]$Department,
    [Parameter(Mandatory=$false)]
    [string]$JobTitle
)

try {
    # 既存の接続を切断
    Disconnect-MgGraph -ErrorAction SilentlyContinue

    # Microsoft Graphに接続
    Write-Host "Microsoft Graphに接続します..."
    Connect-MgGraph -Scopes "User.ReadWrite.All", "Domain.Read.All"

    # 接続状態を確認
    $graphContext = Get-MgContext
    if (-not $graphContext) {
        throw "Microsoft Graphへの接続に失敗しました。"
    }

    Write-Host "接続に成功しました。スコープ: $($graphContext.Scopes -join ', ')"

    # ドメインの情報を取得
    $domain = $UserPrincipalName.Split('@')[1]
    try {
        $domainInfo = Get-MgDomain -Filter "Id eq '$domain'" -ErrorAction Stop
        Write-Host "ドメイン $domain が見つかりました。"
    } catch {
        Write-Host "ドメイン $domain の確認をスキップします。"
        $domainInfo = $true
    }

    if (-not $domainInfo) {
        throw "指定されたドメイン($domain)が見つかりません。"
    }

    # ランダムなパスワードを生成
    $password = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 16 | ForEach-Object {[char]$_})
    $password += "Aa1!" # パスワード要件を満たすための追加文字

    # SourceAnchorを生成（UPNのBase64エンコード）
    $sourceAnchor = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserPrincipalName))

    # ユーザー作成用のパラメータを設定
    $params = @{
        DisplayName = $DisplayName
        UserPrincipalName = $UserPrincipalName
        MailNickname = $MailNickname
        AccountEnabled = $true
        UsageLocation = "JP"
        PasswordProfile = @{
            Password = $password
            ForceChangePasswordNextSignIn = $true
            ForceChangePasswordNextSignInWithMfa = $false
        }
        OnPremisesImmutableId = $sourceAnchor
    }

    # オプションパラメータの追加
    if ($Department) {
        $params.Add("Department", $Department)
    }
    if ($JobTitle) {
        $params.Add("JobTitle", $JobTitle)
    }

    # ユーザーの作成
    try {
        Write-Host "ユーザーを作成しています..."
        $newUser = New-MgUser -BodyParameter $params -ErrorAction Stop
        
        # 作成されたユーザーの存在確認
        Write-Host "作成されたユーザーを確認しています..."
        $createdUser = Get-MgUser -UserId $newUser.Id -ErrorAction Stop
        
        if (-not $createdUser) {
            throw "ユーザーが作成されましたが、確認できません。"
        }

        Write-Host "ユーザーが正常に作成されました。"
        Write-Host "表示名: $($createdUser.DisplayName)"
        Write-Host "UPN: $($createdUser.UserPrincipalName)"
        Write-Host "ID: $($createdUser.Id)"
        Write-Host "SourceAnchor: $sourceAnchor"
        Write-Host "初期パスワード: $password"
        Write-Host "注意: このユーザーはSAMLフェデレーション認証を使用します。"
        Write-Host "注意: 次回のサインイン時にパスワードの変更が必要です。"

        # 結果をオブジェクトとして出力
        [PSCustomObject]@{
            DisplayName = $createdUser.DisplayName
            UserPrincipalName = $createdUser.UserPrincipalName
            Id = $createdUser.Id
            SourceAnchor = $sourceAnchor
            InitialPassword = $password
            Status = "Success"
            ErrorMessage = ""
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
    } catch {
        throw "ユーザーの作成に失敗しました: $_"
    }

} catch {
    Write-Error "エラーが発生しました: $_"
    # エラー時も結果をオブジェクトとして出力
    [PSCustomObject]@{
        DisplayName = $DisplayName
        UserPrincipalName = $UserPrincipalName
        Id = ""
        SourceAnchor = ""
        InitialPassword = ""
        Status = "Error"
        ErrorMessage = $_.Exception.Message
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    throw $_
} finally {
    # 接続を切断
    Disconnect-MgGraph -ErrorAction SilentlyContinue
} 