Add-Type -AssemblyName System.Drawing
$a = Join-Path (Get-Location) '.work\assets'
function Shrink($in, $out) {
  $img = [System.Drawing.Image]::FromFile((Join-Path $a $in))
  $bmp = New-Object System.Drawing.Bitmap 1280, 720
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = 'HighQualityBicubic'
  $g.DrawImage($img, 0, 0, 1280, 720)
  $bmp.Save((Join-Path $a $out), [System.Drawing.Imaging.ImageFormat]::Jpeg)
  $g.Dispose(); $bmp.Dispose(); $img.Dispose()
}
Shrink 'floor_169.png' 'floor_small.jpg'
Shrink 'ref_hero_library.png' 'hero_small.jpg'
Shrink 'library_169.jpg' 'library_small.jpg'
Get-ChildItem $a | Select-Object Name,Length
