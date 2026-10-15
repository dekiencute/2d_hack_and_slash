#!/usr/bin/env python3
"""Build a gated Godot 4.6.3 Windows candidate; never publish or approve a release.

Default: refuse packaging if selected media rights are unresolved.
--private-qa: create an owner-review-only archive with explicit unresolved-rights notices.
Public export presets keep their quarantine. QA export changes live only in a temporary copy.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
BASE = 'Stylebreaker-PreAlpha-v0.1.0-windows-x86_64'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def audit_assets():
    spec = json.loads((ROOT / 'tools/release_assets.json').read_text())
    entries = []
    blockers = []
    for group in spec['groups']:
        evidence_ok = bool(group['evidence']) and all((ROOT / p).is_file() for p in group['evidence'])
        cleared = group['status'] == 'verified' and evidence_ok
        if not cleared:
            blockers.append(f"{group['id']}: {group['status']} commercial compiled-game permission")
        for name in group['files']:
            path = ROOT / name
            if not path.is_file():
                raise RuntimeError(f'Missing required asset: {name}')
            entries.append({'path': 'res://' + name, 'group': group['id'], 'sha256': sha(path),
                            'bytes': path.stat().st_size, 'license_status': group['status'],
                            'public_cleared': cleared, 'attribution': group['attribution'],
                            'evidence': group['evidence']})
    if len({e['path'] for e in entries}) != len(entries):
        raise RuntimeError('Duplicate release asset inventory paths')
    return {'public_release_approved': False, 'asset_rights_cleared': not blockers,
            'blockers': blockers, 'assets': entries, 'groups': spec['groups']}


def verify_executable(path):
    data = path.read_bytes()
    if data[:2] != b'MZ':
        raise RuntimeError('Windows output is not a PE executable')
    offset = struct.unpack_from('<I', data, 0x3c)[0]
    if data[offset:offset + 4] != b'PE\0\0' or struct.unpack_from('<H', data, offset + 4)[0] != 0x8664:
        raise RuntimeError('Expected Windows x86_64 PE')
    if b'GDPC' not in data[-64:]:
        raise RuntimeError('Missing embedded Godot pack footer')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', default='godot')
    parser.add_argument('--private-qa', action='store_true', help='Owner-only QA; NOT FOR DISTRIBUTION')
    parser.add_argument('--audit-only', action='store_true')
    args = parser.parse_args()
    kind = 'private-qa' if args.private_qa else 'release-candidate'
    build = ROOT / 'builds' / ('rc-' + kind)
    logs = build / 'logs'
    logs.mkdir(parents=True, exist_ok=True)
    report = audit_assets()
    (build / 'ASSET_LICENSE_REPORT.json').write_text(json.dumps(report, indent=2) + '\n')
    if args.audit_only:
        print(json.dumps({'selected_assets': len(report['assets']), 'blockers': report['blockers'],
                          'report': str(build / 'ASSET_LICENSE_REPORT.json')}, indent=2))
        return
    if report['blockers'] and not args.private_qa:
        raise RuntimeError('PUBLIC PACKAGING BLOCKED: ' + '; '.join(report['blockers']) +
                           '. No public ZIP produced. Owner review: --private-qa.')

    # Keep all machine-local Godot writes inside an authorized workspace path.
    env = os.environ.copy()
    for key, folder in [('XDG_DATA_HOME', 'data'), ('XDG_CONFIG_HOME', 'config'), ('XDG_CACHE_HOME', 'cache')]:
        if key not in env:
            env[key] = str(build / folder)
        Path(env[key]).mkdir(parents=True, exist_ok=True)
    commands = []

    def run(label, arguments, cwd=ROOT, checks=False):
        print(f'{label} ...', flush=True)
        result = subprocess.run(arguments, cwd=cwd, env=env, text=True, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, timeout=240)
        (logs / f'{label}.log').write_text(result.stdout)
        commands.append({'label': label, 'command': arguments, 'cwd': str(cwd), 'exit_code': result.returncode})
        (build / 'COMMANDS.json').write_text(json.dumps(commands, indent=2) + '\n')
        if result.returncode or re.search(r'^(?:SCRIPT ERROR:|ERROR:)', result.stdout, re.M):
            raise RuntimeError(f'{label} failed; see {logs / (label + ".log")}')
        if checks and not re.search(r'RESULT: \d+ checks, 0 failures', result.stdout):
            raise RuntimeError(f'{label} did not finish its checks')
        return result.stdout

    version = run('version', [args.godot, '--version']).strip()
    if not version.startswith('4.6.3.stable.'):
        raise RuntimeError('Expected Godot 4.6.3 stable, found ' + version)
    templates = Path(env['XDG_DATA_HOME']) / 'godot/export_templates/4.6.3.stable'
    if not (templates / 'version.txt').is_file() or (templates / 'version.txt').read_text().strip() != '4.6.3.stable':
        raise RuntimeError('Install matching 4.6.3.stable export templates in ' + str(templates))
    for name in ['windows_release_x86_64.exe', 'linux_release.x86_64']:
        if not (templates / name).is_file():
            raise RuntimeError('Missing matching template: ' + name)
    provenance = json.loads((ROOT / 'docs/RC_TEMPLATE_PROVENANCE.json').read_text())
    for name, record in provenance['files'].items():
        if sha(templates / name) != record['sha256']:
            raise RuntimeError('Template does not match the recorded official 4.6.3 file: ' + name)
    run('import', [args.godot, '--headless', '--editor', '--path', str(ROOT), '--import', '--quit'])
    run('source-cleanup-audit', ['python3', str(ROOT / 'tools/check_pixel_only.py')])
    run('pixel-source-regression', [args.godot, '--headless', '--path', str(ROOT), '--script', 'tests/regression.gd'], checks=True)
    for label, script in [('pixel-presentation', 'pixel_art_validation'), ('controller-death', 'release_controls_validation')]:
        run(label, [args.godot, '--headless', '--path', str(ROOT), '--script', 'tests/' + script + '.gd'], checks=True)

    suffix = '-PRIVATE-QA-NOT-FOR-DISTRIBUTION' if args.private_qa else '-RELEASE-CANDIDATE'
    name = BASE + suffix
    output = ROOT / 'dist' / kind
    output.mkdir(parents=True, exist_ok=True)
    archive = output / (name + '.zip')
    checksum = archive.with_suffix('.sha256')
    # Failed reruns must not leave an earlier artifact looking newly verified.
    archive.unlink(missing_ok=True)
    checksum.unlink(missing_ok=True)
    windows = build / 'windows' / 'Stylebreaker.exe'
    linux = build / 'linux' / 'Stylebreaker.x86_64'
    windows.parent.mkdir(exist_ok=True)
    linux.parent.mkdir(exist_ok=True)
    windows.unlink(missing_ok=True)
    linux.unlink(missing_ok=True)
    selected = ['res://pixel_art/arena.tscn'] + [a['path'] for a in report['assets']]
    # Script preload() paths and global classes are not all traversed by selected-scene export.
    selected += ['res://' + str(p.relative_to(ROOT))
                 for folder in ['actors', 'combat', 'systems', 'ui', 'resources', 'pixel_art']
                 for p in (ROOT / folder).rglob('*') if p.suffix in ['.gd', '.tscn', '.tres']]
    selected = sorted(set(selected))
    all_media = ['res://' + str(p.relative_to(ROOT)) for p in (ROOT / 'assets/Art').rglob('*') if p.suffix.lower() in ['.png', '.gif', '.psd', '.aseprite']]
    pack_spec = {'private_qa': args.private_qa, 'expected_assets': [a['path'] for a in report['assets']],
                 'forbidden_assets': sorted(set(all_media) - {a['path'] for a in report['assets']}),
                 'forbidden_paths': []}
    import csv
    with (ROOT / 'docs/CLEANUP_DELETIONS.csv').open() as ledger:
        pack_spec['forbidden_paths'] = ['res://' + row['path'] for row in csv.DictReader(ledger)
                                        if not row['path'].startswith(('/', '.godot/', 'builds/', 'dist/'))]

    pack_spec_path = build / 'PACK_EXPECTATIONS.json'
    pack_spec_path.write_text(json.dumps(pack_spec, indent=2) + '\n')
    with tempfile.TemporaryDirectory(prefix='stylebreaker-rc-') as temp_name:
        temp = Path(temp_name)
        copy = temp / 'project'
        shutil.copytree(ROOT, copy, ignore=shutil.ignore_patterns('.git', '.godot', 'builds', 'dist', '__pycache__', '.test-artifacts'))
        # Selected resources + dependencies, including texture paths loaded dynamically.
        # Never change the committed quarantined public presets to make a QA build.
        cfg = (copy / 'export_presets.cfg').read_text()
        cfg = cfg.replace('export_filter="all_resources"', 'export_filter="resources"\nexport_files=PackedStringArray(' + ', '.join(json.dumps(p) for p in selected) + ')')
        cfg = cfg.replace(',pixel_art/*,assets/Art/*', '')
        if args.private_qa:
            cfg = cfg.replace('custom_features=""', 'custom_features="private_qa"')
        (copy / 'export_presets.cfg').write_text(cfg)
        (build / 'QA_EXPORT_PRESETS.cfg').write_text(cfg)
        run('qa-import', [args.godot, '--headless', '--editor', '--path', str(copy), '--import', '--quit'])
        for preset, label, path in [('Windows Desktop', 'windows-export', windows), ('Linux Validation', 'linux-export', linux)]:
            run(label, [args.godot, '--headless', '--editor', '--path', str(copy), '--export-release', preset, str(path)])
        verify_executable(windows)
        run('linux-startup', [str(linux), '--headless', '--quit-after', '120'], temp)
        stage = temp / name
        stage.mkdir()
        shutil.copy2(windows, stage / 'Stylebreaker.exe')
        for src, dest in [('PLAYER_README.txt', 'README.txt'), ('RC_CREDITS.txt', 'CREDITS.txt'),
                          ('RC_ASSET_LICENSE_REPORT.md', 'ASSET_LICENSE_REPORT.md')]:
            shutil.copy2(ROOT / 'docs' / src, stage / dest)
        shutil.copy2(build / 'ASSET_LICENSE_REPORT.json', stage / 'ASSET_LICENSE_REPORT.json')
        licenses = stage / 'LICENSES'
        licenses.mkdir()
        shutil.copy2(ROOT / 'resources/audio/LICENSE.txt', licenses / 'AUDIO_CC0.txt')
        for file in (ROOT / 'docs/licenses').iterdir():
            if file.is_file():
                shutil.copy2(file, licenses / file.name)
        status = ('PRIVATE OWNER QA — NOT FOR DISTRIBUTION\n' if args.private_qa else 'RELEASE CANDIDATE — NOT APPROVED\n')
        status += ('Stylebreaker — Pre-Alpha v0.1.0 — Windows x86_64\n'
                   'Native Windows execution and physical controller/audio: NOT TESTED.\n'
                   'Linux checks of the embedded Windows pack are not Windows execution.\n'
                   'No itch.io publication or upload was performed.\n')
        status += '\nAsset rights blockers:\n' + '\n'.join(report['blockers']) + '\n'
        (stage / 'BUILD_STATUS.txt').write_text(status)
        revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
        tracked = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode().split('\0')
        sources = {p: sha(ROOT / p) for p in tracked if p and (ROOT / p).is_file()}
        manifest = {'godot': version, 'source_commit': revision,
                    'source_worktree_dirty': bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT).strip()),
                    'private_qa': args.private_qa, 'public_release_approved': False,
                    'windows_native_execution': 'NOT TESTED', 'asset_rights_cleared': report['asset_rights_cleared'],
                    'template_sha256': {p: sha(templates / p) for p in ['version.txt', 'windows_release_x86_64.exe', 'linux_release.x86_64']},
                    'template_source': provenance['source'],
                    'source_sha256': sources,
                    'package_sha256': {str(p.relative_to(stage)): sha(p) for p in sorted(stage.rglob('*')) if p.is_file()}}
        (stage / 'BUILD_MANIFEST.json').write_text(json.dumps(manifest, indent=2) + '\n')
        temporary_zip = build / (name + '.zip.pending')
        try:
            with zipfile.ZipFile(temporary_zip, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as out:
                for path in sorted(stage.rglob('*')):
                    if path.is_file():
                        out.write(path, path.relative_to(stage.parent))
            extracted = temp / 'fresh-extract'
            with zipfile.ZipFile(temporary_zip) as packed:
                if packed.testzip() is not None:
                    raise RuntimeError('ZIP CRC validation failed')
                packed.extractall(extracted)
            bundle = extracted / name
            extracted_exe = bundle / 'Stylebreaker.exe'
            verify_executable(extracted_exe)
            for relative, digest in manifest['package_sha256'].items():
                if sha(bundle / relative) != digest:
                    raise RuntimeError('Extracted file hash mismatch: ' + relative)
            if json.loads((bundle / 'BUILD_MANIFEST.json').read_text()) != manifest:
                raise RuntimeError('Extracted build manifest mismatch')
            if sha(extracted_exe) != sha(windows):
                raise RuntimeError('Extracted executable differs from tested export')
            run('extracted-windows-pack-validation', [args.godot, '--headless', '--main-pack', str(extracted_exe),
                '--script', str(ROOT / 'tests/release_candidate_validation.gd'), '--', str(pack_spec_path), str(build / 'PACK_CONTENTS.json')], extracted, checks=True)
            run('extracted-windows-pack-regression', [args.godot, '--headless', '--main-pack', str(extracted_exe),
                '--script', str(ROOT / 'tests/regression.gd')], extracted, checks=True)
            run('extracted-windows-controller-death', [args.godot, '--headless', '--main-pack', str(extracted_exe),
                '--script', str(ROOT / 'tests/release_controls_validation.gd')], extracted, checks=True)
            run('extracted-pack-cleanup-audit', ['python3', str(ROOT / 'tools/check_pixel_only.py'), '--pack', str(build / 'PACK_CONTENTS.json')])
            run('derived-media-audit', ['python3', str(ROOT / 'tools/audit_rc_pack.py'), '--build', str(build)])
            shutil.move(temporary_zip, archive)
        except BaseException:
            temporary_zip.unlink(missing_ok=True)
            raise
    checksum.write_text(f'{sha(archive)}  {archive.name}\n')
    checksums = {str(p.relative_to(ROOT)): sha(p) for p in [windows, linux, archive]}
    (build / 'SHA256.json').write_text(json.dumps(checksums, indent=2) + '\n')
    print(f'Verified QA/candidate ZIP: {archive}\nSHA-256: {sha(archive)}\nRELEASE STATUS: NOT READY', flush=True)


if __name__ == '__main__':
    main()
