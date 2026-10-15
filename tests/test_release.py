"""Packaging-policy and Windows path tests; no Godot or artwork changes."""
import importlib.util
import json
import os
from pathlib import Path, PureWindowsPath
import re
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location('stylebreaker_release', Path(__file__).resolve().parents[1] / 'tools/release.py')
release = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(release)


class ReleaseWorkflowTests(unittest.TestCase):
    def test_pending_permissions_are_warnings_without_false_clearance(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'tools').mkdir()
            (root / 'fixture.bin').write_bytes(b'permission audit fixture')
            for status in ['unverified', 'verified']:
                # Even a status label cannot clear missing creator evidence.
                (root / 'tools/release_assets.json').write_text(json.dumps({'groups': [{
                    'id': 'character', 'status': status, 'evidence': ['missing-terms.txt'],
                    'attribution': 'test', 'files': ['fixture.bin']}]}), encoding='utf-8')
                with patch.object(release, 'ROOT', root):
                    report = release.audit_assets()
                self.assertEqual(len(report['assets']), 1)
                self.assertEqual(len(report['warnings']), 1)
                self.assertFalse(report['asset_rights_cleared'])
                self.assertFalse(report['public_release_approved'])
                self.assertFalse(report['license_verification_blocks_export'])

    def test_missing_asset_remains_a_hard_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'tools').mkdir()
            (root / 'tools/release_assets.json').write_text(json.dumps({'groups': [{
                'id': 'missing', 'status': 'unverified', 'evidence': [], 'attribution': 'test',
                'files': ['missing.wav']}]}), encoding='utf-8')
            with patch.object(release, 'ROOT', root), self.assertRaisesRegex(RuntimeError, 'Missing required asset'):
                release.audit_assets()

    def test_normal_presets_select_exact_pixel_runtime_without_quarantine(self):
        config = (release.ROOT / 'export_presets.cfg').read_text(encoding='utf-8')
        resources = re.findall(r'^export_files=PackedStringArray\((.*)\)$', config, re.M)
        self.assertEqual(len(resources), 2)
        expected = release.runtime_resources(release.audit_assets())
        for value in resources:
            self.assertEqual(json.loads('[' + value + ']'), expected)
        self.assertNotIn('pixel_art/*', config)
        self.assertNotIn('assets/Art/*', config)
        self.assertTrue(all('\\' not in path for path in expected))

    def test_windows_template_location_and_host_requirements(self):
        with patch.object(release.sys, 'platform', 'win32'), patch.dict(os.environ, {'APPDATA': 'C:/Users/Test User/AppData/Roaming'}):
            self.assertEqual(release.find_templates().as_posix(), 'C:/Users/Test User/AppData/Roaming/Godot/export_templates/4.6.3.stable')
        self.assertNotIn('linux_release.x86_64', release.required_template_names('win32'))
        self.assertIn('linux_release.x86_64', release.required_template_names('linux'))

    def test_custom_windows_template_paths_use_godot_slashes(self):
        config = (release.ROOT / 'export_presets.cfg').read_text(encoding='utf-8')
        result = release.export_configuration(config, ['res://pixel_art/arena.tscn'], PureWindowsPath('C:/Godot Templates/4.6.3.stable'), True)
        self.assertIn('custom_template/release="C:/Godot Templates/4.6.3.stable/windows_release_x86_64.exe"', result)
        self.assertEqual(result.count('export_files='), 2)
        self.assertEqual(result.count('custom_features="private_qa"'), 2)

    def test_explicit_and_portable_godot_detection_with_spaces(self):
        with tempfile.TemporaryDirectory(prefix='Godot install ') as directory:
            root = Path(directory)
            exe = root / 'Godot_v4.6.3-stable_win64_console.exe'
            exe.touch()
            with patch.object(release.shutil, 'which', return_value=None):
                self.assertEqual(release.find_godot('"' + str(exe) + '"'), str(exe.resolve()))
                with patch.object(release, 'ROOT', root), patch.dict(os.environ, {}, clear=True):
                    self.assertEqual(release.find_godot(), str(exe.resolve()))

    def test_invalid_explicit_godot_does_not_fall_back_silently(self):
        with patch.object(release.shutil, 'which', return_value=None), self.assertRaisesRegex(RuntimeError, 'Godot executable not found'):
            release.find_godot('missing-godot-4.6.3.exe')

    def test_corrupt_windows_export_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            exe = Path(directory) / 'Stylebreaker.exe'
            exe.write_bytes(b'MZ broken')
            with self.assertRaisesRegex(RuntimeError, 'not a PE executable'):
                release.verify_executable(exe)


if __name__ == '__main__':
    unittest.main()
