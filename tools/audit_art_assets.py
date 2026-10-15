#!/usr/bin/env python3
"""Inspect uploaded art and write metadata only. Never creates/edits image assets.
Requires Pillow for decoding PNG/GIF/PSD files. Godot preview has no Python dependency.
"""
from pathlib import Path
import collections
import csv
import hashlib
import json
import re
import struct
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'assets/Art'
OUT = ROOT / 'preview/art_catalog.json'
CHAR_NOTES = {
    'Idle': 'Single pose. Matches existing idle frame count.',
    'Run': '8 frames match existing run layout; preserve gameplay-owned animation timing.',
    'JumpAndFall': 'Two distinct poses: split frame 0 Jump and frame 1 Fall; do not loop as locomotion.',
    'Dash': '6 available frames; current dash uses four atlas cells (indices 1–4). Review selection before retargeting.',
    'GroundCombo1': '8 available frames; existing light_01 uses six cells. Extra poses need deliberate timing/selection.',
    'GroundCombo2': '10 available frames; existing light_02 uses eight cells. Extra poses need deliberate timing/selection.',
    'GroundCombo3': '14 available frames; existing launcher uses 14, light_03 uses 12, air_heavy uses seven selected cells. Review state-specific selection.',
    'AirCombo1': '7 frames fit existing air_light_01 layout; keep hit timings separate from preview FPS.',
    'AirCombo2': '7 frames fit existing air_light_02 layout; keep hit timings separate from preview FPS.',
    'AirCombo3': '9 frames fit existing air_light_03 layout; keep hit timings separate from preview FPS.',
    'Die': '4 poses fit stored die animation; gameplay currently freezes the last pose on death.',
    'TakeHit': 'One reaction pose; no dedicated active hurt animation state currently.',
    'LungingStab': '15 frames. No existing move/animation state is wired to this sheet.',
}


def aseprite_metadata(path):
    data = path.read_bytes()
    size, magic, frames, width, height, depth = struct.unpack_from('<I5H', data)
    if magic != 0xA5E0 or size != len(data):
        raise ValueError(f'Invalid Aseprite header: {path}')
    tags, durations = [], []
    offset = 128
    for frame in range(frames):
        length, magic, old_count, duration = struct.unpack_from('<I3H', data, offset)
        if magic != 0xF1FA or offset + length > len(data):
            raise ValueError(f'Invalid frame {frame}: {path}')
        count = struct.unpack_from('<I', data, offset + 12)[0] or old_count
        position = offset + 16
        durations.append(duration)
        for _ in range(count):
            chunk_length, kind = struct.unpack_from('<IH', data, position)
            if chunk_length < 6 or position + chunk_length > offset + length:
                raise ValueError(f'Invalid chunk in {path}')
            body = data[position + 6:position + chunk_length]
            if kind == 0x2018:
                tag_count = struct.unpack_from('<H', body)[0]
                cursor = 10
                for _ in range(tag_count):
                    start, end, direction, repeat = struct.unpack_from('<HHBH', body, cursor)
                    name_length = struct.unpack_from('<H', body, cursor + 17)[0]
                    name = body[cursor + 19:cursor + 19 + name_length].decode('utf-8')
                    tags.append({'name': name, 'start': start, 'end': end,
                                 'count': end - start + 1, 'direction': direction, 'repeat': repeat})
                    cursor += 19 + name_length
            position += chunk_length
        offset += length
    return {'dimensions': [width, height], 'frames': frames, 'depth': depth,
            'durations_ms': durations, 'tags': tags}


def image_metadata(path):
    with Image.open(path) as image:
        image.load()
        result = {'dimensions': list(image.size), 'mode': image.mode,
                  'has_alpha': 'A' in image.getbands(), 'frames': getattr(image, 'n_frames', 1)}
        if path.suffix == '.png':
            result['alpha_bounds'] = list(image.getbbox()) if image.getbbox() else []
        if path.suffix == '.gif':
            durations = []
            for index in range(image.n_frames):
                image.seek(index)
                image.load()
                durations.append(image.info.get('duration', 0))
            result['durations_ms'] = durations
        return result


def main():
    previous = ROOT / 'docs/REMOVED_ASSETS_2026-10-15.csv'
    hashes = {}
    if previous.exists():
        hashes = {r['sha256']: r['original_path'] for r in csv.DictReader(previous.open())}
    files, entries, failures = [], [], []
    for path in sorted(p for p in ART.rglob('*') if p.is_file()):
        relative = path.relative_to(ROOT).as_posix()
        record = {'path': 'res://' + relative, 'bytes': path.stat().st_size,
                  'sha256': hashlib.sha256(path.read_bytes()).hexdigest(), 'format': path.suffix[1:]}
        if path.suffix in {'.png', '.gif', '.psd'}:
            record.update(image_metadata(path))
        elif path.suffix == '.aseprite':
            record.update(aseprite_metadata(path))
        elif path.suffix == '.import':
            text = path.read_text()
            source = re.search(r'^source_file="([^"]+)"', text, re.M)
            record['source_exists'] = bool(source and (ROOT / source[1].removeprefix('res://')).is_file())
            record['lossless'] = 'compress/mode=0' in text
            record['mipmaps'] = 'mipmaps/generate=true' in text
            if not record['source_exists']:
                failures.append(relative + ': missing import source')
        if record['sha256'] in hashes:
            record['identical_historical_asset'] = hashes[record['sha256']]
        files.append(record)
    pngs = [f for f in files if f['format'] == 'png']
    for item in pngs:
        path = item['path']
        name = Path(path).stem
        width, height = item['dimensions']
        if '/Character/' in path:
            if width % 80 or height != 48:
                failures.append(path + ': unexpected character sheet grid')
                continue
            frames = [[x, 0, 80, 48] for x in range(0, width, 80)]
            note = CHAR_NOTES.get(name, 'Two firing poses; no gun mechanic/state is wired in this prototype.')
            entries.append({'id': 'character/' + name, 'category': 'Character', 'name': name,
                            'path': path, 'dimensions': item['dimensions'], 'frames': frames,
                            'cell': [80, 48], 'fps': 8, 'fps_basis': 'Inspection speed only; no authored timing supplied.',
                            'note': note, 'technical_status': 'Valid 80 × 48 strip; state mapping/timing review required.'})
        elif '/UI/' in path:
            role = 'Packed options/components; crop deliberately before use as a widget.'
            if 'Created-by' in name:
                role = 'Author credit artwork, not a health widget and not a license.'
            elif 'Background' in name:
                role = 'Opaque presentation background, not a transparent UI component.'
            elif 'staminabar' in name:
                role = 'Detached pixels beyond main bar; alpha bounds alone do not isolate a clean component.'
            elif name.endswith('healthbar') or name.endswith('border') or name.endswith('healthbarcomplete'):
                role = 'Component/composite on a padded canvas; use a reviewed AtlasTexture region.'
            bounds = item.get('alpha_bounds', [])
            region = [bounds[0], bounds[1], bounds[2] - bounds[0], bounds[3] - bounds[1]] if bounds else [0, 0, width, height]
            entries.append({'id': 'ui/' + name, 'category': 'UI', 'name': name, 'path': path,
                            'dimensions': item['dimensions'], 'frames': [[0, 0, width, height]],
                            'alpha_region': region, 'cell': [0, 0], 'fps': 1,
                            'fps_basis': 'Static PNG, not an animation.', 'note': role,
                            'technical_status': 'Decodes; padded/packed UI needs selected regions and fill setup.'})
    enemy_path = ART / 'Enemies/Demon_Sword/Sword.png'
    enemy_source = next(f for f in files if f['path'].endswith('/Demon_Sword/Sword.aseprite'))
    with Image.open(enemy_path) as image:
        for row, tag in enumerate(enemy_source['tags']):
            frames = []
            for column in range(image.width // 128):
                region = [column * 128, row * 64, 128, 64]
                if image.crop((region[0], region[1], region[0]+128, region[1]+64)).getbbox():
                    frames.append(region)
            mismatch = len(frames) != tag['count']
            entries.append({'id': 'enemy/' + tag['name'], 'category': 'Enemy', 'name': tag['name'],
                            'path': 'res://' + enemy_path.relative_to(ROOT).as_posix(),
                            'dimensions': list(image.size), 'cell': [128, 64], 'frames': frames,
                            'source_tag': tag, 'fps': 10, 'fps_basis': 'Aseprite source uses 100 ms per frame; PNG may be an older export.',
                            'technical_status': 'Source/export count mismatch; re-export/reconcile.' if mismatch else 'Valid occupied PNG row; future enemy pivot/state mapping needed.',
                            'note': f'PNG row {row}: {len(frames)} nonempty cells; source tag {tag["start"]}–{tag["end"]}: {tag["count"]} frames. Empty trailing cells are not previewed.'})
    for item in files:
        if item['format'] in {'aseprite', 'psd', 'gif'}:
            entries.append({'id': 'source/' + item['path'], 'category': 'Source',
                            'name': Path(item['path']).name, 'path': item['path'],
                            'dimensions': item['dimensions'], 'frames': [], 'fps': 1,
                            'fps_basis': 'Source/reference file, not a Godot texture.',
                            'technical_status': 'Metadata inspected; not runtime-previewable as an imported Texture2D.',
                            'note': f'{item["format"].upper()} · {item["frames"]} source/reference frame(s). View in its authoring tool. PNG exports remain available above.'})
    for entry in entries:
        entry['license_status'] = 'No license/redistribution grant supplied. Preview only; verify before integration/distribution.'
        if entry['category'] == 'Character':
            entry['license_status'] += ' SHA-256 matches the historical Dante asset; upload/renaming does not resolve rights.'
        entry['frames_count'] = len(entry['frames'])
    result = {'schema': 1, 'root': 'res://assets/Art/',
              'license_files': [f['path'] for f in files if any(x in Path(f['path']).name.lower() for x in ['license', 'readme', 'copying'])],
              'counts': dict(collections.Counter(f['format'] for f in files)), 'failures': failures,
              'files': files, 'entries': sorted(entries, key=lambda e: (e['category'], e['name']))}
    OUT.write_text(json.dumps(result, indent=2, ensure_ascii=False) + '\n')
    print(f'Inspected {len(files)} files, {len(pngs)} PNG textures, {len(entries)} preview entries; {len(failures)} missing/layout failures.')
    if failures:
        raise SystemExit('\n'.join(failures))


if __name__ == '__main__':
    main()
