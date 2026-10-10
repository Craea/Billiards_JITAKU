param(
    [Parameter(Mandatory = $true)]
    [string]$ScenePath
)

$guidMap = @{}
Get-ChildItem -Path 'Assets' -Recurse -File -Filter '*.prefab.meta' | ForEach-Object {
    $match = [regex]::Match([IO.File]::ReadAllText($_.FullName), '(?m)^guid: ([0-9a-f]+)')
    if ($match.Success) {
        $guidMap[$match.Groups[1].Value] = $_.FullName.Substring((Get-Location).Path.Length + 1)
    }
}

$text = [IO.File]::ReadAllText((Resolve-Path $ScenePath))
$blocks = [regex]::Matches($text, '(?ms)^--- !u!1001 &(-?\d+)\r?\nPrefabInstance:\r?\n(.*?)(?=^--- !u!|\z)')
$rows = foreach ($block in $blocks) {
    $body = $block.Groups[2].Value
    $source = [regex]::Match($body, 'm_SourcePrefab: \{fileID: \d+, guid: ([0-9a-f]+), type: 3\}')
    if (-not $source.Success) { continue }
    $path = $guidMap[$source.Groups[1].Value]
    if ([string]::IsNullOrEmpty($path)) { continue }

    $name = ''
    $position = @{ x = '-'; y = '-'; z = '-' }
    $mods = [regex]::Matches($body, '(?ms)- target: .*?\r?\n\s*propertyPath: ([^\r\n]+)\r?\n\s*value: ([^\r\n]*)')
    foreach ($mod in $mods) {
        $key = $mod.Groups[1].Value.Trim()
        $value = $mod.Groups[2].Value.Trim()
        if ($key -eq 'm_Name') { $name = $value }
        if ($key -match '^m_LocalPosition\.([xyz])$') { $position[$matches[1]] = $value }
    }

    [PSCustomObject]@{
        Prefab = $path
        Name = $name
        Position = "($($position['x']), $($position['y']), $($position['z']))"
    }
}

$rows | Sort-Object Prefab, Name | Format-Table -AutoSize
