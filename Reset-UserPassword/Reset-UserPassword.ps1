#Requires -Modules Microsoft.Graph.Users

param(
    [Parameter(Mandatory=$true)]
    [string]$UserPrincipalName
)

# ランダムなパスワードを生成する関数
function Generate-RandomPassword {
    param(
        [string]$ExcludeString
    )
    
    $length = 16
    $maxAttempts = 10
    $attempts = 0

    # 文字セットを定義
    $lowercase = "abcdefghijklmnopqrstuvwxyz"
    $uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $numbers = "0123456789"
    $special = "!@#$%^&*()_+-=[]{}|;:,.<>?"
    
    # 各文字セットから最低1文字ずつ使用することを保証
    $password = ""
    $password += $lowercase[(Get-Random -Minimum 0 -Maximum $lowercase.Length)]
    $password += $uppercase[(Get-Random -Minimum 0 -Maximum $uppercase.Length)]
    $password += $numbers[(Get-Random -Minimum 0 -Maximum $numbers.Length)]
    $password += $special[(Get-Random -Minimum 0 -Maximum $special.Length)]
    
    # 残りの文字をランダムに生成
    $allChars = $lowercase + $uppercase + $numbers + $special
    for ($i = $password.Length; $i -lt $length; $i++) {
        $password += $allChars[(Get-Random -Minimum 0 -Maximum $allChars.Length)]
    }
    
    # パスワードをシャッフル
    $passwordArray = $password.ToCharArray()
    $random = New-Object System.Random
    for ($i = $passwordArray.Length - 1; $i -gt 0; $i--) {
        $j = $random.Next(0, $i + 1)
        $temp = $passwordArray[$i]
        $passwordArray[$i] = $passwordArray[$j]
        $passwordArray[$j] = $temp
    }
    $password = -join $passwordArray

    # ユーザー名との重複チェック（大文字小文字を区別しない）
    if ($ExcludeString -and $password -match [regex]::Escape($ExcludeString)) {
        throw "パスワードにユーザー名が含まれています。再試行してください。"
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

    # ユーザー名を除外して新しいパスワードを生成
    $newPassword = Generate-RandomPassword -ExcludeString $UserPrincipalName

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
        ErrorMessage = ""
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

} catch {
    Write-Error "エラーが発生しました: $_"
    # エラー時も結果をオブジェクトとして出力
    [PSCustomObject]@{
        UPN = $UserPrincipalName
        Status = "Error"
        NewPassword = ""
        ErrorMessage = $_.Exception.Message
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    throw $_
} 