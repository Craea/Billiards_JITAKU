param(
    [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
    [string[]]$ScenePaths
)

$scriptGuids = @{}
Get-ChildItem -Path 'Assets/Scripts' -Recurse -File -Filter '*.cs.meta' | ForEach-Object {
    $match = [regex]::Match([IO.File]::ReadAllText($_.FullName), '(?m)^guid: ([0-9a-f]+)')
    if ($match.Success) {
        $scriptGuids[$match.Groups[1].Value] = $_.BaseName -replace '\.cs$', ''
    }
}

$wanted = @('ShotBall', 'TargetBall', 'TriangleWall', 'InterCellWall', 'FlameTile', 'MagicPotion', 'BurnableEffect', 'Pocket', 'GameManager', 'GameClear', 'StageInfo', 'MagicManager')
$header = [regex]'(?ms)^--- !u!(\d+) &(-?\d+)\r?\n(.*?)(?=^--- !u!|\z)'

foreach ($scenePath in $ScenePaths) {
    $text = [IO.File]::ReadAllText((Resolve-Path $scenePath))
    $names = @{}
    $tags = @{}
    $positions = @{}
    $components = @{}

    foreach ($block in $header.Matches($text)) {
        $kind = [int]$block.Groups[1].Value
        $fileId = $block.Groups[2].Value
        $body = $block.Groups[3].Value
        $goMatch = [regex]::Match($body, 'm_GameObject: \{fileID: (-?\d+)\}')

        if ($kind -eq 1) {
            $nameMatch = [regex]::Match($body, '(?m)^  m_Name: (.*)$')
            $tagMatch = [regex]::Match($body, '(?m)^  m_TagString: (.*)$')
            $names[$fileId] = if ($nameMatch.Success) { $nameMatch.Groups[1].Value } else { '' }
            $tags[$fileId] = if ($tagMatch.Success) { $tagMatch.Groups[1].Value } else { 'Untagged' }
        }
        elseif ($kind -eq 4 -and $goMatch.Success) {
            $posMatch = [regex]::Match($body, 'm_LocalPosition: \{x: ([^,]+), y: ([^,]+), z: ([^}]+)\}')
            if ($posMatch.Success) {
                $positions[$goMatch.Groups[1].Value] = "($($posMatch.Groups[1].Value), $($posMatch.Groups[2].Value), $($posMatch.Groups[3].Value))"
            }
        }
        elseif ($kind -eq 114 -and $goMatch.Success) {
            $guidMatch = [regex]::Match($body, 'm_Script: \{fileID: \d+, guid: ([0-9a-f]+), type: 3\}')
            if ($guidMatch.Success -and $scriptGuids.ContainsKey($guidMatch.Groups[1].Value)) {
                $go = $goMatch.Groups[1].Value
                if (-not $components.ContainsKey($go)) { $components[$go] = [System.Collections.Generic.List[string]]::new() }
                $components[$go].Add($scriptGuids[$guidMatch.Groups[1].Value])
            }
        }
    }

    Write-Output "--- $scenePath ---"
    $components.Keys | ForEach-Object {
        $go = $_
        $relevant = @($components[$go] | Where-Object { $wanted -contains $_ } | Select-Object -Unique)
        if ($relevant.Count -gt 0) {
            [PSCustomObject]@{
                Name = $names[$go]
                Position = $positions[$go]
                Tag = $tags[$go]
                Scripts = $relevant -join ', '
            }
        }
    } | Sort-Object Scripts, Name | Format-Table -AutoSize
}
