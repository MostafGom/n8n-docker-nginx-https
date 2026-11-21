# Checks that your machine is ready. Changes nothing. Run it as often as you like:
#   .\scripts\check-prereqs.ps1
$root = Split-Path -Parent $PSScriptRoot

$hostNames = @('n8n.apps.mylocalhost', 'n8n-queue.apps.mylocalhost')
$script:fail = $false
function Ok($msg)        { Write-Host "  [ OK ]  $msg" -ForegroundColor Green }
function Bad($msg, $fix) { Write-Host "  [FAIL]  $msg" -ForegroundColor Red; Write-Host "          -> $fix"; $script:fail = $true }
function Todo($msg, $fix){ Write-Host "  [TODO]  $msg" -ForegroundColor Yellow; Write-Host "          -> $fix" }
function Has($cmd)       { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

Write-Host 'Tools'
$dockerRunning = $false
if (Has 'docker') {
    Ok "Docker is installed ($(docker --version))"
    docker info *> $null
    if ($LASTEXITCODE -eq 0) { $dockerRunning = $true; Ok 'Docker is running' }
    else { Bad 'Docker is installed but not running' 'Start Docker Desktop from the Start menu and wait until it says it is running' }
    docker compose version *> $null
    if ($LASTEXITCODE -eq 0) { Ok "Docker Compose v2 is available ($(docker compose version --short))" }
    else { Bad "The 'docker compose' command is missing" 'Update Docker Desktop' }
} else {
    Bad 'Docker is not installed' 'Follow docs\01-install-docker-windows.md'
}

if (Has 'mkcert') { Ok 'mkcert is installed' }
else { Bad 'mkcert is not installed' 'Follow docs\01-install-docker-windows.md (then open a new PowerShell window)' }

Write-Host ''
Write-Host 'Setup steps'
$networkExists = $false
if ($dockerRunning) { docker network inspect local-shared *> $null; $networkExists = ($LASTEXITCODE -eq 0) }
if ($networkExists) { Ok "Docker network 'local-shared' exists" }
else { Todo "Docker network 'local-shared' does not exist yet" 'docker network create local-shared' }

if ((Test-Path (Join-Path $root 'nginx\certs\apps.mylocalhost.pem')) -and (Test-Path (Join-Path $root 'nginx\certs\apps.mylocalhost-key.pem'))) {
    Ok 'HTTPS certificate exists in nginx\certs\'
} else {
    Todo 'HTTPS certificate not created yet' '.\nginx\generate-certs.ps1'
}

$hostsFile = Join-Path $env:SystemRoot 'System32\drivers\etc\hosts'
$hostsLines = @(Get-Content $hostsFile -ErrorAction SilentlyContinue)
foreach ($h in $hostNames) {
    $found = $false
    foreach ($line in $hostsLines) {
        $fields = @((($line -replace '#.*$', '').Trim()) -split '\s+')
        if ($fields[0] -eq '127.0.0.1' -and $fields.Count -gt 1 -and ($fields[1..($fields.Count - 1)] -contains $h)) { $found = $true }
    }
    if ($found) { Ok "hosts file has $h" }
    else { Todo "hosts file is missing $h" 'see docs\02-https-and-hosts.md' }
}

foreach ($d in @('n8n', 'n8n-queue')) {
    if (Test-Path (Join-Path $root "$d\.env")) { Ok "$d\.env exists" }
    else { Todo "$d\.env not created yet (only needed for that variant)" ".\$d\generate-env.ps1" }
}

Write-Host ''
Write-Host 'Ports'
foreach ($port in 80, 443) {
    $proxyRunning = $false
    if ($dockerRunning) {
        $proxyRunning = [bool](docker ps --filter 'label=com.docker.compose.project=local-proxy' --filter "publish=$port" -q)
    }
    $client = New-Object System.Net.Sockets.TcpClient
    $inUse = $true
    try { $client.Connect('127.0.0.1', $port) } catch { $inUse = $false } finally { $client.Close() }
    if (-not $inUse) { Ok "Port $port is free" }
    elseif ($proxyRunning) { Ok "Port $port is in use by this project's nginx" }
    else { Bad "Port $port is already used by another program" 'Stop that program first (see docs\troubleshooting.md)' }
}

Write-Host ''
if ($script:fail) { Write-Host 'Fix the [FAIL] items above, then run this check again.'; exit 1 }
Write-Host 'No blockers found. Finish any [TODO] items above, in order.'
exit 0
