"""Tiny helpers for authoring Wildlore zones as JSON (region agent R1, Pennines)."""
import json, os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
FLOOR = 14


def write_json(rel, data):
    path = os.path.join(ROOT, rel)
    with open(path, "w") as f:
        json.dump(data, f, indent=1, ensure_ascii=False)
        f.write("\n")


class Zone:
    def __init__(self, zid, name, w, h, fill=".", kind="route", region="yorkshire"):
        self.id, self.name, self.w, self.h = zid, name, w, h
        self.g = [[fill] * w for _ in range(h)]
        self.hts = [[0] * w for _ in range(h)]
        self.kind, self.region = kind, region
        self.props, self.warps, self.npcs, self.signs = [], [], [], []
        self.extra = {}

    def put(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.g[y][x] = c

    def get(self, x, y):
        return self.g[y][x]

    def rect(self, x, y, w, h, c):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                self.put(xx, yy, c)

    def height(self, x, y, w, h, v):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                if 0 <= xx < self.w and 0 <= yy < self.h:
                    self.hts[yy][xx] = v

    def border(self, c, thick=2):
        for y in range(self.h):
            for x in range(self.w):
                if x < thick or y < thick or x >= self.w - thick or y >= self.h - thick:
                    self.g[y][x] = c

    def prop(self, t, x, y, **kw):
        d = {"type": t, "x": x, "y": y}
        d.update(kw)
        self.props.append(d)
        return d

    def building(self, x, y, w, h, style, label=None, kind=None, door=None, to=None, tx=None, ty=None, show_label=True):
        """door: absolute x of the door on the bottom row (None = no door). to: interior zone id."""
        self.rect(x, y, w, h, "B")
        d = {"type": "building", "style": style, "x": x, "y": y, "w": w, "h": h}
        if label:
            d["label"] = label
        if kind:
            d["kind"] = kind
        if not show_label or not label:
            d["show_label"] = False
            d.pop("label", None) if not label else None
        self.props.append(d)
        if door is not None:
            self.put(door, y + h - 1, "D")
            if to:
                self.warps.append({"x": door, "y": y + h - 1, "to": to, "tx": tx, "ty": ty, "facing": "up"})
        return d

    def npc(self, nid, sprite, x, y, facing="down", move="still", script=None, trainer=None, name=None, **kw):
        d = {"id": nid, "sprite": sprite, "x": x, "y": y, "facing": facing, "move": move}
        if script:
            d["script"] = script
        if trainer:
            d["trainer"] = trainer
        if name:
            d["name"] = name
        d.update(kw)
        self.npcs.append(d)
        return d

    def sign(self, x, y, text, plaque=None, title=None, **kw):
        d = {"x": x, "y": y, "text": text}
        if plaque:
            d["plaque"] = plaque
            d["title"] = title
        d.update(kw)
        self.signs.append(d)
        return d

    def to_dict(self, **extra):
        d = {"id": self.id, "name": self.name, "region": self.region, "kind": self.kind}
        d.update(extra)
        d["props"] = self.props
        d["warps"] = self.warps
        d["npcs"] = self.npcs
        d["signs"] = self.signs
        d["rows"] = ["".join(r) for r in self.g]
        if any(any(v for v in r) for r in self.hts):
            d["heights"] = ["".join(str(v) for v in r) for r in self.hts]
        if self.extra:
            d["legend_extra"] = self.extra
        return d


def interior(zid, name, w, h, door_x, back, bx, by, props=(), npcs=(), signs=(), floor="|", counters=(),
             music="", dark=False, extra_warps=(), rows_override=None):
    """A room w x h including the 'x' walls; door on row h-2 at door_x, back to (bx, by) outside."""
    g = [["x"] * w for _ in range(h)]
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            g[y][x] = floor
    for (x, y) in counters:
        g[y][x] = "C"
    g[h - 2][door_x] = "D"
    if rows_override:
        g = [list(r) for r in rows_override]
    warps = [{"x": door_x, "y": h - 2, "to": back, "tx": bx, "ty": by, "facing": "down"}]
    warps += list(extra_warps)
    d = {"id": zid, "name": name, "region": "", "kind": "interior", "music": music, "weather": {},
         "props": list(props), "warps": warps, "edges": {}, "npcs": list(npcs), "encounters": {},
         "signs": list(signs), "spawn": [door_x, h - 3], "rows": ["".join(r) for r in g]}
    if dark:
        d["dark"] = True
    return d


def P(t, x, y, **kw):
    d = {"type": t, "x": x, "y": y}
    d.update(kw)
    return d


def N(nid, sprite, x, y, script=None, trainer=None, name=None, facing="down", move="still", **kw):
    d = {"id": nid, "sprite": sprite, "x": x, "y": y, "facing": facing, "move": move}
    if script:
        d["script"] = script
    if trainer:
        d["trainer"] = trainer
    if name:
        d["name"] = name
    d.update(kw)
    return d


def say(who, text):
    return {"do": "say", "who": who, "text": text}


def chat(who, *lines):
    return [say(who, t) for t in lines]


def trainer(tid, name, cls, sprite, party, intro, win, after, money=None, **kw):
    lv = max(int(m[1]) for m in party)
    d = {"id": tid, "name": name, "class": cls, "sprite": sprite,
         "party": [dict({"species": m[0], "level": m[1]}, **(m[2] if len(m) > 2 else {})) for m in party],
         "ai": "trainer", "money": money if money is not None else lv * 30, "scaled_floor": FLOOR,
         "intro": [say(name, t) for t in ([intro] if isinstance(intro, str) else intro)],
         "win": win, "after": after}
    d.update(kw)
    write_json("data/trainers/%s.json" % tid, d)
    return d
