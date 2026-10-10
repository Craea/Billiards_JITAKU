Set-Location "C:\Users\yuta_\unity_project\jitaku_billiards - コピー"
Get-ChildItem Assets\Graphic\Video -Recurse | Select-Object Name,Length | Format-Table -AutoSize
Get-ChildItem Assets\Graphic\Tutorial -Recurse -File | Where-Object Extension -ne '.meta' | Select-Object -First 15 Name
Get-Content Assets\Resources\EndingSettings.asset -Encoding UTF8 | Select-Object -First 50
Get-ChildItem Assets\Scripts -Recurse -Filter *.cs | Select-String -Pattern '[ぁ-んァ-ヶ一-龠]{4,}' -Encoding UTF8 | Select-Object -First 70 | ForEach-Object { $_.Filename + ': ' + $_.Line.Trim() }
