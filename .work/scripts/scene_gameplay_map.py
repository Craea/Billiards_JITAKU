from __future__ import annotations
import re
import sys
from pathlib import Path

root = Path.cwd()
script_guids: dict[str, str] = {}
for meta in (root / 'Assets' / 'Scripts').rglob('*.cs.meta'):
    match = re.search(r'^guid: ([0-9a-f]+)', meta.read_text(encoding='utf-8', errors='replace'), re.M)
    if match:
        script_guids[match.group(1)] = meta.stem.removesuffix('.cs')

wanted = {
    'ShotBall', 'TargetBall', 'TriangleWall', 'InterCellWall', 'FlameTile',
    'MagicPotion', 'BurnableEffect', 'Pocket', 'GameManager', 'GameClear',
    'StageInfo', 'MagicManager'
}

header = re.compile(r'^--- !u!(\d+) &(-?\d+)', re.M)

def blocks(text: str):
    found = list(header.finditer(text))
    for i, match in enumerate(found):
        yield int(match.group(1)), match.group(2), text[match.end(): found[i+1].start() if i+1 < len(found) else len(text)]

def parse_scene(path: Path):
    text = path.read_text(encoding='utf-8', errors='replace')
    names: dict[str, str] = {}
    transforms: dict[str, tuple[str, str]] = {}
    components: dict[str, list[str]] = {}
    tags: dict[str, str] = {}
    for kind, file_id, body in blocks(text):
        go = re.search(r'm_GameObject: \{fileID: (-?\d+)\}', body)
        if kind == 1:
            name = re.search(r'^  m_Name: (.*)$', body, re.M)
            tag = re.search(r'^  m_TagString: (.*)$', body, re.M)
            names[file_id] = name.group(1) if name else ''
            tags[file_id] = tag.group(1) if tag else 'Untagged'
        elif kind == 4 and go:
            pos = re.search(r'm_LocalPosition: \{x: ([^,]+), y: ([^,]+), z: ([^}]+)\}', body)
            if pos:
                transforms[go.group(1)] = (file_id, f'({pos.group(1)}, {pos.group(2)}, {pos.group(3)})')
        elif kind == 114 and go:
            guid = re.search(r'm_Script: \{fileID: \d+, guid: ([0-9a-f]+), type: 3\}', body)
            script = script_guids.get(guid.group(1), None) if guid else None
            if script:
                components.setdefault(go.group(1), []).append(script)
    rows = []
    for go, scripts in components.items():
        selected = sorted(set(scripts) & wanted)
        if selected:
            rows.append((names.get(go, '<unnamed>'), transforms.get(go, ('', '<no transform>'))[1], tags.get(go, ''), ', '.join(selected)))
    return sorted(rows)

paths = [Path(p) for p in sys.argv[1:]]
for path in paths:
    print(f'--- {path.as_posix()} ---')
    for name, pos, tag, scripts in parse_scene(path):
        print(f'{name:24} {pos:22} tag={tag:10} [{scripts}]')
