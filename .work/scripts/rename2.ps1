$d = Join-Path (Get-Location) '.work\src'
$a = -join [char[]](0x708E,0x5E8A)
$b = -join [char[]](0x708E,0x9B54,0x6CD5)
Rename-Item -LiteralPath (Join-Path $d ($a + '.mp4')) -NewName 'fire_floor.mp4'
Rename-Item -LiteralPath (Join-Path $d ($b + '.mp4')) -NewName 'fire_magic.mp4'
(Get-ChildItem $d).Name -join ', '
