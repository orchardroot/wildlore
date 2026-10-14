# Shared helpers for the Ireland (west) zone scripts.
from wcommon import *
from wcommon import _stand
import math


def hills(z, specs):
    """radial stepped hills: specs = [(cx, cy, peak, radius)]; steps of 1 so every slope is walkable."""
    for y in range(z.h):
        for x in range(z.w):
            v = max([0] + [max(0, pk - int(math.hypot(x - cx, y - cy) / (r / pk))) for (cx, cy, pk, r) in specs])
            z.hg[y][x] = max(z.hg[y][x], v)


def blob(z, cx, cy, rx, ry, ch, only=None, seed=0, jitter=0.0):
    r = random.Random(seed)
    for y in range(int(cy - ry - 1), int(cy + ry + 2)):
        for x in range(int(cx - rx - 1), int(cx + rx + 2)):
            if 0 <= x < z.w and 0 <= y < z.h:
                d = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
                if d <= 1.0 + (r.random() - 0.5) * jitter and (only is None or z.g[y][x] in only):
                    z.set(x, y, ch)


def creature(z, zid, sp, x, y, move="wander", line=None, who=None):
    _stand(z, x, y)
    z.npc(id="c_%s_%d_%d" % (sp, x, y), sprite="creature:" + sp, x=x, y=y, facing="down", move=move, script="c_" + sp)
    script(zid, "c_" + sp, say(who or sp.capitalize(), line or "It gives you a long, unhurried look and goes back to what it was doing."))


def stub(OUT, zid, name, edges):
    """minimal placeholder zone: edges = {side: (first_gap_index, neighbour)}; the real zone replaces it on merge."""
    z = Z(zid, name, 40, 40, kind="town", region="ireland", music="town_ireland")
    z.d["stage"] = "town"
    z.d["stub"] = True
    gaps = []
    for side, (a, to) in edges.items():
        gaps.append({"west": (0, a, 2, 3), "east": (38, a, 2, 3), "north": (a, 0, 3, 2), "south": (a, 38, 3, 2)}[side])
        z.d["edges"][side] = {"to": to, "offset": 0}
    z.border("T", 2, gaps=gaps)
    z.d["spawn"] = [20, 20]
    z.save(OUT + "/" + zid + ".json")


def finish(z):
    """drop point props that landed on an NPC or sign tile, and sign tiles on blocked tiles."""
    occ = {(n["x"], n["y"]) for n in z.d["npcs"]} | {(s["x"], s["y"]) for s in z.d["signs"]}
    z.d["props"] = [p for p in z.d["props"] if p["type"] == "building" or (p["x"], p["y"]) not in occ]
