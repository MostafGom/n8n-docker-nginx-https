# Creates a locally trusted HTTPS certificate for *.apps.mylocalhost
# and saves it in nginx\certs\. Safe to run again.
$certDir  = Join-Path $PSScriptRoot 'certs'
$certFile = Join-Path $certDir 'apps.mylocalhost.pem'
$keyFile  = Join-Path $certDir 'apps.mylocalhost-key.pem'

if (-not (Get-Command mkcert -ErrorAction SilentlyContinue)) {
    Write-Host 'mkcert is not installed. See docs\01-install-docker-windows.md.' -ForegroundColor Red
    exit 1
}

# Adds mkcert's local certificate authority to Windows.
# Windows shows a security prompt the first time: choose Yes.
mkcert -install
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

New-Item -ItemType Directory -Force -Path $certDir | Out-Null
mkcert -cert-file $certFile -key-file $keyFile "*.apps.mylocalhost"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ''
Write-Host 'Done. Certificate saved in nginx\certs\ (this folder is ignored by git).'
