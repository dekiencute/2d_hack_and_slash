#!/usr/bin/env python3
"""Check active runtime dependencies and optional actual exported-pack inventory."""
from pathlib import Path
import argparse,csv,json,re
ROOT=Path(__file__).resolve().parents[1]
RUNTIME=['actors','combat','pixel_art','resources','systems','ui']

def main():
 parser=argparse.ArgumentParser(description=__doc__)
 parser.add_argument('--pack',type=Path)
 args=parser.parse_args()
 errors=[]
 files=[p for folder in RUNTIME for p in (ROOT/folder).rglob('*') if p.is_file()]
 files += [ROOT/'project.godot',ROOT/'export_presets.cfg']
 for p in files:
  if p.suffix=='.svg':errors.append(str(p.relative_to(ROOT)))
  if p.suffix not in ['.gd','.tscn','.tres','.godot','.cfg']:continue
  text=p.read_text()
  if p.suffix=='.gd' and re.search(r'\bdraw_(?:arc|line|polygon|circle|rect)\s*\(',text):errors.append('Illustrative draw function: '+str(p))
  if p.suffix=='.tscn' and re.search(r'type="(?:Polygon2D|Line2D|MeshInstance2D)"',text):errors.append('Illustrative geometry node: '+str(p))
  for ref in re.findall(r'res://[^"\'\n]+',text):
   target=ROOT/ref.removeprefix('res://')
   if not target.exists():errors.append(f'{p.relative_to(ROOT)} -> missing {ref}')
 for folder in ['tests','tools']:
  for p in (ROOT/folder).glob('*'):
   if p.suffix not in ['.gd','.py']:continue
   for ref in re.findall(r'(?:load|preload)\(\s*["\'](res://[^"\']+)',p.read_text()):
    if not (ROOT/ref.removeprefix('res://')).exists():errors.append(f'{p.relative_to(ROOT)} loads missing {ref}')
 deleted=[]
 with (ROOT/'docs/CLEANUP_DELETIONS.csv').open() as f:
  for row in csv.DictReader(f):
   p=Path(row['path'])
   if not p.is_absolute() and not row['path'].startswith(('.godot/','builds/','dist/','tools/__pycache__/')):
    deleted.append(row['path'])
    # Regenerated caches/build output are deliberately not treated as source.
    if (ROOT/p).is_file():errors.append('Deleted source reappeared: '+str(p))
 if args.pack:
  entries=json.loads(args.pack.read_text())['files']
  for e in entries:
   path=e['path'].removeprefix('res://')
   if '.svg' in path or path in deleted:errors.append('Removed asset in exported pack: '+path)
 if errors:raise SystemExit('\n'.join(errors))
 print('PASS: active runtime references exist; no generated SVG/illustrative geometry; deleted sources absent'+('; exported pack clean' if args.pack else ''))
if __name__=='__main__':main()
