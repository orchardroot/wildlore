import json, os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')

def dump(rel, obj):
    p = os.path.join(ROOT, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, 'w') as f:
        json.dump(obj, f, indent=1, ensure_ascii=False)
        f.write('\n')
    s = json.dumps(obj, ensure_ascii=False)
    assert '—' not in s, rel + ' has an em-dash'

def say(who, text):
    assert '—' not in text
    return {"do": "say", "who": who, "text": text}

def setf(flag):
    return {"do": "set", "flag": flag}

def iff(flag, then, els=None):
    d = {"do": "if", "flag": flag, "then": then}
    if els is not None:
        d["else"] = els
    return d

def when(cond, then, els=None):
    d = {"do": "when", "cond": cond, "then": then}
    if els is not None:
        d["else"] = els
    return d

def give(item, n=1):
    return {"do": "give_item", "item": item, "n": n}

def standing(n=10):
    return {"do": "standing", "nation": "overseas", "amount": n}

def battle(tid):
    return {"do": "battle", "trainer": tid}


class Zone:
    def __init__(self, zid, name, w, h, fill='g', kind='town', region='', music='', stage='', weather=None, legend=None):
        self.id, self.name, self.w, self.h = zid, name, w, h
        self.g = [[fill] * w for _ in range(h)]
        self.kind, self.region, self.music, self.stage = kind, region, music, stage
        self.weather = weather or {}
        self.legend = legend or {}
        self.props, self.warps, self.npcs, self.signs, self.edges = [], [], [], [], {}
        self.encounters = {}
        self.spawn = (0, 0)
        self.extra = {}
        self.dialogue = {}

    def rect(self, x, y, w, h, ch):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                self.g[yy][xx] = ch

    def at(self, x, y):
        return self.g[y][x]

    def put(self, x, y, ch):
        self.g[y][x] = ch

    def building(self, x, y, w, h, style, label=None, door=None, show_label=None):
        self.rect(x, y, w, h, 'B')
        p = {"type": "building", "style": style, "x": x, "y": y, "w": w, "h": h}
        if label:
            p["label"] = label
        if show_label is False or label is None:
            p["show_label"] = False
        self.props.append(p)
        if door is None:
            return None
        dx, dy = x + door, y + h - 1
        self.g[dy][dx] = 'D'
        return (dx, dy)

    def prop(self, typ, x, y, **kw):
        d = {"type": typ, "x": x, "y": y}
        d.update(kw)
        self.props.append(d)

    def npc(self, nid, sprite, x, y, facing='down', script=None, trainer=None, name=None, move='still', **kw):
        d = {"id": nid, "sprite": sprite, "x": x, "y": y, "facing": facing, "move": move}
        if script:
            d["script"] = script
        if trainer:
            d["trainer"] = trainer
        if name:
            d["name"] = name
        d.update(kw)
        self.npcs.append(d)

    def sign(self, x, y, text, plaque=None, title=None, **kw):
        assert '—' not in text
        d = {"x": x, "y": y}
        if plaque:
            d["plaque"] = plaque
            d["title"] = title
        d["text"] = text
        d.update(kw)
        self.signs.append(d)

    def rows(self):
        return [''.join(r) for r in self.g]

    def to_json(self):
        d = {"id": self.id, "name": self.name, "region": self.region, "kind": self.kind, "music": self.music,
             "weather": self.weather, "props": self.props, "warps": self.warps, "edges": self.edges,
             "npcs": self.npcs, "encounters": self.encounters, "signs": self.signs,
             "spawn": list(self.spawn)}
        if self.kind != 'interior':
            d["scaled_floor"] = 95
        if self.stage:
            d["stage"] = self.stage
        d["rows"] = self.rows()
        if self.legend:
            d["legend_extra"] = self.legend
        d.update(self.extra)
        for r in d["rows"]:
            assert len(r) == self.w, (self.id, len(r), self.w)
        assert len(d["rows"]) == self.h
        return d

    def save(self):
        dump('data/zones/%s.json' % self.id, self.to_json())
        if self.dialogue:
            dump('data/dialogue/%s.json' % self.id, self.dialogue)


def interior(town, door, iid, name, w=11, h=9, music='', counter=None, props=None, npcs=None, rows=None):
    """An interior behind `door` (x, y) in `town`: a room w x h, door on the bottom wall's middle."""
    z = Zone(iid, name, w, h, fill='|', kind='interior', music=music)
    z.rect(0, 0, w, 1, 'x'); z.rect(0, h - 1, w, 1, 'x'); z.rect(0, 0, 1, h, 'x'); z.rect(w - 1, 0, 1, h, 'x')
    dx = w // 2
    z.put(dx, h - 2, 'D')
    if rows:
        for y, r in enumerate(rows):
            z.g[y] = list(r)
        dx = rows[h - 2].index('D')
    if counter:
        cx, cy, cw = counter
        for x in range(cx, cx + cw):
            z.put(x, cy, 'C')
    z.spawn = (dx, h - 3)
    z.warps.append({"x": dx, "y": h - 2, "to": town.id, "tx": door[0], "ty": door[1] + 1, "facing": "down"})
    town.warps.append({"x": door[0], "y": door[1], "to": iid, "tx": dx, "ty": h - 3, "facing": "up"})
    for p in props or []:
        z.props.append(p)
    for n in npcs or []:
        z.npcs.append(n)
    return z


def npcd(nid, sprite, x, y, facing='down', script=None, name=None, trainer=None):
    d = {"id": nid, "sprite": sprite, "x": x, "y": y, "facing": facing, "move": "still"}
    if script:
        d["script"] = script
    if trainer:
        d["trainer"] = trainer
    if name:
        d["name"] = name
    return d


def trainer(tid, name, cls, sprite, party, intro, win, after, money=4200):
    t = {"id": tid, "name": name, "class": cls, "sprite": sprite,
         "party": [{"species": s, "level": 95} for s, l in party], "ai": "trainer", "money": money,
         "intro": [say(name, x) for x in intro], "win": win, "after": after, "scaled_floor": 95}
    for x in [win, after] + intro:
        assert '—' not in x
    dump('data/trainers/%s.json' % tid, t)
    return t


def nurse_script(hello, healing, healed, ark, browse):
    return [
        say("Nurse", hello),
        {"do": "choice", "text": "What can we do for you?", "options": ["Heal my team", "Open the Ark", "Just looking"], "set": "_nurse_choice"},
        {"do": "if", "flag": "_nurse_choice", "eq": 0,
         "then": [say("Nurse", healing), {"do": "heal"}, say("Nurse", healed)],
         "else": [{"do": "if", "flag": "_nurse_choice", "eq": 1,
                   "then": [say("Nurse", ark), {"do": "ark"}],
                   "else": [say("Nurse", browse)]}]},
    ]


def sanctuary(town, door, iid, name, nurse_lines):
    z = interior(town, door, iid, name, music='sanctuary', counter=(3, 3, 5),
                 props=[{"type": "potted_plant", "x": 1, "y": 1}, {"type": "potted_plant", "x": 9, "y": 1},
                        {"type": "bookshelf", "x": 1, "y": 4}, {"type": "table", "x": 9, "y": 4}],
                 npcs=[npcd("nurse", "sanctuary_nurse", 5, 2, script="nurse"),
                       npcd("memory_coach", "poet", 8, 4, script="memory_coach", name="Retired Keeper")])
    z.put(1, 6, '+'); z.put(2, 6, '+'); z.put(8, 6, '+'); z.put(9, 6, '+')
    z.dialogue["nurse"] = nurse_script(*nurse_lines)
    return z


def shop(town, door, iid, name, shop_id, hello, bye, who="Shopkeeper", extra_npcs=None, extra_dialogue=None):
    z = interior(town, door, iid, name, w=9, h=8,
                 rows=["xxxxxxxxx", "x|||||||x", "x|CCC|CCx", "x|||||CCx", "x|||||CCx", "x|||||||x", "x|||D|||x", "xxxxxxxxx"],
                 props=[{"type": "bookshelf", "x": 1, "y": 1}, {"type": "potted_plant", "x": 7, "y": 5}],
                 npcs=[npcd("shopkeeper", "shopkeeper", 3, 1, script="shopkeeper", name=who if who != "Shopkeeper" else None)] + (extra_npcs or []))
    z.dialogue["shopkeeper"] = [say(who, hello), {"do": "shop", "id": shop_id}, say(who, bye)]
    if extra_dialogue:
        z.dialogue.update(extra_dialogue)
    return z


def edge(a, side, b, offset=0):
    opp = {"north": "south", "south": "north", "east": "west", "west": "east"}[side]
    a.edges[side] = {"to": b.id, "offset": offset}
    b.edges[opp] = {"to": a.id, "offset": -offset}


def enc(species, weight, lo=95, hi=97, **kw):
    d = {"species": species, "min": lo, "max": hi, "weight": weight}
    d.update(kw)
    return d
