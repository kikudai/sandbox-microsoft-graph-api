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
    # ユーザーを検索
    $user = Get-MgUser -Filter "userPrincipalName eq '$UserPrincipalName'"
    
    if ($null -eq $user) {
        Write-Error "ユーザーが見つかりません: $UserPrincipalName"
        throw "ユーザーが見つかりません: $UserPrincipalName"
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

    # 結果をオブジェクトとして出力
    [PSCustomObject]@{
        UPN = $UserPrincipalName
        Status = "Success"
        NewPassword = $newPassword
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

} catch {
    Write-Error "エラーが発生しました: $_"
    # エラー時も結果をオブジェクトとして出力
    [PSCustomObject]@{
        UPN = $UserPrincipalName
        Status = "Error"
        ErrorMessage = $_.Exception.Message
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    throw $_
} 