#Requires -Modules Microsoft.Graph.Users

param(
    [Parameter(Mandatory=$true)]
    [string]$CsvPath,
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "password_reset_results.csv"
)

try {
    # CSVファイルの存在確認
    if (-not (Test-Path $CsvPath)) {
        Write-Error "CSVファイルが見つかりません: $CsvPath"
        throw "CSVファイルが見つかりません: $CsvPath"
    }

    # CSVファイルを読み込み
    $users = Import-Csv -Path $CsvPath

    # UPNカラムの存在確認
    if (-not ($users[0].PSObject.Properties.Name -contains "UPN")) {
        Write-Error "CSVファイルにUPNカラムが存在しません。"
        throw "CSVファイルにUPNカラムが存在しません。"
    }

    # 結果を格納する配列
    $results = @()

    # 各ユーザーのUPNを出力
    foreach ($user in $users) {
        if ([string]::IsNullOrWhiteSpace($user.UPN)) {
            Write-Error "空のUPNが検出されました。処理を中止します。"
            throw "空のUPNが検出されました。"
        }
        $user.UPN
    }

} catch {
    Write-Error "エラーが発生しました: $_"
    throw $_
} 