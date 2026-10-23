<#
  Adds the SRS background to new Teams' background list for the logged-on user.
  NinjaOne: run as "Current logged on user". Safe to re-run (fixed GUID overwrites).
#>
$ImageUrl = 'https://REPLACE-ME/SRS-Teams-Background.jpg'
$Guid     = '5a1e0c3b-7d2f-4e8a-9b6c-1f0d2e3a4b5c'   # fixed so re-runs replace, not duplicate

$dir = Join-Path $env:LOCALAPPDATA 'Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Backgrounds\Uploads'
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$full  = Join-Path $dir "$Guid.jpg"
$thumb = Join-Path $dir "${Guid}_thumb.jpg"
$tmp   = Join-Path $env:TEMP "srs-teams-bg.jpg"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $ImageUrl -OutFile $tmp -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Output "Download failed: $($_.Exception.Message)"; exit 1
}

Add-Type -AssemblyName System.Drawing
try {
    $img = [System.Drawing.Image]::FromFile($tmp)
} catch {
    Write-Output "Downloaded file is not a valid image"; exit 1
}

# Thumbnail (Teams shows this in the picker)
$bmp = New-Object System.Drawing.Bitmap 280, 158
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = 'HighQualityBicubic'
$g.DrawImage($img, 0, 0, 280, 158)
$g.Dispose()
$bmp.Save($thumb, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$bmp.Dispose()
$img.Dispose()

Copy-Item $tmp $full -Force
Remove-Item $tmp -Force

Write-Output "SRS Teams background installed for $env:USERNAME in $dir"
