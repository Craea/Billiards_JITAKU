Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) '.work\src\logo.png'))
"{0} {1}" -f $img.PixelFormat, $img.Size
foreach ($p in @(@(5,5),@(960,100),@(100,1000),@(960,540))) { $c=$img.GetPixel($p[0],$p[1]); "{0},{1}: A={2} R={3} G={4} B={5}" -f $p[0],$p[1],$c.A,$c.R,$c.G,$c.B }
$img.Dispose()
