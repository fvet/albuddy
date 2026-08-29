<#
    Renders the PNG icons from logo.svg with headless Chrome (or Edge).

    Usage:  powershell -ExecutionPolicy Bypass -File icons/build-icons.ps1

    Every size comes from logo.svg, the full "AL." monogram: the Extensions
    view, the marketplace listing and any status-bar use should show the same
    brand. The source is rendered at 512 px first and then scaled down;
    headless Chrome does not always produce a reliable screenshot at very
    small window sizes.

    Segoe UI Semibold is rasterised into the PNG here, so the shipped icon
    does not depend on that font being installed on the reader's machine -
    only on this machine during the build.

    Outputs:
      icons/icon128.png  - referenced by package.json ("icon"); this is what
                           the Marketplace and the Extensions view display.
      icons/icon256.png  - a crisper source kept for future use (READMEs,
                           social cards). Not shipped in the .vsix.
#>

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$candidates = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
)
$browser = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { throw 'No Chrome or Edge found.' }

$iconDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$work = Join-Path $env:TEMP 'albuddy-icons'
if (-not (Test-Path $work)) { New-Item -ItemType Directory -Path $work | Out-Null }

$render = 512

function Render-Svg([string]$svgName) {
    $svg = Get-Content (Join-Path $iconDir $svgName) -Raw
    $html = @"
<!doctype html><meta charset="utf-8">
<style>
  html,body{margin:0;padding:0;background:transparent;overflow:hidden}
  svg{display:block;width:${render}px;height:${render}px}
</style>
$svg
"@
    $htmlFile = Join-Path $work ($svgName + '.html')
    $pngFile = Join-Path $work ($svgName + '.png')
    Set-Content -Path $htmlFile -Value $html -Encoding utf8
    if (Test-Path $pngFile) { Remove-Item $pngFile }

    $url = 'file:///' + ($htmlFile -replace '\\', '/')
    & $browser --headless=new --disable-gpu --no-sandbox --hide-scrollbars `
        --force-device-scale-factor=1 --default-background-color=00000000 `
        --user-data-dir="$work\profile" --virtual-time-budget=4000 `
        --window-size="$render,$render" --screenshot="$pngFile" $url | Out-Null

    if (-not (Test-Path $pngFile)) { throw "Rendering $svgName failed." }
    return $pngFile
}

function Save-Resized([string]$sourcePng, [int]$size, [string]$target) {
    $src = [System.Drawing.Image]::FromFile($sourcePng)
    try {
        $bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $size, $size)))
        $g.Dispose()
        $bmp.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
    } finally {
        $src.Dispose()
    }
}

$bigPng = Render-Svg 'logo.svg'

$targets = @(256, 128)
foreach ($size in $targets) {
    $out = Join-Path $iconDir ("icon{0}.png" -f $size)
    Save-Resized $bigPng $size $out
    Write-Host ("icon{0}.png  ({1} bytes)" -f $size, (Get-Item $out).Length) -ForegroundColor Green
}

Write-Host "`nDone." -ForegroundColor Green
