#Requires -Modules Microsoft.Graph.Users, Microsoft.Graph.Identity.DirectoryManagement

param(
    [Parameter(Mandatory=$true)]
    [string]$CsvPath
)

# CSVファイルの存在確認
if (-not (Test-Path $CsvPath)) {
    throw "指定されたCSVファイルが見つかりません: $CsvPath"
}

# CSVファイルを読み込む
$users = Import-Csv -Path $CsvPath

# 必須カラムの確認
$requiredColumns = @('DisplayName', 'UserPrincipalName', 'MailNickname')
$missingColumns = $requiredColumns | Where-Object { $users[0].PSObject.Properties.Name -notcontains $_ }
if ($missingColumns) {
    throw "CSVファイルに必須カラムが不足しています: $($missingColumns -join ', ')"
}

# 結果を格納する配列
$results = @()

# 各ユーザーに対して処理を実行
foreach ($user in $users) {
    try {
        Write-Host "`nユーザー '$($user.DisplayName)' の作成を開始します..."
        
        # パラメータの構築
        $params = @{
            DisplayName = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            MailNickname = $user.MailNickname
        }

        # ユーザー作成スクリプトの実行
        $result = & .\Create-FederatedUser.ps1 @params

        # 結果を配列に追加
        $results += $result

        Write-Host "ユーザー '$($user.DisplayName)' の作成が完了しました。"
    }
    catch {
        Write-Error "ユーザー '$($user.DisplayName)' の作成中にエラーが発生しました: $_"
        $results += [PSCustomObject]@{
            DisplayName = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            Id = ""
            SourceAnchor = ""
            InitialPassword = ""
            Status = "Error"
            ErrorMessage = $_.Exception.Message
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
    }
}

# 結果のサマリーを表示
Write-Host "`n処理結果のサマリー:"
$successCount = ($results | Where-Object { $_.Status -eq "Success" }).Count
$errorCount = ($results | Where-Object { $_.Status -eq "Error" }).Count
Write-Host "成功: $successCount 件"
Write-Host "失敗: $errorCount 件"

# 結果をCSVファイルに出力
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outputPath = "UserCreationResults_$timestamp.csv"
$results | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8
Write-Host "`n詳細な結果は以下のファイルに保存されました: $outputPath" 