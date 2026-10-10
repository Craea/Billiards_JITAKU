$ErrorActionPreference='Stop'
$dir = Join-Path (Get-Location) '.work\src'
$map = @{
 ([string]::Join('',[char[]](0x30DC,0x30FC,0x30EB,0x64CD,0x4F5C))) = 'ball_control'
 ([string]::Join('',[char[]](0x30DD,0x30B1,0x30C3,0x30C8))) = 'pocket'
 ([string]::Join('',[char[]](0x4E09,0x89D2,0x58C1))) = 'triangle_wall'
 ([string]::Join('',[char[]](0x58C1,0x53CD,0x5C04))) = 'wall_bounce'
 ([string]::Join('',[char[]](0x6728,0x7BB1))) = 'crate'
 ([string]::Join('',[char[]](0x6C34,0x9B54,0x6CD5))) = 'water_magic'
 ([string]::Join('',[char[]](0x7089,0x5E8A))) = 'fire_floor'
 ([string]::Join('',[char[]](0x7089,0x9B54,0x6CD5))) = 'fire_magic'
 ([string]::Join('',[char[]](0x904B,0x52D5,0x91CF))) = 'momentum'
 ([string]::Join('',[char[]](0x9593,0x58C1))) = 'divider_wall'
 ([string]::Join('',[char[]](0x98A8,0x9B54,0x6CD5))) = 'wind_magic'
}
foreach ($k in $map.Keys) {
  $f = Join-Path $dir ($k + '.mp4')
  if (Test-Path -LiteralPath $f) { Rename-Item -LiteralPath $f -NewName ($map[$k] + '.mp4') }
}
Get-ChildItem $dir | Select-Object Name,Length
