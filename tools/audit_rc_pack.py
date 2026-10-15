#!/usr/bin/env python3
"""Reconcile every imported media file in the actual QA PCK with declared sources."""
import argparse
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build', type=Path, default=ROOT / 'builds/rc-private-qa')
    args = parser.parse_args()
    inventory = json.loads((args.build / 'PACK_CONTENTS.json').read_text(encoding='utf-8'))
    spec = json.loads((args.build / 'PACK_EXPECTATIONS.json').read_text(encoding='utf-8'))
    allowed = set()
    for source in spec['expected_assets']:
        text = (ROOT / (source.removeprefix('res://') + '.import')).read_text(encoding='utf-8')
        # Godot import metadata contains multiline Variants, not standard INI.
        allowed.update(re.findall(r'^path(?:\.[^=]+)?="(res://[^\"]+)"$', text, re.M))
    actual = {e['path'] for e in inventory['files']
              if e['path'].endswith(('.ctex', '.sample', '.oggstr', '.mp3str', '.fontdata'))}
    if not allowed or actual != allowed:
        raise RuntimeError(f'Media mismatch: unexpected={sorted(actual - allowed)}, missing={sorted(allowed - actual)}')
    result = {'all_derived_media_declared': True, 'count': len(actual), 'paths': sorted(actual)}
    (args.build / 'DERIVED_MEDIA_AUDIT.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(f'PASS: all {len(actual)} imported media files match declared asset sources; {len(inventory["files"])} total pack files')


if __name__ == '__main__':
    main()
