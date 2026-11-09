"""Builds the TeamXperience start-up animation as Lottie JSON, from the real
Poppins Bold letter outlines. White letters and a yellow X for a navy page;
a teal dashed route draws underneath and ends in a dot that pulses (the loop)."""
import json
import sys

from fontTools.pens.basePen import BasePen
from fontTools.ttLib import TTFont

FONT = sys.argv[1]
OUT = sys.argv[2]

TEXT = 'TeamXperience'
EM = 104            # px per em
FPS = 60
INTRO = 110         # frames of the intro; the loop is INTRO..END
END = 150
PAD_X = 36
BASELINE = 150
HEIGHT = 250

WHITE = [1, 1, 1, 1]
YELLOW = [246 / 255, 175 / 255, 26 / 255, 1]
TEAL = [83 / 255, 196 / 255, 199 / 255, 1]


class LottiePen(BasePen):
    """Collects contours as Lottie paths, in px, y downwards."""

    def __init__(self, glyphset, scale, dx, dy):
        super().__init__(glyphset)
        self.scale, self.dx, self.dy = scale, dx, dy
        self.paths = []
        self.cur = None

    def _pt(self, p):
        return [round(p[0] * self.scale + self.dx, 2), round(-p[1] * self.scale + self.dy, 2)]

    def _moveTo(self, p):
        self.cur = {'v': [self._pt(p)], 'i': [[0, 0]], 'o': [[0, 0]]}

    def _lineTo(self, p):
        self.cur['v'].append(self._pt(p))
        self.cur['i'].append([0, 0])
        self.cur['o'].append([0, 0])

    def _curveToOne(self, p1, p2, p3):
        last = self.cur['v'][-1]
        a, b, c = self._pt(p1), self._pt(p2), self._pt(p3)
        self.cur['o'][-1] = [round(a[0] - last[0], 2), round(a[1] - last[1], 2)]
        self.cur['v'].append(c)
        self.cur['i'].append([round(b[0] - c[0], 2), round(b[1] - c[1], 2)])
        self.cur['o'].append([0, 0])

    def _closePath(self):
        cur = self.cur
        # A closing point equal to the start is merged into it.
        if len(cur['v']) > 1 and cur['v'][-1] == cur['v'][0]:
            cur['i'][0] = cur['i'][-1]
            cur['v'].pop(); cur['i'].pop(); cur['o'].pop()
        self.paths.append({**cur, 'c': True})
        self.cur = None

    _endPath = _closePath


def ease(t, s, out=(0.22, 1), inn=(0.36, 0)):
    return {'t': t, 's': s, 'o': {'x': [inn[0]], 'y': [inn[1]]}, 'i': {'x': [out[0]], 'y': [out[1]]}}


def anim(*keys):
    return {'a': 1, 'k': list(keys)}


def static(v):
    return {'a': 0, 'k': v}


def transform(anchor, pos, scale=None, opacity=None, rotation=None):
    return {
        'a': static(anchor + [0]),
        'p': pos if isinstance(pos, dict) else static(pos + [0]),
        's': scale or static([100, 100, 100]),
        'o': opacity or static(100),
        'r': rotation or static(0),
    }


def shape_layer(index, name, shapes, ks, ip=0, op=END):
    return {'ddd': 0, 'ind': index, 'ty': 4, 'nm': name, 'sr': 1, 'ks': ks, 'ao': 0,
            'shapes': shapes, 'ip': ip, 'op': op, 'st': 0, 'bm': 0}


def group(name, items):
    return {'ty': 'gr', 'nm': name, 'it': items + [{
        'ty': 'tr', 'p': static([0, 0]), 'a': static([0, 0]), 's': static([100, 100]),
        'r': static(0), 'o': static(100), 'sk': static(0), 'sa': static(0)}]}


font = TTFont(FONT)
glyphs = font.getGlyphSet()
cmap = font.getBestCmap()
upm = font['head'].unitsPerEm
scale = EM / upm
advances = [font['hmtx'][cmap[ord(ch)]][0] * scale for ch in TEXT]
text_width = sum(advances)
WIDTH = round(text_width + 2 * PAD_X)

layers = []
x = PAD_X
for i, ch in enumerate(TEXT):
    name = cmap[ord(ch)]
    pen = LottiePen(glyphs, scale, x, BASELINE)
    glyphs[name].draw(pen)
    is_x = ch == 'X'
    centre = [round(x + advances[i] / 2, 2), BASELINE]
    shapes = [group(ch, [{'ty': 'sh', 'ks': static(p)} for p in pen.paths] + [
        {'ty': 'fl', 'c': static(YELLOW if is_x else WHITE), 'o': static(100), 'r': 1}])]
    start = 4 + i * 4
    if is_x:
        start = 30
        ks = transform(
            [centre[0], BASELINE - EM * 0.36], [centre[0], BASELINE - EM * 0.36],
            scale=anim(ease(start, [0, 0, 100], out=(0.3, 1.45)), ease(start + 16, [118, 118, 100]), {'t': start + 26, 's': [100, 100, 100]}),
            opacity=anim({'t': start, 's': [0], 'h': 1}, {'t': start + 1, 's': [100]}),
            rotation=anim(ease(start, [-25]), {'t': start + 22, 's': [0]}),
        )
    else:
        ks = transform(
            centre, anim(ease(start, [centre[0], centre[1] + 34, 0]), {'t': start + 20, 's': [centre[0], centre[1], 0]}),
            opacity=anim(ease(start, [0]), {'t': start + 16, 's': [100]}),
        )
    layers.append(shape_layer(len(layers) + 1, ch, shapes, ks))
    x += advances[i]

# The route: a gentle wave under the word, drawn left to right, dashed.
y = BASELINE + 46
left, right = PAD_X + 6, WIDTH - PAD_X - 6
span = right - left
pts = [[left, y], [left + span * 0.33, y - 10], [left + span * 0.66, y + 10], [right, y]]
route = {'v': pts, 'i': [[0, 0], [-span * 0.12, 0], [-span * 0.12, 0], [-span * 0.12, 0]],
         'o': [[span * 0.12, 0], [span * 0.12, 0], [span * 0.12, 0], [0, 0]], 'c': False}
layers.append(shape_layer(len(layers) + 1, 'route', [group('route', [
    {'ty': 'sh', 'ks': static(route)},
    {'ty': 'tm', 's': static(0), 'e': anim(ease(52, [0], out=(0.4, 1), inn=(0.5, 0)), {'t': 96, 's': [100]}), 'o': static(0), 'm': 1},
    {'ty': 'st', 'c': static(TEAL), 'o': static(100), 'w': static(5), 'lc': 2, 'lj': 2, 'ml': 4,
     'd': [{'n': 'd', 'nm': 'dash', 'v': static(12)}, {'n': 'g', 'nm': 'gap', 'v': static(10)}]},
])], transform([0, 0], [0, 0])))

# The dot at the end: pops in, then pulses for as long as the loop plays.
dot_ks = transform(
    [right, y], [right, y],
    scale=anim(ease(92, [0, 0, 100], out=(0.3, 1.5)), ease(108, [100, 100, 100]), ease(INTRO, [100, 100, 100]),
               ease(INTRO + 20, [128, 128, 100]), {'t': END, 's': [100, 100, 100]}),
)
layers.append(shape_layer(len(layers) + 1, 'dot', [group('dot', [
    {'ty': 'el', 'p': static([right, y]), 's': static([18, 18]), 'd': 1},
    {'ty': 'fl', 'c': static(TEAL), 'o': static(100), 'r': 1},
])], dot_ks))

layers.reverse()  # Lottie draws the first layer on top.
for n, layer in enumerate(layers, start=1):
    layer['ind'] = n

doc = {
    'v': '5.7.4', 'fr': FPS, 'ip': 0, 'op': END, 'w': WIDTH, 'h': HEIGHT,
    'nm': 'TeamXperience', 'ddd': 0, 'assets': [], 'layers': layers,
    'markers': [{'tm': 0, 'cm': 'intro', 'dr': INTRO}, {'tm': INTRO, 'cm': 'loop', 'dr': END - INTRO}],
}
with open(OUT, 'w', encoding='utf8') as f:
    json.dump(doc, f, separators=(',', ':'))
print(f'{WIDTH}x{HEIGHT}, {len(layers)} layers, {END / FPS:.2f}s, loop from {INTRO / FPS:.2f}s')
