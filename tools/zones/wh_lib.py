"""Small helpers for the West Highlands region generator (tools/zones/westhighlands.py).

Builds outdoor zones on a character canvas, interiors from a spec, and collects dialogue and trainers so the
generator can write data/zones, data/dialogue and data/trainers in the game's usual JSON shape.
"""
import json
import os
import random

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
ZONES = {}      # id -> zone dict
DIALOGUE = {}   # zone id -> {script id -> [commands]}
TRAINERS = {}   # trainer id -> dict


def say(who, text):
    return {"do": "say", "who": who, "text": text}


def set_flag(flag, value=True):
    c = {"do": "set", "flag": flag}
    if value is not True:
        c["value"] = value
    return c


def if_(flag, then, other=None, eq=None):
    c = {"do": "if", "flag": flag, "then": then, "else": other or []}
    if eq is not None:
        c["eq"] = eq
    return c


def choice(text, options, flag):
    return {"do": "choice", "text": text, "options": options, "set": flag}


def item(item_id, n=1):
    c = {"do": "give_item", "item": item_id}
    if n != 1:
        c["n"] = n
    return c


def standing(nation, amount):
    return {"do": "standing", "nation": nation, "amount": amount}


def script(zone_id, script_id, cmds):
    DIALOGUE.setdefault(zone_id, {})[script_id] = cmds


def talk(zone_id, script_id, who, *lines):
    """A plain NPC script: one say per line."""
    script(zone_id, script_id, [say(who, t) for t in lines])


def trainer(tid, name, cls, sprite, party, money, intro, win, after, scaled=69, **extra):
    t = {"id": tid, "name": name, "class": cls, "sprite": sprite,
         "party": [{"species": s, "level": lv} for s, lv in party], "ai": "trainer", "money": money,
         "scaled_floor": scaled, "intro": [say(name, i) for i in intro], "win": win, "after": after}
    t.update(extra)
    TRAINERS[tid] = t
    return tid


class Out:
    """An outdoor zone drawn on a character grid."""

    def __init__(self, zid, name, kind, w, h, music, stage, weather, region="scotland", fill=".", scaled=69, town=False):
        self.id, self.name, self.kind, self.w, self.h = zid, name, kind, w, h
        self.g = [[fill] * w for _ in range(h)]
        self.music, self.stage, self.weather, self.region = music, stage, weather, region
        self.props, self.signs, self.npcs, self.warps, self.edges = [], [], [], [], {}
        self.encounters, self.scaled, self.town = {}, scaled, town
        self.spawn = [w // 2, h // 2]
        self.extra = {}
        self.rng = random.Random(zid)
        self.plaques = []

    # --- painting -----------------------------------------------------------
    def put(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.g[y][x] = c

    def at(self, x, y):
        return self.g[y][x] if 0 <= x < self.w and 0 <= y < self.h else "x"

    def rect(self, x, y, w, h, c):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                self.put(xx, yy, c)

    def ell(self, cx, cy, rx, ry, c, only=None):
        for yy in range(int(cy - ry) - 1, int(cy + ry) + 2):
            for xx in range(int(cx - rx) - 1, int(cx + rx) + 2):
                if ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2 <= 1.0:
                    if only is None or self.at(xx, yy) in only:
                        self.put(xx, yy, c)

    def line(self, pts, c, wd=1):
        """Axis-aligned polyline, wd tiles wide."""
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            for xx in range(min(x0, x1), max(x0, x1) + 1):
                for yy in range(min(y0, y1), max(y0, y1) + 1):
                    for k in range(wd):
                        if x0 == x1:
                            self.put(xx + k, yy, c)
                        else:
                            self.put(xx, yy + k, c)

    def border(self, c="T", c2="P", thick=2):
        for y in range(self.h):
            for x in range(self.w):
                if x < thick or y < thick or x >= self.w - thick or y >= self.h - thick:
                    self.put(x, y, c if (x * 7 + y * 3) % 11 else c2)

    def scatter(self, c, n, only=".", avoid=None):
        placed = 0
        tries = 0
        while placed < n and tries < n * 40:
            tries += 1
            x, y = self.rng.randrange(2, self.w - 2), self.rng.randrange(2, self.h - 2)
            if self.at(x, y) in only:
                self.put(x, y, c)
                placed += 1

    def sprinkle(self, ptype, n, only=".", variants=3, margin=3, rows=None):
        """Point props (bush, rock, birch...) on plain tiles, kept off the main paths by `only`."""
        placed = 0
        tries = 0
        used = {(int(p["x"]), int(p["y"])) for p in self.props}
        while placed < n and tries < n * 60:
            tries += 1
            x, y = self.rng.randrange(margin, self.w - margin), self.rng.randrange(margin, self.h - margin)
            if rows and not (rows[0] <= y <= rows[1]):
                continue
            if self.at(x, y) in only and (x, y) not in used:
                p = {"type": ptype, "x": x, "y": y}
                if variants:
                    p["variant"] = self.rng.randrange(variants)
                self.props.append(p)
                used.add((x, y))
                placed += 1

    # --- things ---------------------------------------------------------------
    def building(self, x, y, w, h, style, label, kind=None, door=None, to=None, tx=None, ty=None):
        """A B block with its door D on the bottom row; `to` wires a warp to an interior spawn (tx, ty)."""
        self.rect(x, y, w, h, "B")
        door = w // 2 if door is None else door
        pr = {"type": "building", "style": style, "x": x, "y": y, "w": w, "h": h, "label": label}
        if kind:
            pr["kind"] = kind
        self.props.append(pr)
        if door >= 0:
            self.put(x + door, y + h - 1, "D")
            if to:
                self.warps.append({"x": x + door, "y": y + h - 1, "to": to, "tx": tx, "ty": ty, "facing": "up"})
        return (x + door, y + h)  # the doorstep

    def sign(self, x, y, text, plaque=None, title=None):
        s = {"text": text, "x": x, "y": y}
        if plaque:
            s["plaque"] = plaque
            s["title"] = title
            self.plaques.append(plaque)
        self.signs.append(s)

    def npc(self, nid, sprite, x, y, script_id=None, facing="down", move="still", **kw):
        n = {"id": nid, "sprite": sprite, "x": x, "y": y, "facing": facing, "move": move}
        if script_id:
            n["script"] = script_id
        n.update(kw)
        self.npcs.append(n)

    def trainer_npc(self, nid, sprite, x, y, tid, facing="down", **kw):
        n = {"id": nid, "sprite": sprite, "x": x, "y": y, "facing": facing, "move": "still", "trainer": tid}
        n.update(kw)
        self.npcs.append(n)

    def prop(self, ptype, x, y, **kw):
        p = {"type": ptype, "x": x, "y": y}
        p.update(kw)
        self.props.append(p)

    def enc(self, kind, species, lo, hi, weight, **cond):
        e = {"species": species, "min": lo, "max": hi, "weight": weight}
        e.update(cond)
        self.encounters.setdefault(kind, []).append(e)

    def save(self):
        z = {"id": self.id, "name": self.name, "region": self.region, "kind": self.kind, "music": self.music,
             "weather": self.weather, "props": self.props, "warps": self.warps, "edges": self.edges, "npcs": self.npcs,
             "encounters": self.encounters, "signs": self.signs, "spawn": self.spawn, "stage": self.stage,
             "rows": ["".join(r) for r in self.g]}
        if self.scaled:
            z["scaled_floor"] = self.scaled
        if self.town:
            z["town_id"] = self.id
        z.update(self.extra)
        ZONES[self.id] = z
        return z


def interior(zid, name, w, h, parent, door_xy, props=None, npcs=None, signs=None, floor="|", music="",
             counters=None, rows_extra=None, encounters=None, scaled=None, extra=None, region=""):
    """A room: walls of x, a floor, a door bottom-centre warping back to `parent` at `door_xy` (the doorstep).

    counters: list of (x, y, w) runs of counter tiles. Returns (tx, ty): the spawn tile to warp into.
    """
    g = [["x"] * w for _ in range(h)]
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            g[y][x] = floor
    dx = w // 2
    g[h - 1][dx] = "D"
    for (cx, cy, cw) in counters or []:
        for i in range(cw):
            g[cy][cx + i] = "C"
    if rows_extra:
        rows_extra(g)
    z = {"id": zid, "name": name, "region": region, "kind": "interior", "music": music, "weather": {},
         "props": props or [], "warps": [{"x": dx, "y": h - 1, "to": parent, "tx": door_xy[0], "ty": door_xy[1], "facing": "down"}],
         "edges": {}, "npcs": npcs or [], "encounters": encounters or {}, "signs": signs or [],
         "spawn": [dx, h - 2], "rows": ["".join(r) for r in g]}
    if scaled:
        z["scaled_floor"] = scaled
    if extra:
        z.update(extra)
    ZONES[zid] = z
    return (dx, h - 2)


def inpc(nid, sprite, x, y, script_id=None, facing="down", name=None, **kw):
    n = {"id": nid, "sprite": sprite, "x": x, "y": y, "facing": facing, "move": "still"}
    if script_id:
        n["script"] = script_id
    if name:
        n["name"] = name
    n.update(kw)
    return n


def write_all():
    zdir = os.path.join(ROOT, "data", "zones")
    for zid, z in ZONES.items():
        with open(os.path.join(zdir, zid + ".json"), "w") as f:
            json.dump(z, f, indent=1, ensure_ascii=False)
    for zid, d in DIALOGUE.items():
        path = os.path.join(ROOT, "data", "dialogue", zid + ".json")
        with open(path, "w") as f:
            json.dump(d, f, indent=1, ensure_ascii=False)
    for tid, t in TRAINERS.items():
        with open(os.path.join(ROOT, "data", "trainers", tid + ".json"), "w") as f:
            json.dump(t, f, indent=1, ensure_ascii=False)
