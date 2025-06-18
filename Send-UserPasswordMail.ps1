param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [PSCustomObject]$UserInfo,

    [Parameter(Mandatory = $true)]
    [string]$SenderUserId
)

# メール送信設定
$subject = "【重要】仮パスワードのお知らせ"

# メール本文
$body = @"
$($UserInfo.Email) 様

Microsoft Entra ID（新IdP）の仮パスワードをお送りします。

※重要: この仮パスワードは、メモ帳などにコピーして保存してください。
（仮パスワード変更時、メール閲覧ができない場合があります）

仮パスワード:
$($UserInfo.Password)

---
このメールは自動送信です。
"@

# Graph APIでメール送信
try {
    Send-MgUserMail -UserId $SenderUserId -BodyParameter @{
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
