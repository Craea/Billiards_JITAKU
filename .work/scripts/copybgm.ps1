$root = Get-Location
$f = Get-ChildItem (Join-Path $root 'Assets\Sound') -Filter 'MagiArchv*.mp3' | Select-Object -First 1
Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $root '.work\src\title_bgm.mp3') -Force
$p = Get-ChildItem (Join-Path $root 'Assets\Sound') -Filter 'play*.mp3' | Select-Object -First 1
Copy-Item -LiteralPath $p.FullName -Destination (Join-Path $root '.work\src\play_bgm.mp3') -Force
Get-ChildItem (Join-Path $root '.work\src') | Select-Object Name,Length
