<#
.SYNOPSIS
    Authenticode-sign consumer .ps1 installers in a mcp-skills product directory.
    Requires SignPath setup action (sets CODE_SIGNING_CERT_PATH + SIGNPATH_* env vars).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$StagingDir
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $StagingDir)) {
    throw "Staging directory not found: $StagingDir"
}

foreach ($required in @(
        "CODE_SIGNING_CERT_PATH",
        "SIGNPATH_PROJECT_SLUG",
        "SIGNPATH_SIGNINGPOLICY_SLUG"
    )) {
    if (-not [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($required))) {
        continue
    }
    throw "Missing env var $required. Run SignPath setup action before this script."
}

if (-not (Test-Path $env:CODE_SIGNING_CERT_PATH)) {
    throw "Certificate not found: $env:CODE_SIGNING_CERT_PATH"
}

$signtool = Get-ChildItem -Path "${env:ProgramFiles(x86)}\Windows Kits" -Recurse -Filter signtool.exe -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match '\\x64\\signtool\.exe$' } |
    Sort-Object FullName -Descending |
    Select-Object -First 1

if (-not $signtool) {
    throw "signtool.exe not found. Run on a Windows runner after SignPath setup."
}

$keyContainer = "$($env:SIGNPATH_PROJECT_SLUG)/$($env:SIGNPATH_SIGNINGPOLICY_SLUG)"
$timestampServers = @(
    "http://timestamp.digicert.com",
    "http://ts.ssl.com",
    "http://timestamp.entrust.net/TSS/RFC3161sha2TS",
    "http://timestamp.globalsign.com/tsa/r6advanced1"
)

$files = @(
    Get-ChildItem -Path $StagingDir -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -eq ".ps1" }
)
$libDir = Join-Path $StagingDir "lib"
if (Test-Path $libDir) {
    $files += @(
        Get-ChildItem -Path $libDir -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -eq ".ps1" }
    )
}

if ($files.Count -eq 0) {
    Write-Host "No .ps1 installer scripts found under $StagingDir"
    exit 0
}

function Invoke-SignFile([string]$FilePath) {
    foreach ($timestampServer in $timestampServers) {
        Write-Host "Signing $FilePath via $timestampServer"
        $global:LASTEXITCODE = 0
        & $signtool.FullName sign `
            /csp SignPathKSP `
            /kc $keyContainer `
            /fd SHA256 `
            /f $env:CODE_SIGNING_CERT_PATH `
            /tr $timestampServer `
            /td sha256 `
            /v $FilePath
        if ($global:LASTEXITCODE -eq 0) {
            $status = (Get-AuthenticodeSignature -FilePath $FilePath).Status
            if ($status -ne "Valid") {
                throw "Signature not valid after signing ${FilePath}: $status"
            }
            return
        }
        Write-Host "signtool failed (exit $global:LASTEXITCODE), trying next timestamp server"
        Start-Sleep -Seconds 1
    }
    throw "signtool failed to sign $FilePath against all timestamp servers"
}

foreach ($file in $files) {
    Invoke-SignFile -FilePath $file.FullName
}

Write-Host "Signed $($files.Count) installer script(s)."

$sumPath = Join-Path $StagingDir "SHA256SUMS"
$hashTargets = @(
    Get-ChildItem -Path $StagingDir -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -in ".ps1", ".bat", ".py" } |
        Sort-Object Name
)
$lines = foreach ($file in $hashTargets) {
    $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    "$hash  $($file.Name)"
}
[System.IO.File]::WriteAllText($sumPath, (($lines -join "`n") + "`n"))
Write-Host "Wrote $sumPath ($($hashTargets.Count) files)."
