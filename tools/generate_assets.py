#!/usr/bin/env python3
"""Rebuild original geometric SVG art and synthesized PCM sound. No source media."""
from pathlib import Path
import math
import random
import struct
import wave

ROOT = Path(__file__).resolve().parents[1] / 'resources' / 'original'
ROOT.mkdir(parents=True, exist_ok=True)


def svg(name, width, height, content):
    (ROOT / name).write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">{content}</svg>\n')


def fighter(kind, frame):
    phase = frame * math.pi / 3
    stride = math.sin(phase) * 5 if kind == 'Run' else math.sin(phase) * .6
    bob = abs(math.sin(phase)) if kind in ('Run', 'Idle') else 0
    attack = 'Combo' in kind
    angle = (-100 + frame * 32) if attack else (-30 if kind == 'Dash' else -65)
    if kind == 'JumpAndFall':
        stride = 4
    if kind == 'Die':
        angle = 25
    return f'''<g transform="translate(0 {-bob:.2f})" stroke-linejoin="round">
    <path d="M36 19 L17 22 L23 27 L34 25" fill="#d6a951"/>
    <path d="M35 30 L{33-stride:.2f} 43 L{39-stride:.2f} 43 L41 31 M42 31 L{44+stride:.2f} 43 L{50+stride:.2f} 43 L47 29" fill="#152339" stroke="#7aa0b5" stroke-width="1.5"/>
    <path d="M33 20 L44 18 L49 30 L40 34 L31 29 Z" fill="#25475a" stroke="#65dbd1" stroke-width="1.5"/>
    <path d="M36 20 L43 19 L42 29 L38 30 Z" fill="#58d6d0"/>
    <path d="M32 9 L43 8 L48 15 L44 20 L34 20 L30 15 Z" fill="#d5ede8" stroke="#142338" stroke-width="1.3"/>
    <path d="M35 13 L47 13 L45 16 L35 16 Z" fill="#142338"/>
    <path d="M40 14 L46 14" stroke="#5df2df" stroke-width="1.4"/>
    <path d="M33 21 L28 27 L32 30 M44 21 L50 25" fill="none" stroke="#aadbd6" stroke-width="3"/>
    <g transform="rotate({angle} 49 25)"><path d="M47 25 L74 23 L78 25 L74 27 L47 27 Z" fill="#e2fcf5" stroke="#62d8d4" stroke-width="1"/><path d="M48 21 L48 30 M43 26 L49 26" stroke="#dbab58" stroke-width="2.5"/></g>
    </g>'''


# Frame sizes and counts match the existing AnimationPlayer/SpriteFrames tracks.
STRIPS = {'Die': 4, 'AirCombo1': 7, 'AirCombo2': 7, 'AirCombo3': 9,
          'JumpAndFall': 2, 'Idle': 8, 'Dash': 5, 'Run': 8,
          'GroundCombo1': 6, 'GroundCombo2': 8, 'GroundCombo3': 14}
for kind, count in STRIPS.items():
    svg(f'player_{kind.lower()}.svg', count * 80, 48, ''.join(
        f'<g transform="translate({i * 80} 0)">{fighter(kind, i)}</g>' for i in range(count)))

svg('enemy.svg', 64, 80, '''
<g stroke="#171c30" stroke-width="2" stroke-linejoin="round">
<path d="M18 48 L15 76 L25 76 L30 52 M35 51 L39 76 L49 76 L46 47" fill="#b9a7b9"/>
<path d="M14 27 L4 44 L11 54 L21 38 M46 28 L59 42 L55 54 L42 39" fill="#c7b8cb"/>
<path d="M17 24 L45 24 L49 49 L32 60 L15 49 Z" fill="#ede4ee"/>
<path d="M23 32 L42 32 L38 47 L28 47 Z" fill="#242c41"/>
<path d="M27 37 L37 37 L32 45 Z" fill="#fff4cf" stroke="none"/>
<path d="M18 11 L26 3 L39 3 L46 12 L42 25 L22 25 Z" fill="#f1e7eb"/>
<path d="M21 13 L44 13 L40 19 L25 19 Z" fill="#20293d"/>
<path d="M25 15 L40 15" stroke="#fff1c6" stroke-width="2"/>
<path d="M6 43 L14 43 M48 43 L57 43" stroke="#fff1c6"/>
</g>''')

bg = ['<rect width="1800" height="1100" fill="#0b1322"/>',
      '<path d="M0 620 L1800 620 L1800 1100 L0 1100Z" fill="#101d2d"/>',
      '<circle cx="900" cy="530" r="245" fill="#0f2130" stroke="#23414a" stroke-width="2"/>',
      '<circle cx="900" cy="530" r="220" fill="none" stroke="#305959" stroke-width="5"/>',
      '<path d="M900 345 L995 530 L900 715 L805 530Z" fill="#17303c" stroke="#42716c" stroke-width="2"/>',
      '<path d="M900 405 L962 530 L900 655 L838 530Z" fill="#102432" stroke="#c3a05b" stroke-width="2"/>']
for x in range(0, 1801, 130):
    bg.append(f'<path d="M{x} 120 L{x+30} 120 L{x+30} 915 L{x} 915Z" fill="#122333"/><path d="M{x+5} 145 L{x+5} 850" stroke="#24404b" stroke-width="2"/>')
for y in (260, 620, 820):
    bg.append(f'<path d="M0 {y} H1800" stroke="#253c48" stroke-width="2"/>')
for x in range(40, 1800, 90):
    bg.append(f'<path d="M{x} 916 L{x-80} 1100" stroke="#203443"/>')
for y in (940, 985, 1050):
    bg.append(f'<path d="M0 {y} H1800" stroke="#203443"/>')
bg += ['<rect y="916" width="1800" height="5" fill="#74b4af"/>',
       '<rect y="921" width="1800" height="10" fill="#253d4a"/>']
for x in (220, 1550):
    bg.append(f'<path d="M{x} 916 L{x} 685 L{x+25} 670 L{x+50} 685 L{x+50} 916Z" fill="#182e3c" stroke="#46646a" stroke-width="2"/><path d="M{x+18} 705 V860 M{x+32} 705 V860" stroke="#edbb65" stroke-width="3"/>')
svg('arena.svg', 1800, 1100, ''.join(bg))
svg('icon.svg', 128, 128, '<rect width="128" height="128" rx="24" fill="#101d2d"/><path d="M64 14 L104 64 L64 114 L24 64Z" fill="#25475a" stroke="#64e1d1" stroke-width="4"/><path d="M82 28 L51 62 L73 62 L43 101 L56 68 L37 68Z" fill="#f3cc7d"/>')

# Deterministic synthesis: short, faded mono effects, with no samples or voices.
AUDIO = ROOT / 'audio'
AUDIO.mkdir(exist_ok=True)
for name, duration in [('slash', .14), ('hit', .12), ('dash', .19), ('hurt', .25),
                       ('wave', .65), ('victory', 1.2), ('defeat', .8)]:
    rng = random.Random(name)
    rate = 22050
    samples = []
    for i in range(int(rate * duration)):
        t = i / rate
        p = t / duration
        env = min(t / .008, 1) * (1 - p) ** 1.8
        if name in ('slash', 'dash'):
            value = rng.uniform(-1, 1) * .6 + math.sin(2 * math.pi * (700 * t - 1300 * t * t)) * .15
        elif name in ('hit', 'hurt'):
            value = math.sin(2 * math.pi * (110 * t - 100 * t * t)) * .6 + rng.uniform(-1, 1) * .25
        else:
            notes = {'wave': [330, 440, 660], 'victory': [330, 440, 554, 660, 880], 'defeat': [330, 277, 220]}[name]
            freq = notes[min(int(p * len(notes)), len(notes)-1)]
            value = math.sin(2 * math.pi * freq * t) * .5 + math.sin(4 * math.pi * freq * t) * .12
        samples.append(struct.pack('<h', int(value * env * 18000)))
    with wave.open(str(AUDIO / f'{name}.wav'), 'wb') as out:
        out.setparams((1, 2, rate, 0, 'NONE', 'not compressed'))
        out.writeframes(b''.join(samples))
print('Generated 14 SVG assets and 7 original synthesized sounds.')
