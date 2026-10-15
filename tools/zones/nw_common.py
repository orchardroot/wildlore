# Shared helpers for plan 6 group B (Dales, Lancaster, Lakes, Keswick, Sheffield, Sherwood, Nottingham).
from sc_common import *
from sc_common import _stand

WX_NORTH = {"drizzle": 34, "clear": 20, "downpour": 14, "fog": 10, "gale": 6, "sunshine": 16}
WX_FELL = {"fog": 28, "drizzle": 28, "downpour": 14, "clear": 14, "gale": 8, "frost": 4, "sunshine": 4}
WX_MID = {"clear": 30, "drizzle": 28, "sunshine": 20, "fog": 8, "downpour": 10, "gale": 4}


def put(z, x, y, ch):
    if 0 <= x < z.w and 0 <= y < z.h:
        z.g[y][x] = ch


def hill(z, x, y, w, h, peak):
    """flat plateau at `peak` with concentric one-level rings falling to 0 (every step is 1, so it walks)."""
    for r in range(peak, -1, -1):
        lv = peak - r
        for yy in range(max(0, y - r), min(z.h, y + h + r)):
            for xx in range(max(0, x - r), min(z.w, x + w + r)):
                z.hg[yy][xx] = max(z.hg[yy][xx], lv)


def wall_h(z, y, x0, x1, gaps=(), ch="W"):
    for x in range(x0, x1 + 1):
        if x not in gaps and z.g[y][x] in ".,b":
            z.g[y][x] = ch


def wall_v(z, x, y0, y1, gaps=(), ch="W"):
    for y in range(y0, y1 + 1):
        if y not in gaps and z.g[y][x] in ".,b":
            z.g[y][x] = ch


def forest(z, x, y, w, h, n, seed, ch="T"):
    r = random.Random(seed)
    for _ in range(n):
        xx, yy = r.randrange(x, x + w), r.randrange(y, y + h)
        if z.g[yy][xx] == ".":
            z.g[yy][xx] = ch


def sheep(z, nid, x, y, species="herdwick", text=None, move="wander"):
    _stand(z, x, y)
    z.npc(id=nid, sprite="creature:" + species, x=x, y=y, facing="down", move=move, script="sheep_" + species)
    script(z.d["id"], "sheep_" + species, say(species.capitalize(), text or "It looks at you as if you have asked a deeply rude question, then goes back to the grass."))


def tidy(z):
    """no prop may sit on a sign, a warp, an NPC, a path, a road or a platform tile."""
    spots = {(s["x"], s["y"]) for s in z.d["signs"]} | {(w["x"], w["y"]) for w in z.d["warps"]} | {(n["x"], n["y"]) for n in z.d["npcs"]}
    for s in z.d["signs"]:
        if z.g[s["y"]][s["x"]] in "TPRHFWB^":
            z.g[s["y"]][s["x"]] = "."
    z.d["props"] = [p for p in z.d["props"] if p["type"] == "building" or
                    ((p["x"], p["y"]) not in spots and z.g[p["y"]][p["x"]] not in "#=_!")]
