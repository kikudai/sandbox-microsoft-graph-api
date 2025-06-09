#Requires -Modules Microsoft.Graph.Users

param(
    [Parameter(Mandatory=$true)]
    [string]$UserPrincipalName
)

# ランダムなパスワードを生成する関数
function Generate-RandomPassword {
    $length = 16
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+"
    $random = New-Object System.Random
    $password = ""
    for ($i = 0; $i -lt $length; $i++) {
        $password += $chars[$random.Next(0, $chars.Length)]
    }
    return $password
}

try {
    # Microsoft Graphに接続
    Connect-MgGraph -Scopes "User.ReadWrite.All"

    # ユーザーを検索
    $user = Get-MgUser -Filter "userPrincipalName eq '$UserPrincipalName'"
    
    if ($null -eq $user) {
        Write-Error "ユーザーが見つかりません: $UserPrincipalName"
        exit 1
    }

    # 新しいパスワードを生成
    $newPassword = Generate-RandomPassword

    # パスワードをリセット
    $passwordProfile = @{
        Password = $newPassword
        ForceChangePasswordNextSignIn = $true
    }

    Update-MgUser -UserId $user.Id -PasswordProfile $passwordProfile

    Write-Host "パスワードが正常にリセットされました。"
    Write-Host "新しいパスワード: $newPassword"
    Write-Host "次回のサインイン時にパスワードの変更が必要です。"

} catch {
    Write-Error "エラーが発生しました: $_"
    exit 1
} finally {
    # Microsoft Graphから切断
    Disconnect-MgGraph
} 