# Shared helpers for the 3.3 "Overseas" zone scripts (RAF Brize Norton, Gibraltar, Akrotiri and Dhekelia).
import sys, os, math, random, json, importlib.util
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
# tools/zones/zlib.py is our own helper module; Python builds where the stdlib zlib is built in would shadow it
_spec = importlib.util.spec_from_file_location("zlib", os.path.join(os.path.dirname(os.path.abspath(__file__)), "zlib.py"))
_zl = importlib.util.module_from_spec(_spec)
sys.modules["zlib"] = _zl
_spec.loader.exec_module(_zl)
from p6a_common import *
from wcommon import _stand
from zlib import landmark

FLOOR = 95  # post-game: every overseas zone and trainer is authored for par 95 and lifts with the story
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "data", "zones")


def plaque(z, x, y, territory, pid, title, text):
    _stand(z, x, y)
    z.d["signs"].append({"x": x, "y": y, "plaque": territory + "_" + pid, "title": title, "text": text})


def blocked_ok(z, x, y, w, h):
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            assert 0 <= xx < z.w and 0 <= yy < z.h, "%s: building off the map at %d,%d" % (z.d["id"], xx, yy)
            assert z.g[yy][xx] not in "B~", "%s: building overlap at %d,%d" % (z.d["id"], xx, yy)


def bld(z, x, y, w, h, style, label=None, door=None, to=None, iw=13, ih=10, show_label=True):
    """a building; with `door` and `to`, a warp into interior `to` (arrive above its exit). Returns the tile below the door."""
    blocked_ok(z, x, y, w, h)
    z.building(x, y, w, h, style, label, door=door, show_label=show_label)
    if door is not None and to:
        z.warp(x + door, y + h - 1, to, iw // 2, ih - 3, "up")
        return (x + door, y + h)
    return None


def fringe(z, land=".,#:=fsg"):
    """shallow tiles where open water meets land."""
    marks = []
    for y in range(z.h):
        for x in range(z.w):
            if z.g[y][x] != "~":
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                xx, yy = x + dx, y + dy
                if 0 <= xx < z.w and 0 <= yy < z.h and z.g[yy][xx] in land:
                    marks.append((x, y))
                    break
    for (x, y) in marks:
        z.set(x, y, "w")


def reach_check(z, extra=(), walk=".,#=:sfw_Dbgk+|lmncaLM"):
    """BFS from the spawn: every warp door, NPC and sign must be reachable (or have a reachable neighbour)."""
    walk = set(walk)
    blockers = {(p["x"], p["y"]) for p in z.d["props"] if p["type"] != "building" and not p.get("walk")}
    start = tuple(z.d["spawn"])
    seen = {start}
    q = [start]
    while q:
        x, y = q.pop()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < z.w and 0 <= ny < z.h and (nx, ny) not in seen and z.g[ny][nx] in walk and (nx, ny) not in blockers:
                seen.add((nx, ny))
                q.append((nx, ny))
    bad = []
    targets = [(w_["x"], w_["y"]) for w_ in z.d["warps"]] + [(n["x"], n["y"]) for n in z.d["npcs"]] + [(s["x"], s["y"]) for s in z.d["signs"]] + list(extra)
    for (x, y) in targets:
        if (x, y) in seen:
            continue
        if not any((x + dx, y + dy) in seen for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
            bad.append((x, y))
    assert not bad, "%s: unreachable %s" % (z.d["id"], bad)
    return seen


def say1(who, *lines):
    return [{"do": "say", "who": who, "text": t} for t in lines]


def sett(*flags):
    return [{"do": "set", "flag": f} for f in flags]


def iff(flag, then, other=None):
    return {"do": "if", "flag": flag, "then": then, "else": other or []}


def item(i, n=1):
    return {"do": "give_item", "item": i, "n": n}


def standing(n, nation="overseas"):
    return {"do": "standing", "nation": nation, "amount": n}


def plain_trainer(tid, name, cls, sprite, party, intro, win, money):
    """a trainer who only fights inside a script (a gauntlet or a battle command), with no NPC of their own."""
    TRN[tid] = {"id": tid, "name": name, "class": cls, "sprite": sprite,
                "party": [{"species": sp, "level": lv} for sp, lv in party], "ai": "trainer", "money": money,
                "intro": say(name, *intro), "win": win, "after": win}


def scale_all(ids):
    for t in ids:
        TRN[t]["scaled_floor"] = FLOOR


def drywall(z, x0, y0, x1, y1, ch="W", gaps=(), only=".,gk"):
    if y0 == y1:
        for x in range(x0, x1 + 1):
            if x not in gaps and z.g[y0][x] in only:
                z.set(x, y0, ch)
    else:
        for y in range(y0, y1 + 1):
            if y not in gaps and z.g[y][x0] in only:
                z.set(x0, y, ch)


def sprinkle(z, ch, n, seed, x0=0, y0=0, x1=None, y1=None, only="."):
    r = random.Random(seed)
    x1 = z.w if x1 is None else x1
    y1 = z.h if y1 is None else y1
    tries = 0
    done_ = 0
    while done_ < n and tries < n * 30:
        tries += 1
        x, y = r.randrange(x0, x1), r.randrange(y0, y1)
        if z.g[y][x] in only:
            z.g[y][x] = ch
            done_ += 1


def write_dialogue_and_trainers():
    root = ROOT
    os.makedirs(os.path.join(root, "data", "dialogue"), exist_ok=True)
    os.makedirs(os.path.join(root, "data", "trainers"), exist_ok=True)
    for zid, d in DLG.items():
        json.dump(d, open(os.path.join(root, "data", "dialogue", zid + ".json"), "w"), indent=1, ensure_ascii=False)
    for tid, t in TRN.items():
        json.dump(t, open(os.path.join(root, "data", "trainers", tid + ".json"), "w"), indent=1, ensure_ascii=False)
