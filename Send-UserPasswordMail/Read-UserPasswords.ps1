#Requires -Modules Microsoft.Graph.Users

param(
    [Parameter(Mandatory=$true)]
    [string]$CsvPath,
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "mail_send_results.csv"
)

try {
    # CSVファイルの存在確認
    if (-not (Test-Path $CsvPath)) {
        Write-Error "CSVファイルが見つかりません: $CsvPath"
        throw "CSVファイルが見つかりません: $CsvPath"
    }

    # CSVファイルを読み込み
    $users = Import-Csv -Path $CsvPath

    # カラム名の存在確認
    if (-not ($users[0].PSObject.Properties.Name -contains "UPN") -or -not ($users[0].PSObject.Properties.Name -contains "NewPassword")) {
        Write-Error "CSVファイルにUPNまたはNewPasswordカラムが存在しません。"
        throw "CSVファイルにUPNまたはNewPasswordカラムが存在しません。"
    }

    # 各ユーザーの情報を出力
    foreach ($user in $users) {
        if ([string]::IsNullOrWhiteSpace($user.UPN) -or [string]::IsNullOrWhiteSpace($user.NewPassword)) {
            Write-Error "空のUPNまたはNewPasswordが検出されました。処理を中止します。"
            throw "空のUPNまたはNewPasswordが検出されました。"
        }
        [PSCustomObject]@{
            Email = $user.UPN
            Password = $user.NewPassword
        }
    }

} catch {
    Write-Error "エラーが発生しました: $_"
    throw $_
}
