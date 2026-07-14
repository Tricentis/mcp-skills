# Search all test cases — run via Invoke-TcApi.ps1 or dot-source TcApiSession.ps1 first.

$project = Get-TcApiProject
foreach ($tc in Search-TcApi -Start $project -Tql '=>SUBPARTS:TestCase') {
    Write-Output (Format-TcApiObject $tc)
}
