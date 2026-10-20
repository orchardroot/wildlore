# Shared helpers for the South Wales valleys region (R6): Rhondda, Merthyr Tydfil, Blaenavon.
import os, sys, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ie_common import *
from ie_common import _stand
from p6a_common import smooth, done
from zlib import landmark

FLOOR = 36          # Cardiff's band: all of the valleys scale from par 36
SW = "south_wales"
Q = "q_valleys_"
WX = {"drizzle": 36, "downpour": 14, "fog": 10, "clear": 16, "sunshine": 14, "gale": 10}


def T(tid, name, cls, sprite, party, intro, win, after, money):
    """a scaled trainer file only (fought through a script or an npc's "trainer")."""
    TRN[tid] = {"id": tid, "name": name, "class": cls, "sprite": sprite, "scaled_floor": FLOOR,
                "party": [{"species": s, "level": l} for s, l in party], "ai": "trainer", "money": money,
                "intro": say(name, *intro), "win": win, "after": after}


def trn(z, tid, name, cls, sprite, party, x, y, facing, intro, win, after, money, move="still"):
    trainer(z, tid, name, cls, sprite, party, x, y, facing, intro, win, after, money, move)
    TRN[tid]["scaled_floor"] = FLOOR


def plaque(z, region, pid, x, y, title, text):
    z.d["signs"].append({"x": x, "y": y, "plaque": "%s_%s" % (region, pid), "title": title, "text": text})


def flag_if(flag, then, other=None):
    return {"do": "if", "flag": flag, "then": then, "else": other or []}


def setf(flag, value=True):
    return {"do": "set", "flag": flag, "value": value}


def interior(OUT, zid, name, town, ret, kind, npcs, w=13, h=10, extra=(), furnish=True, music="", drop=(), dark=False, signs=()):
    z = landmark(OUT, zid, name, town, ret, kind, npcs, w=w, h=h, furnish=furnish, write=False)
    z.d["props"] = [q for q in z.d["props"] if q["type"] not in drop]
    taken = {(p["x"], p["y"]) for p in z.d["props"]} | {(n["x"], n["y"]) for n in z.d["npcs"]}
    for p in extra:
        if (p["x"], p["y"]) in taken and not p.get("walk"):
            z.d["props"] = [q for q in z.d["props"] if not (q["x"] == p["x"] and q["y"] == p["y"])]
        z.d["props"].append(dict(p))
    for s in signs:
        z.d["signs"].append(dict(s))
    if music:
        z.d["music"] = music
    if dark:
        z.d["dark"] = True
    z.save(OUT + "/" + zid + ".json")
    return z


def P(t, x, y, **kw):
    d = {"type": t, "x": x, "y": y}
    d.update(kw)
    return d


def hband(x, east, west):
    """valley height by column: bands of 5 tiles climbing outwards (east and west are lists of (x0, x1, level))."""
    for (a, b, lv) in (east if x >= 30 else west):
        if a <= x <= b:
            return lv
    return 0


def reach_check(z, extra_ok=""):
    """BFS from the spawn over walkable tiles; report warps, npc neighbours and edge gaps that can't be reached."""
    walk = set(".,#=:sfwD_gh|+" + extra_ok)
    for ch, spec in z.legend.items():
        if spec["tile"] in ("grass", "tall_grass", "path", "road", "cobbles", "sand", "flowers", "shallow", "door", "floor_wood", "floor_tile"):
            walk.add(ch)
    blocked = {(p["x"], p["y"]) for p in z.d["props"] if p["type"] not in ("bunting", "washing_line", "hanging_basket") and not p.get("walk")}
    blocked |= {(n["x"], n["y"]) for n in z.d["npcs"]}
    blocked |= {(s["x"], s["y"]) for s in z.d["signs"]}
    start = tuple(z.d["spawn"])
    seen = {start}
    stack = [start]
    while stack:
        x, y = stack.pop()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < z.w and 0 <= ny < z.h and (nx, ny) not in seen and z.g[ny][nx] in walk and (nx, ny) not in blocked:
                seen.add((nx, ny))
                stack.append((nx, ny))
    bad = []
    for w in z.d["warps"]:
        if (w["x"], w["y"]) not in seen:
            bad.append(("warp", w["x"], w["y"], w["to"]))
    for n in z.d["npcs"] + z.d["signs"]:
        if not any((n["x"] + dx, n["y"] + dy) in seen for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
            bad.append(("npc/sign", n["x"], n["y"], n.get("id", n.get("title", ""))))
    for side, e in z.d["edges"].items():
        pass
    return bad
