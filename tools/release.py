#!/usr/bin/env python3
"""Build and technically validate a Godot 4.6.3 Windows ZIP; never publish it.

Incomplete asset-license evidence is reported, not an export failure. Technical
checks remain mandatory. --private-qa retains the owner-only archive/feature label.
"""
import argparse
import csv
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
BASE = 'Stylebreaker-PreAlpha-v0.1.0-windows-x86_64'
TEMPLATE_VERSION = '4.6.3.stable'
RUNTIME_FOLDERS = ['actors', 'combat', 'systems', 'ui', 'resources', 'pixel_art']


def find_godot(explicit=None):
    """Prefer an explicit path, GODOT_BIN, then console-capable PATH installs."""
    requested = explicit or os.environ.get('GODOT_BIN')
    if requested:
        expanded = os.path.expandvars(os.path.expanduser(requested.strip('"')))
        found = shutil.which(expanded)
        if found:
            return str(Path(found).resolve())
        if Path(expanded).is_file():
            return str(Path(expanded).resolve())
        raise RuntimeError('Godot executable not found: ' + requested)
    for name in ['godot_console', 'godot4_console', 'godot', 'godot4']:
        found = shutil.which(name)
        if found:
            return str(Path(found).resolve())
    # Official Windows portable downloads have versioned filenames, not godot.exe.
    folders = [ROOT] + [Path(p) for p in os.get_exec_path() if p]
    if os.name == 'nt':
        for variable, suffix in [('LOCALAPPDATA', 'Programs/Godot'), ('ProgramFiles', 'Godot')]:
            if os.environ.get(variable):
                folders.append(Path(os.environ[variable]) / suffix)
    for folder in folders:
        for pattern in ['Godot_v4.6.3-stable_win64_console.exe', 'Godot_v4.6.3-stable_win64.exe']:
            candidate = folder / pattern
            if candidate.is_file():
                return str(candidate.resolve())
    raise RuntimeError('Install Godot 4.6.3 and add it to PATH, set GODOT_BIN, or pass --godot "C:\\Tools\\Godot\\Godot_v4.6.3-stable_win64_console.exe"')


def find_templates(explicit=None):
    if explicit:
        return Path(os.path.expandvars(explicit)).expanduser().resolve()
    if sys.platform == 'win32':
        base = Path(os.environ.get('APPDATA', Path.home() / 'AppData/Roaming')) / 'Godot'
    elif sys.platform == 'darwin':
        base = Path.home() / 'Library/Application Support/Godot'
    else:
        base = Path(os.environ.get('XDG_DATA_HOME', Path.home() / '.local/share')) / 'godot'
    return base / 'export_templates' / TEMPLATE_VERSION


def required_template_names(platform):
    names = ['version.txt', 'windows_release_x86_64.exe']
    if platform.startswith('linux'):
        names.append('linux_release.x86_64')
    return names


def runtime_resources(report):
    # Godot resource identifiers must use forward slashes on Windows too.
    paths = ['res://pixel_art/arena.tscn'] + [a['path'] for a in report['assets']]
    paths += ['res://' + p.relative_to(ROOT).as_posix()
              for folder in RUNTIME_FOLDERS for p in (ROOT / folder).rglob('*')
              if p.suffix in ['.gd', '.tscn', '.tres']]
    return sorted(set(paths))


def export_configuration(text, selected, templates, private_qa):
    """Configure the isolated export copy, leaving the normal presets intact."""
    text = re.sub(r'(?m)^export_filter=.*$', 'export_filter="resources"', text)
    value = 'export_files=PackedStringArray(' + ', '.join(json.dumps(p) for p in selected) + ')'
    text = re.sub(r'(?m)^export_files=.*$', lambda _: value, text)
    if private_qa:
        text = text.replace('custom_features=""', 'custom_features="private_qa"')
    for index, template in [(0, 'windows_release_x86_64.exe'), (1, 'linux_release.x86_64')]:
        # --templates-dir also works when templates are outside Godot's default dir.
        path = json.dumps((templates / template).as_posix())
        text = re.sub(r'(\[preset\.' + str(index) + r'\.options\][\s\S]*?custom_template/release=)"[^"\n]*"',
                      lambda match: match[1] + path, text, count=1)
    return text


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def audit_assets():
    spec = json.loads((ROOT / 'tools/release_assets.json').read_text(encoding='utf-8'))
    entries = []
    warnings = []
    for group in spec['groups']:
        evidence_ok = bool(group['evidence']) and all((ROOT / p).is_file() for p in group['evidence'])
        cleared = group['status'] == 'verified' and evidence_ok
        if not cleared:
            warnings.append(f"{group['id']}: {group['status']} commercial compiled-game permission")
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
    return {'public_release_approved': False, 'asset_rights_cleared': not warnings,
            'license_verification_blocks_export': False,
            'warnings': warnings, 'assets': entries, 'groups': spec['groups']}


def verify_executable(path):
    data = path.read_bytes()
    if len(data) < 64 or data[:2] != b'MZ':
        raise RuntimeError('Windows output is not a PE executable')
    offset = struct.unpack_from('<I', data, 0x3c)[0]
    if offset + 6 > len(data) or data[offset:offset + 4] != b'PE\0\0' or struct.unpack_from('<H', data, offset + 4)[0] != 0x8664:
        raise RuntimeError('Expected Windows x86_64 PE')
    if b'GDPC' not in data[-64:]:
        raise RuntimeError('Missing embedded Godot pack footer')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', help='Godot executable path (or GODOT_BIN / auto-detect)')
    parser.add_argument('--templates-dir', help='Directory containing matching 4.6.3.stable templates')
    parser.add_argument('--private-qa', action='store_true', help='Owner-only QA; NOT FOR DISTRIBUTION')
    parser.add_argument('--audit-only', action='store_true')
    args = parser.parse_args()
    kind = 'private-qa' if args.private_qa else 'release-candidate'
    build = ROOT / 'builds' / ('rc-' + kind)
    suffix = '-PRIVATE-QA-NOT-FOR-DISTRIBUTION' if args.private_qa else '-RELEASE-CANDIDATE'
    name = BASE + suffix
    output = ROOT / 'dist' / kind
    output.mkdir(parents=True, exist_ok=True)
    archive = output / (name + '.zip')
    checksum = archive.with_suffix('.sha256')
    if not args.audit_only:
        # A failed rerun must never leave an older ZIP looking newly verified.
        archive.unlink(missing_ok=True)
        checksum.unlink(missing_ok=True)
        (build / 'SHA256.json').unlink(missing_ok=True)
    logs = build / 'logs'
    if not args.audit_only and logs.exists():
        shutil.rmtree(logs)
    logs.mkdir(parents=True, exist_ok=True)
    report = audit_assets()
    (build / 'ASSET_LICENSE_REPORT.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    for warning in report['warnings']:
        print('ASSET LICENSE WARNING (export continues): ' + warning, flush=True)
    if args.audit_only:
        print(json.dumps({'selected_assets': len(report['assets']), 'warnings': report['warnings'],
                          'report': str(build / 'ASSET_LICENSE_REPORT.json')}, indent=2))
        return
    godot = find_godot(args.godot)
    templates = find_templates(args.templates_dir)
    env = os.environ.copy()
    # Use the user's normal Godot settings/templates on each OS; honor XDG overrides.
    commands = []

    def run(label, arguments, cwd=ROOT, checks=False):
        print(f'{label} ...', flush=True)
        result = subprocess.run(arguments, cwd=cwd, env=env, text=True, encoding='utf-8', errors='replace', stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, timeout=240)
        (logs / f'{label}.log').write_text(result.stdout, encoding='utf-8')
        commands.append({'label': label, 'command': arguments, 'cwd': str(cwd), 'exit_code': result.returncode})
        (build / 'COMMANDS.json').write_text(json.dumps(commands, indent=2) + '\n', encoding='utf-8')
        if result.returncode or re.search(r'^(?:SCRIPT ERROR:|ERROR:)', result.stdout, re.M):
            raise RuntimeError(f'{label} failed; see {logs / (label + ".log")}')
        if checks and not re.search(r'RESULT: \d+ checks, 0 failures', result.stdout):
            raise RuntimeError(f'{label} did not finish its checks')
        return result.stdout

    version = run('version', [godot, '--version']).strip()
    if not version.startswith('4.6.3.stable.'):
        raise RuntimeError('Expected Godot 4.6.3 stable, found ' + version)
    if not (templates / 'version.txt').is_file() or (templates / 'version.txt').read_text(encoding='utf-8').strip() != TEMPLATE_VERSION:
        raise RuntimeError('Install matching 4.6.3.stable export templates in ' + str(templates))
    required_templates = required_template_names(sys.platform)
    provenance = json.loads((ROOT / 'docs/RC_TEMPLATE_PROVENANCE.json').read_text(encoding='utf-8'))
    for template in required_templates:
        if not (templates / template).is_file():
            raise RuntimeError('Missing matching template: ' + template)
        if sha(templates / template) != provenance['files'][template]['sha256']:
            raise RuntimeError('Template does not match the recorded official 4.6.3 file: ' + template)
    run('import', [godot, '--headless', '--editor', '--path', str(ROOT), '--import', '--quit'])
    run('source-cleanup-audit', [sys.executable, str(ROOT / 'tools/check_pixel_only.py')])
    run('release-workflow-tests', [sys.executable, '-m', 'unittest', 'discover', '-s', 'tests', '-p', 'test_release.py'])
    run('pixel-source-regression', [godot, '--headless', '--path', str(ROOT), '--script', 'tests/regression.gd'], checks=True)
    for label, script in [('pixel-presentation', 'pixel_art_validation'), ('controller-death', 'release_controls_validation')]:
        run(label, [godot, '--headless', '--path', str(ROOT), '--script', 'tests/' + script + '.gd'], checks=True)
    windows = build / 'windows' / 'Stylebreaker.exe'
    linux = build / 'linux' / 'Stylebreaker.x86_64'
    windows.parent.mkdir(exist_ok=True)
    linux.parent.mkdir(exist_ok=True)
    windows.unlink(missing_ok=True)
    linux.unlink(missing_ok=True)
    selected = runtime_resources(report)
    all_media = ['res://' + p.relative_to(ROOT).as_posix() for p in (ROOT / 'assets/Art').rglob('*') if p.suffix.lower() in ['.png', '.gif', '.psd', '.aseprite']]
    pack_spec = {'private_qa': args.private_qa, 'expected_assets': [a['path'] for a in report['assets']],
                 'forbidden_assets': sorted(set(all_media) - {a['path'] for a in report['assets']}),
                 'forbidden_paths': []}
    with (ROOT / 'docs/CLEANUP_DELETIONS.csv').open(encoding='utf-8') as ledger:
        pack_spec['forbidden_paths'] = ['res://' + row['path'] for row in csv.DictReader(ledger)
                                        if not row['path'].startswith(('/', '.godot/', 'builds/', 'dist/'))]

    pack_spec_path = build / 'PACK_EXPECTATIONS.json'
    pack_spec_path.write_text(json.dumps(pack_spec, indent=2) + '\n', encoding='utf-8')
    with tempfile.TemporaryDirectory(prefix='stylebreaker-rc-') as temp_name:
        temp = Path(temp_name)
        copy = temp / 'project'
        shutil.copytree(ROOT, copy, ignore=shutil.ignore_patterns('.git', '.godot', 'builds', 'dist', '__pycache__', '.test-artifacts'))
        cfg = export_configuration((copy / 'export_presets.cfg').read_text(encoding='utf-8'), selected, templates, args.private_qa)
        (copy / 'export_presets.cfg').write_text(cfg, encoding='utf-8')
        (build / 'EXPORT_PRESETS.cfg').write_text(cfg, encoding='utf-8')
        run('export-copy-import', [godot, '--headless', '--editor', '--path', str(copy), '--import', '--quit'])
        run('windows-export', [godot, '--headless', '--editor', '--path', str(copy), '--export-release', 'Windows Desktop', str(windows)])
        verify_executable(windows)
        native_status = 'NOT TESTED (host: ' + sys.platform + ')'
        artifacts = [windows]
        if sys.platform.startswith('linux'):
            run('linux-export', [godot, '--headless', '--editor', '--path', str(copy), '--export-release', 'Linux Validation', str(linux)])
            run('linux-startup', [str(linux), '--headless', '--quit-after', '120'], temp)
            artifacts.append(linux)
        elif sys.platform == 'win32':
            run('windows-headless-startup', [str(windows), '--headless', '--quit-after', '120'], temp)
            native_status = 'Headless startup passed on Windows; interactive playtest NOT TESTED'
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
        for filename in ['GODOT_LICENSE.txt', 'GODOT_COPYRIGHT.txt', 'FOREST_HISTORICAL_README.txt', 'FOREST_HISTORICAL_TERMS.txt']:
            shutil.copy2(ROOT / 'docs/licenses' / filename, licenses / filename)
        status = ('PRIVATE OWNER QA — NOT FOR DISTRIBUTION\n' if args.private_qa else 'RELEASE CANDIDATE — NOT APPROVED\n')
        status += ('Stylebreaker — Pre-Alpha v0.1.0 — Windows x86_64\n'
                   'Physical controller/audio and interactive Windows playtest: NOT TESTED.\n'
                   'No itch.io publication or upload was performed.\n')
        status += 'Native Windows execution: ' + native_status + '\n'
        status += '\nUnresolved license evidence (nonblocking export warnings):\n' + '\n'.join(report['warnings']) + '\n'
        (stage / 'BUILD_STATUS.txt').write_text(status, encoding='utf-8')
        try:
            revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True, encoding='utf-8', stderr=subprocess.DEVNULL).strip()
            tracked = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode('utf-8').split('\0')
            dirty = bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT).strip())
        except (OSError, subprocess.CalledProcessError):
            revision, dirty = None, None
            tracked = [p.removeprefix('res://') for p in selected] + ['project.godot', 'export_presets.cfg', 'tools/release_assets.json']
        sources = {p: sha(ROOT / p) for p in tracked if p and (ROOT / p).is_file()}
        manifest = {'godot': version, 'source_commit': revision,
                    'source_worktree_dirty': dirty,
                    'private_qa': args.private_qa, 'public_release_approved': False,
                    'windows_native_execution': native_status, 'interactive_windows_playtest': 'NOT TESTED',
                    'asset_rights_cleared': report['asset_rights_cleared'], 'license_verification_blocks_export': False,
                    'template_sha256': {p: sha(templates / p) for p in required_templates},
                    'template_source': provenance['source'],
                    'source_sha256': sources,
                    'package_sha256': {p.relative_to(stage).as_posix(): sha(p) for p in sorted(stage.rglob('*')) if p.is_file()}}
        (stage / 'BUILD_MANIFEST.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
        temporary_zip = build / (name + '.zip.pending')
        try:
            with zipfile.ZipFile(temporary_zip, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as out:
                for path in sorted(stage.rglob('*')):
                    if path.is_file():
                        out.write(path, path.relative_to(stage.parent).as_posix())
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
            if json.loads((bundle / 'BUILD_MANIFEST.json').read_text(encoding='utf-8')) != manifest:
                raise RuntimeError('Extracted build manifest mismatch')
            if sha(extracted_exe) != sha(windows):
                raise RuntimeError('Extracted executable differs from tested export')
            if sys.platform == 'win32':
                run('extracted-windows-startup', [str(extracted_exe), '--headless', '--quit-after', '120'], extracted)
            run('extracted-windows-pack-validation', [godot, '--headless', '--main-pack', str(extracted_exe),
                '--script', str(ROOT / 'tests/release_candidate_validation.gd'), '--', str(pack_spec_path), str(build / 'PACK_CONTENTS.json')], extracted, checks=True)
            run('extracted-windows-pack-regression', [godot, '--headless', '--main-pack', str(extracted_exe),
                '--script', str(ROOT / 'tests/regression.gd')], extracted, checks=True)
            run('extracted-windows-controller-death', [godot, '--headless', '--main-pack', str(extracted_exe),
                '--script', str(ROOT / 'tests/release_controls_validation.gd')], extracted, checks=True)
            run('extracted-pack-cleanup-audit', [sys.executable, str(ROOT / 'tools/check_pixel_only.py'), '--pack', str(build / 'PACK_CONTENTS.json')])
            run('derived-media-audit', [sys.executable, str(ROOT / 'tools/audit_rc_pack.py'), '--build', str(build)])
            shutil.move(temporary_zip, archive)
        except BaseException:
            temporary_zip.unlink(missing_ok=True)
            raise
    checksum.write_text(f'{sha(archive)}  {archive.name}\n', encoding='utf-8')
    checksums = {p.relative_to(ROOT).as_posix(): sha(p) for p in artifacts + [archive]}
    (build / 'SHA256.json').write_text(json.dumps(checksums, indent=2) + '\n', encoding='utf-8')
    print(f'Verified Windows ZIP: {archive}\nSHA-256: {sha(archive)}\nNative Windows execution: {native_status}\n'
          f'Unresolved asset-permission warnings: {len(report["warnings"])} (see ASSET_LICENSE_REPORT). No publication performed.', flush=True)


if __name__ == '__main__':
    main()
