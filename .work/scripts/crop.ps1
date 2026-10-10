Add-Type -AssemblyName System.Drawing
$root = Get-Location
$src = Get-ChildItem (Join-Path $root 'Assets\Graphic') -Filter 'Gemini_Generated*.jpg' | Select-Object -First 1
$img = [System.Drawing.Image]::FromFile($src.FullName)
$w = $img.Width; $h = $img.Height
$newW = [int]($h * 16 / 9)
$x = [int](($w - $newW) / 2)
$bmp = New-Object System.Drawing.Bitmap 1920, 1080
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = 'HighQualityBicubic'
$g.DrawImage($img, (New-Object System.Drawing.Rectangle 0,0,1920,1080), (New-Object System.Drawing.Rectangle $x,0,$newW,$h), 'Pixel')
New-Item -ItemType Directory -Force (Join-Path $root '.work\assets') | Out-Null
$bmp.Save((Join-Path $root '.work\assets\library_169.jpg'), [System.Drawing.Imaging.ImageFormat]::Jpeg)
$g.Dispose(); $bmp.Dispose(); $img.Dispose()
Copy-Item (Join-Path $root 'Assets\Graphic\magic_academy_billiards_floor_background.png') (Join-Path $root '.work\assets\floor_169.png') -Force
Get-ChildItem (Join-Path $root '.work\assets') | Select-Object Name,Length
