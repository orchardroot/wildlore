# Helpers shared by the Wales zone scripts: dialogue and trainer writers, hill shaping, prop sprinkling.
import json, math, os, random
from zlib import Z

_orig_building = Z.building
_orig_save = Z.save


def _building(self, *a, **k):
    r = _orig_building(self, *a, **k)
    if r:
        self.__dict__.setdefault("_doors", []).append(r)
    return r


def _save(self, path):
    # paths drawn after buildings must not eat the footprint or the door
    for p in self.d["props"]:
        if p["type"] == "building":
            for yy in range(p["y"], p["y"] + p["h"]):
                for xx in range(p["x"], p["x"] + p["w"]):
                    if self.g[yy][xx] not in "BD":
                        self.g[yy][xx] = "B"
    for (x, y) in self.__dict__.get("_doors", []):
        self.g[y][x] = "D"
    # nothing blocks an NPC, a sign or a warp: drop props and clear trees/rock under them
    occ = {(n["x"], n["y"]) for n in self.d["npcs"]} | {(w["x"], w["y"]) for w in self.d["warps"]}
    self.d["props"] = [p for p in self.d["props"] if p["type"] == "building" or (p["x"], p["y"]) not in occ]
    for (x, y) in occ:
        if self.g[y][x] in "TPRH^":
            self.g[y][x] = "."
    _orig_save(self, path)


Z.building = _building
Z.save = _save

DLG = {}   # zone id -> {script id: [commands]}
TRN = {}   # trainer id -> dict


def say(who, *lines):
    return [{"do": "say", "who": who, "text": t} for t in lines]


def talk(zone, sid, who, *lines):
    DLG.setdefault(zone, {})[sid] = say(who, *lines)


def chat(z, nid, sprite, x, y, who, lines, facing="down", move="still"):
    z.npc(id=nid, sprite=sprite, x=x, y=y, facing=facing, move=move, script=nid, name=who)
    talk(z.d["id"], nid, who, *lines)


def trainer(z, tid, name, cls, sprite, x, y, facing, party, intro, win, after, money=None):
    lv = max(l for _, l in party)
    TRN[tid] = {"id": tid, "name": name, "class": cls, "sprite": sprite,
                "party": [{"species": s, "level": l} for s, l in party], "ai": "trainer",
                "money": money or lv * 14,
                "intro": say(name, *intro), "win": win, "after": after}
    z.npc(id=tid, sprite=sprite, x=x, y=y, facing=facing, move="still", trainer=tid)


def pth(z, pts, ch="#", w=1):
    """Draw straight (axis-aligned) segments through waypoints, w tiles wide."""
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        xa, xb = sorted((x0, x1))
        ya, yb = sorted((y0, y1))
        z.rect(xa, ya, xb - xa + w, yb - ya + w, ch)


def cones(z, cs, box=None):
    """Raise heights with cones (cx, cy, peak, step, r0). Neighbouring tiles never differ by more than one level."""
    bx, by, bw, bh = box or (0, 0, z.w, z.h)
    for y in range(by, by + bh):
        for x in range(bx, bx + bw):
            h = z.hg[y][x]
            for (cx, cy, peak, step, r0) in cs:
                d = max(0.0, math.hypot(x - cx, y - cy) - r0)
                h = max(h, round(peak - d / step))
            z.hg[y][x] = max(0, min(6, h))


def taken(z):
    t = set()
    for p in z.d["props"]:
        if p["type"] != "building":
            t.add((p["x"], p["y"]))
    for s in z.d["signs"]:
        t.add((s["x"], s["y"]))
    for n in z.d["npcs"]:
        t.add((n["x"], n["y"]))
    for w in z.d["warps"]:
        t.add((w["x"], w["y"]))
    return t


def sprinkle(z, kinds, x, y, w, h, n, seed, on="."):
    """Scatter point props (type or (type, variant)) over tiles whose char is in `on`."""
    r = random.Random(seed)
    t = taken(z)
    done = tries = 0
    while done < n and tries < n * 40:
        tries += 1
        xx, yy = r.randrange(x, x + w), r.randrange(y, y + h)
        if not (0 <= xx < z.w and 0 <= yy < z.h):
            continue
        if z.g[yy][xx] not in on or (xx, yy) in t:
            continue
        k = r.choice(kinds)
        typ, var = k if isinstance(k, tuple) else (k, r.randrange(3))
        z.prop(typ, xx, yy, variant=var)
        t.add((xx, yy))
        done += 1


def write_all(out):
    root = os.path.join(out, "..")
    os.makedirs(os.path.join(root, "dialogue"), exist_ok=True)
    os.makedirs(os.path.join(root, "trainers"), exist_ok=True)
    for zone, d in DLG.items():
        json.dump(d, open(os.path.join(root, "dialogue", zone + ".json"), "w"), indent=1)
    for tid, d in TRN.items():
        json.dump(d, open(os.path.join(root, "trainers", tid + ".json"), "w"), indent=1)


def town_interiors(out, town, name, ret_s, ret_shop, nurse_lines, shop_lines):
    """Sanctuary and Corner Shop interiors plus their dialogue (nurse_lines: welcome, heal-intro, done, ark, none)."""
    from zlib import sanctuary, shop
    sanctuary(out, town, name, ret_s)
    shop(out, town, name, ret_shop)
    w, h, d, a, n = nurse_lines
    nurse = [
        {"do": "say", "who": "Nurse", "text": w},
        {"do": "choice", "text": "What can we do for you?", "options": ["Heal my team", "Open the Ark", "Just looking"], "set": "_nurse_choice"},
        {"do": "if", "flag": "_nurse_choice", "eq": 0, "then": [
            {"do": "say", "who": "Nurse", "text": h}, {"do": "heal"}, {"do": "say", "who": "Nurse", "text": d}],
         "else": [{"do": "if", "flag": "_nurse_choice", "eq": 1, "then": [
             {"do": "say", "who": "Nurse", "text": a}, {"do": "ark"}],
             "else": [{"do": "say", "who": "Nurse", "text": n}]}]}]
    DLG[town + "_sanctuary"] = {"nurse": nurse}
    s1, s2 = shop_lines
    DLG[town + "_shop"] = {"shopkeeper": [{"do": "say", "who": "Shopkeeper", "text": s1},
                                          {"do": "shop", "id": town + "_corner_shop"},
                                          {"do": "say", "who": "Shopkeeper", "text": s2}]}
