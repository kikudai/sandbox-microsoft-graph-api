param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [PSCustomObject]$UserInfo
)

# メール送信設定
$subject = "【重要】仮パスワードのお知らせ"

# メール本文
$body = @"
$($UserInfo.Email) 様

Entra IDの仮パスワードをお送りします。

仮パスワード: $($UserInfo.Password)

ログイン後、必ずパスワードを変更してください。

---
このメールは自動送信です。
"@

# Graph APIでメール送信
try {
    Send-MgUserMail -UserId $UserInfo.Email -BodyParameter @{
        Message = @{
            Subject = $subject
            Body = @{
                ContentType = "Text"
                Content = $body
            }
            ToRecipients = @(
                @{
                    EmailAddress = @{
                        Address = $UserInfo.Email
                    }
                }
            )
        }
        SaveToSentItems = $true
    }
    $status = "Success"
} catch {
    $status = "Failed: $($_.Exception.Message)"
}

# 送信結果を出力
[PSCustomObject]@{
    Email = $UserInfo.Email
    Status = $status
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

# 送信間隔を少し空ける（API制限対策）
Start-Sleep -Seconds 1
