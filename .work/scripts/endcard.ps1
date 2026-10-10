Add-Type -AssemblyName System.Drawing
$root = Get-Location
$cover = [System.Drawing.Image]::FromFile((Join-Path $root '.work\src\bookcover.png'))
$logo  = [System.Drawing.Image]::FromFile((Join-Path $root '.work\src\logo.png'))
$bmp = New-Object System.Drawing.Bitmap 1920, 1080, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = 'HighQualityBicubic'
$g.SmoothingMode = 'HighQuality'
# cover: scale to height 1080 -> width 2332, crop center
$cw = [int]($cover.Width * 1080 / $cover.Height)
$g.DrawImage($cover, (New-Object System.Drawing.Rectangle (-[int](($cw-1920)/2)), 0, $cw, 1080))
# warm glow behind logo
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddEllipse(160, 120, 1600, 840)
$pb = New-Object System.Drawing.Drawing2D.PathGradientBrush $path
$pb.CenterColor = [System.Drawing.Color]::FromArgb(215, 247, 232, 190)
$pb.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 247, 232, 190))
$g.FillPath($pb, $path)
# vignette
$vp = New-Object System.Drawing.Drawing2D.GraphicsPath
$vp.AddEllipse(-500, -400, 2920, 1880)
$vb = New-Object System.Drawing.Drawing2D.PathGradientBrush $vp
$vb.CenterColor = [System.Drawing.Color]::FromArgb(0, 0, 0, 0)
$vb.SurroundColors = @([System.Drawing.Color]::FromArgb(190, 8, 4, 2))
$vb.FocusScales = New-Object System.Drawing.PointF 0.55, 0.55
$g.FillRectangle($vb, 0, 0, 1920, 1080)
# logo, slightly raised to leave room for tagline
$g.DrawImage($logo, (New-Object System.Drawing.Rectangle 0, -60, 1920, 1080))
$bmp.Save((Join-Path $root '.work\assets\endcard.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose(); $cover.Dispose(); $logo.Dispose()
Get-Item (Join-Path $root '.work\assets\endcard.png') | Select-Object Length
Copy-Item (Join-Path $root '.work\assets\endcard.png') (Join-Path $root '.work\src\endcard.png') -Force
