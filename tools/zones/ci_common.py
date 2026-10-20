# Shared helpers for the Channel Islands zone scripts (channel_islands.py and the ci_*.py parts).
import os, sys
# zlib.py here is the zone-building helper; where the interpreter's own zlib is built in it would win the import, so load ours first
import importlib.util
_spec = importlib.util.spec_from_file_location("zlib", os.path.join(os.path.dirname(os.path.abspath(__file__)), "zlib.py"))
_mod = importlib.util.module_from_spec(_spec)
sys.modules["zlib"] = _mod
_spec.loader.exec_module(_mod)
from p6a_common import *
from wcommon import _stand
from zlib import landmark

REG = "channel_islands"
FLOOR = 40  # the band after the fourth badge (the Storm Stone): the gate to Poole, and the par the islands are written at
OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
SHOPS = {}  # shop id -> stock list, written by channel_islands.py


def plaque(z, x, y, pid, title, text):
    _stand(z, x, y)
    z.d["signs"].append({"x": x, "y": y, "plaque": "channel_islands_" + pid, "title": title, "text": text})


def scale(ids, floor=FLOOR):
    for t in ids:
        TRN[t]["scaled_floor"] = floor


def room(z, rid, bx, by, bw, bh, style, label, dx, kind, npcs, rw=13, rh=10, show_label=True):
    """a building on town zone z with a door dx tiles in, and its walk-in interior `rid` (a real place). npcs =
    [(id, sprite, x, y, facing, who, lines)]; lines None means the dialogue is written elsewhere (ci_story.py)."""
    door = z.building(bx, by, bw, bh, style, label, door=dx, show_label=show_label)
    zid = z.d["id"]
    z.warp(door[0], door[1], rid, rw // 2, rh - 3, "up")
    nd = []
    for (nid, sprite, x, y, facing, who, lines) in npcs:
        nd.append(dict(id=nid, sprite=sprite, x=x, y=y, facing=facing, move="still", script=nid, name=who))
        if lines:
            script(rid, nid, say(who, *lines))
    landmark(OUT, rid, label, zid, (door[0], door[1] + 1), kind, nd, w=rw, h=rh)
    return door


def put(zone, sid, cmds):
    DLG.setdefault(zone, {})[sid] = cmds


def sett(*flags):
    return [{"do": "set", "flag": f} for f in flags]


def iff(flag, then, other=None):
    return {"do": "if", "flag": flag, "then": then, "else": other or []}


def when(cond, then, other=None):
    return {"do": "when", "cond": cond, "then": then, "else": other or []}


def item(i, n=1):
    return {"do": "give_item", "item": i, "n": n}


NATION = os.environ.get("CI_NATION", "channel_islands")  # CI_NATION=england to validate before the nation lands


def standing(n, nation=None):
    return {"do": "standing", "nation": nation or NATION, "amount": n}


def s(who, *lines):
    return say(who, *lines)


def fingerpost(z, x, y, text):
    _stand(z, x, y)
    z.sign(x, y, text)


def grass_wild(z, rows, water=None):
    wild(z, rows)
    if water:
        wild(z, water, "water")


def pubquiz(room_id, nid, pub, warmup, region="england_south"):
    """a quizmaster's script: a line, then an optional five-question round about the islands (data/quiz/questions.json)."""
    put(room_id, nid, s("Quizmaster", warmup) + [
        {"do": "choice", "text": "Fancy a round? Five questions, no phones.", "options": ["Count me in", "Not tonight"], "set": "_quiz_choice"},
        {"do": "if", "flag": "_quiz_choice", "eq": 0, "then": [{"do": "quiz", "pub": pub, "region": region, "who": "Quizmaster"}],
         "else": s("Quizmaster", "Fair enough. The offer stands, and so does the bar.")}])


def seal(z, gaps=()):
    """close the map's 2-tile rim: anything walkable there (a road, the shallows) that is not in a gap becomes trees or sea,
    so a neighbour's edge only ever meets the gaps."""
    for y in range(z.h):
        for x in range(z.w):
            if not (x < 2 or y < 2 or x >= z.w - 2 or y >= z.h - 2):
                continue
            if any(gx <= x < gx + gw and gy <= y < gy + gh for (gx, gy, gw, gh) in gaps):
                continue
            c = z.g[y][x]
            if c in "w":
                z.g[y][x] = "$"
            elif c in ".,#=:sf_|k":
                z.g[y][x] = "T"
