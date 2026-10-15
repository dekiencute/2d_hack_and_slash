#!/usr/bin/env python3
"""Build a Windows candidate, check the extracted pack, and bundle required notices.

Requires Godot 4.6.3 and matching Windows/Linux x86_64 export templates.
This does not validate native Windows execution or publish to itch.io.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import struct
import subprocess
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / 'builds'
LOGS = BUILD / 'logs'
DIST = ROOT / 'dist'
NAME = 'Stylebreaker-PreAlpha-0.1.0-windows-x86_64'


def run(label, arguments, cwd=ROOT):
    print(f'{label} ...', flush=True)
    result = subprocess.run(arguments, cwd=cwd, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, timeout=180)
    (LOGS / f'{label}.log').write_text(result.stdout)
    # Godot can exit zero after script/resource failures: inspect output as well.
    if result.returncode or re.search(r'^(?:SCRIPT ERROR:|ERROR:)', result.stdout, re.M):
        raise RuntimeError(f'{label} failed; see {LOGS / (label + ".log")}')
    if label.endswith('regression') and not re.search(r'RESULT: \d+ checks, 0 failures', result.stdout):
        raise RuntimeError(f'{label} did not finish its checks')
    return result.stdout


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def verify_executable(path):
    data = path.read_bytes()
    if data[:2] != b'MZ':
        raise RuntimeError('Windows output is not a PE executable')
    offset = struct.unpack_from('<I', data, 0x3c)[0]
    if data[offset:offset + 4] != b'PE\0\0' or struct.unpack_from('<H', data, offset + 4)[0] != 0x8664:
        raise RuntimeError('Expected a Windows x86_64 executable')
    if b'GDPC' not in data[-64:]:
        raise RuntimeError('Expected embedded Godot pack footer')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', default='godot')
    args = parser.parse_args()
    LOGS.mkdir(parents=True, exist_ok=True)
    DIST.mkdir(exist_ok=True)
    (BUILD / 'windows').mkdir(exist_ok=True)
    (BUILD / 'validation').mkdir(exist_ok=True)
    version = run('version', [args.godot, '--version']).strip()
    if not version.startswith('4.6.3.stable.'):
        raise RuntimeError(f'This candidate is pinned to Godot 4.6.3 stable; found {version}')
    run('import', [args.godot, '--headless', '--editor', '--path', str(ROOT), '--import'])
    run('source-regression', [args.godot, '--headless', '--path', str(ROOT), '--script', 'tests/regression.gd'])
    for preset, label in [('Windows Desktop', 'windows-export'), ('Linux Validation', 'linux-export')]:
        run(label, [args.godot, '--headless', '--editor', '--path', str(ROOT), '--export-release', preset])
    exe = BUILD / 'windows' / 'Stylebreaker.exe'
    verify_executable(exe)
    with tempfile.TemporaryDirectory(prefix='stylebreaker-release-') as temporary:
        temporary = Path(temporary)
        # An exported engine launches independently from the repository/editor.
        run('linux-startup', [str(BUILD / 'validation' / 'Stylebreaker.x86_64'), '--headless', '--quit-after', '120'], temporary)
        stage = temporary / NAME
        stage.mkdir()
        shutil.copy2(exe, stage / exe.name)
        shutil.copy2(ROOT / 'docs' / 'PLAYER_README.txt', stage / 'README.txt')
        shutil.copy2(ROOT / 'docs' / 'CREDITS.txt', stage / 'CREDITS.txt')
        licenses = stage / 'LICENSES'
        licenses.mkdir()
        shutil.copy2(ROOT / 'resources' / 'original' / 'LICENSE.txt', licenses / 'ORIGINAL_ASSETS_CC0.txt')
        for name in ['GODOT_LICENSE.txt', 'GODOT_COPYRIGHT.txt']:
            shutil.copy2(ROOT / 'docs' / 'licenses' / name, licenses / name)
        (stage / 'BUILD_STATUS.txt').write_text(
            'Windows x86_64 PRE-ALPHA RELEASE CANDIDATE — 15 October 2026\n'
            'This archive is a candidate only. A successful tools/release.py run checks\n'
            'source regression, export, Linux startup, and the exact extracted Windows\n'
            'resource pack under Godot on Linux. It does not execute the Windows PE.\n'
            'RELEASE BLOCKER: Extract and run Stylebreaker.exe on native Windows;\n'
            'verify all five waves, controls, sound, win/loss and retry before Public.\n'
            'Physical controller, GPU compatibility and itch.io download remain unverified.\n')
        revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
        dirty = bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT, text=True).strip())
        source_files = [p for folder in ['actors', 'combat', 'levels', 'systems', 'ui', 'resources']
                        for p in (ROOT / folder).rglob('*') if p.is_file()]
        source_files += [ROOT / 'project.godot', ROOT / 'export_presets.cfg']
        manifest = {'godot': version, 'source_commit': revision, 'source_worktree_dirty': dirty,
                    'windows_native_execution': 'NOT TESTED', 'source_sha256': {
                        str(p.relative_to(ROOT)): sha(p) for p in sorted(source_files)},
                    'package_sha256': {str(p.relative_to(stage)): sha(p) for p in sorted(stage.rglob('*')) if p.is_file()}}
        (stage / 'BUILD_MANIFEST.json').write_text(json.dumps(manifest, indent=2) + '\n')
        archive = DIST / f'{NAME}.zip'
        try:
            with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as out:
                for path in sorted(stage.rglob('*')):
                    if path.is_file():
                        out.write(path, path.relative_to(stage.parent))
            extracted = temporary / 'fresh-extract'
            with zipfile.ZipFile(archive) as source:
                if source.testzip() is not None:
                    raise RuntimeError('ZIP CRC validation failed')
                source.extractall(extracted)
            extracted_exe = extracted / NAME / 'Stylebreaker.exe'
            verify_executable(extracted_exe)
            if sha(extracted_exe) != sha(exe):
                raise RuntimeError('Extracted executable does not match the export')
            # Load the actual embedded Windows data pack, using a Linux Godot engine.
            run('extracted-windows-pack-regression', [args.godot, '--headless', '--main-pack', str(extracted_exe),
                                                    '--script', str(ROOT / 'tests' / 'regression.gd')], extracted)
        except BaseException:
            archive.unlink(missing_ok=True)
            raise
        (DIST / f'{NAME}.sha256').write_text(f'{sha(archive)}  {archive.name}\n')
        print(f'Validated candidate archive: {archive}\nNative Windows execution: NOT TESTED', flush=True)


if __name__ == '__main__':
    main()
