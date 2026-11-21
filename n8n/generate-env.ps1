# Creates .env from .env.example and fills in random secrets.
# Will not overwrite an existing .env (that would lock you out of your saved credentials).
$ErrorActionPreference = 'Stop'

$envPath     = Join-Path $PSScriptRoot '.env'
$examplePath = Join-Path $PSScriptRoot '.env.example'

if (Test-Path $envPath) {
    Write-Host '.env already exists - leaving it untouched.' -ForegroundColor Red
    Write-Host 'Delete it yourself only if you want to start over with empty data.'
    exit 1
}

function New-RandomHex {
    $bytes = New-Object byte[] 32
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($bytes)
    $rng.Dispose()
    return -join ($bytes | ForEach-Object { $_.ToString('x2') })
}

$lines = foreach ($line in [System.IO.File]::ReadAllLines($examplePath)) {
    if ($line -match '^([A-Z0-9_]+)=__GENERATED__$') {
        '{0}={1}' -f $Matches[1], (New-RandomHex)
    } else {
        $line
    }
}

# Docker Compose needs plain UTF-8 (no BOM) with Unix line endings.
$text = ($lines -join "`n") + "`n"
[System.IO.File]::WriteAllText($envPath, $text, (New-Object System.Text.UTF8Encoding $false))

Write-Host "Created $envPath with new random secrets."
Write-Host 'Keep this file safe: N8N_ENCRYPTION_KEY is needed to read your saved credentials.'
