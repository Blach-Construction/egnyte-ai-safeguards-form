# Builds the standalone, self-contained HTML form by embedding the Blach fonts
# and logo (as base64) into template.html. Re-run after editing template.html.
#
#   powershell -ExecutionPolicy Bypass -File build.ps1

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$assets = Join-Path $here 'assets'

function B64($path) { [Convert]::ToBase64String([IO.File]::ReadAllBytes($path)) }

# Read as UTF-8 explicitly. Windows PowerShell's Get-Content defaults to the ANSI
# codepage, which would corrupt the emoji / em-dashes / curly quotes in the template.
$html = [IO.File]::ReadAllText((Join-Path $here 'template.html'), (New-Object Text.UTF8Encoding($false)))

$replacements = @{
  '%%FONT_LIGHT%%'  = B64 (Join-Path $assets 'Gotham-Light.woff')
  '%%FONT_BOOK%%'   = B64 (Join-Path $assets 'Gotham-Book.woff')
  '%%FONT_MEDIUM%%' = B64 (Join-Path $assets 'Gotham-Medium.woff')
  '%%FONT_BOLD%%'   = B64 (Join-Path $assets 'Gotham-Bold.woff')
  '%%FONT_BLACK%%'  = B64 (Join-Path $assets 'Gotham-Black.woff')
  '%%LOGO%%'        = B64 (Join-Path $assets 'blach-logo-horizontal-rgb.png')
  '%%LOGO_BUG%%'    = B64 (Join-Path $assets 'blach-logo-bug-blue.png')
}

foreach ($key in $replacements.Keys) {
  $html = $html.Replace($key, $replacements[$key])
}

$enc = New-Object Text.UTF8Encoding($false)

# 1) The standalone file to email around.
$out = Join-Path $here 'Egnyte-AI-Safeguards-Form.html'
[IO.File]::WriteAllText($out, $html, $enc)
$kb = [math]::Round((Get-Item $out).Length / 1KB)
Write-Host "Built $out ($kb KB)"

# 2) index.html at the repo root, so the hosted site serves at the root URL
#    (GitHub Pages "/" source, or drag this folder onto Netlify Drop).
$indexOut = Join-Path $here 'index.html'
[IO.File]::WriteAllText($indexOut, $html, $enc)
Write-Host "Built $indexOut ($kb KB)"
