#!/usr/bin/env python3
"""Wildlore 1.5 foraging: places 3 to 6 `forage` props beside the paths of every route (kind "route", not the dev
testbed). They stand on soft ground next to a path, never on the path itself, never in a one-tile gap or anywhere
that would cut a way off, and well away from doors, edges, NPCs and trainers' lines of sight.

Variants follow the region and the ground round about: coast gets seaweed, Wales slate, moors heather, woods
mushrooms, hazel and wild garlic, hedgerows bramble and blackthorn. Safe to re-run (it replaces its own props).

    python3 tools/zones/forage.py            # every route
    python3 tools/zones/forage.py skye goyt_valley
"""
import json
import os
import random
import sys
from collections import deque

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
ZONES = os.path.join(ROOT, "data", "zones")

LEGEND = {
    ".": "grass", ",": "tall_grass", "#": "path", "=": "road", ":": "cobbles", "s": "sand", "f": "flowers", "~": "water",
    "w": "shallow", "T": "tree_oak", "P": "tree_pine", "H": "hedge", "W": "drystone_wall", "F": "fence", "R": "rock",
    "^": "cliff", "B": "building", "D": "door", "x": "void", "|": "floor_wood", "+": "floor_tile", "C": "counter",
    "L": "ledge_south", "%": "bramble", "o": "deep_water", "/": "scree", "_": "platform", "!": "rail", "$": "sea",
    "*": "bog", "&": "level_crossing",
}
WALKABLE = {"grass", "tall_grass", "path", "road", "cobbles", "sand", "flowers", "shallow", "door", "floor_wood",
            "floor_tile", "platform", "level_crossing"}
PATHS = {"path", "road", "cobbles"}
SOFT = {"grass", "flowers", "sand"}
WET = {"sea", "water", "shallow", "deep_water", "sand"}
WOOD = {"tree_oak", "tree_pine"}
STEPS = ((1, 0), (-1, 0), (0, 1), (0, -1))
GAP_DETOUR = 3
MIN_APART = 6


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


class Grid:
    def __init__(self, z):
        self.z = z
        self.rows = z["rows"]
        self.h = len(self.rows)
        self.w = max(len(r) for r in self.rows) if self.rows else 0
        legend = z.get("legend_extra", {})
        self.tiles = [[(legend[c]["tile"] if c in legend else LEGEND.get(c, "void")) for c in row] for row in self.rows]
        hs = z.get("heights", [])
        g = int(z.get("ground_height", 0))
        self.hgt = [[(int(hs[y][x]) if y < len(hs) and x < len(hs[y]) and hs[y][x].isdigit() else g) for x in range(self.w)] for y in range(self.h)]
        self.blocked = {(int(p["x"]), int(p["y"])) for p in z.get("props", []) if p.get("type") != "building" and not p.get("walk")}
        self.blocked |= {(int(s["x"]), int(s["y"])) for s in z.get("signs", [])}

    def tile(self, p):
        x, y = p
        return self.tiles[y][x] if 0 <= x < self.w and 0 <= y < self.h else ""

    def walk(self, p, frm=None, extra=()):
        if self.tile(p) not in WALKABLE or p in self.blocked or p in extra:
            return False
        if frm is not None and abs(self.hgt[frm[1]][frm[0]] - self.hgt[p[1]][p[0]]) > 1:
            return False
        return True

    def reach(self, start, extra=()):
        seen = {start}
        q = deque([start])
        while q:
            p = q.popleft()
            for dx, dy in STEPS:
                n = (p[0] + dx, p[1] + dy)
                if n in seen:
                    continue
                if self.tile(n) == "ledge_south" and (dx, dy) == (0, 1):
                    land = (n[0], n[1] + 1)
                    if land not in seen and self.walk(land, None, extra):
                        seen.add(land)
                        q.append(land)
                    continue
                if self.walk(n, p, extra):
                    seen.add(n)
                    q.append(n)
        return seen

    def gap(self, t):
        """Blocking t would split its neighbours (no way round within GAP_DETOUR tiles)."""
        ways = [(t[0] + dx, t[1] + dy) for dx, dy in STEPS if self.walk((t[0] + dx, t[1] + dy), t)]
        if len(ways) < 2:
            return False
        seen = {ways[0]}
        q = deque([ways[0]])
        while q:
            p = q.popleft()
            for dx, dy in STEPS:
                n = (p[0] + dx, p[1] + dy)
                if n == t or n in seen or max(abs(n[0] - t[0]), abs(n[1] - t[1])) > GAP_DETOUR or not self.walk(n, p):
                    continue
                seen.add(n)
                q.append(n)
        return any(w not in seen for w in ways)

    def near(self, p, kinds, r):
        for y in range(p[1] - r, p[1] + r + 1):
            for x in range(p[0] - r, p[0] + r + 1):
                if self.tile((x, y)) in kinds:
                    return True
        return False


def keep_clear(z, g):
    """Tiles forage must stay off: doorsteps, NPCs and their beats, trainers' sight lines, ledge landings."""
    out = set()
    for w in z.get("warps", []):
        for dy in range(-2, 3):
            for dx in range(-2, 3):
                out.add((int(w["x"]) + dx, int(w["y"]) + dy))
    for n in z.get("npcs", []):
        hx, hy = int(n["x"]), int(n["y"])
        r = 1
        if n.get("move", "still") == "wander":
            r = int(n.get("radius", 2)) + 2
        for dy in range(-r, r + 1):
            for dx in range(-r, r + 1):
                out.add((hx + dx, hy + dy))
        if n.get("move") == "pace":
            px, py = hx, hy
            for d in n.get("path", []):
                px += {"left": -1, "right": 1}.get(d, 0)
                py += {"up": -1, "down": 1}.get(d, 0)
                for dy in range(-2, 3):
                    for dx in range(-2, 3):
                        out.add((px + dx, py + dy))
        if n.get("trainer"):
            for k in range(-7, 8):
                out.add((hx + k, hy))
                out.add((hx, hy + k))
    for key in ("station", "ferry"):
        s = z.get(key) or {}
        if "x" in s:
            for dy in range(-2, 3):
                for dx in range(-2, 3):
                    out.add((int(s["x"]) + dx, int(s["y"]) + dy))
    sp = z.get("spawn", [0, 0])
    for dy in range(-2, 3):
        for dx in range(-2, 3):
            out.add((int(sp[0]) + dx, int(sp[1]) + dy))
    for y in range(g.h):
        for x in range(g.w):
            if g.tile((x, y)) == "ledge_south":
                out.add((x, y + 1))
    return out


def palette(z):
    """What grows here by default (before the ground round each spot has its say)."""
    region = z.get("region", "")
    stage = z.get("stage", "")
    if stage == "forest":
        pal = ["mushroom_ring", "hazel", "wild_garlic", "bramble"]
    elif stage == "moor":
        pal = ["heather", "blackthorn", "heather", "bramble"]
    elif stage == "mountain":
        pal = ["heather", "blackthorn", "elder"]
    elif stage == "bog":
        pal = ["nettle_patch", "heather", "elder"]
    elif stage == "quarry":
        pal = ["slate_heap", "heather", "nettle_patch"]
    else:
        pal = ["bramble", "blackthorn", "elder", "nettle_patch"]
    if region.endswith("wales"):
        pal = ["slate_heap"] + pal
    if region.startswith("ireland"):
        pal = pal + ["wild_garlic", "hazel"]
    if region == "scotland" and "heather" not in pal:
        pal = ["heather"] + pal
    if region in ("peak", "yorkshire", "north_east") and stage in ("moor", "mountain", ""):
        pal = ["heather"] + pal
    return pal


def variant_for(z, g, p, pal, i):
    coastal = z.get("stage") == "coast" or g.near(p, {"sea"}, 6)
    if coastal and g.near(p, WET - {"water", "deep_water"}, 2):
        return "seaweed"
    if g.near(p, WOOD, 1) and i % 2 == 0:
        return ["hazel", "mushroom_ring", "wild_garlic"][i // 2 % 3]
    if g.near(p, {"hedge"}, 1):
        return ["bramble", "blackthorn"][i % 2]
    if z.get("region", "").endswith("wales") and g.near(p, {"drystone_wall", "rock", "scree", "cliff"}, 2):
        return "slate_heap"
    return pal[i % len(pal)]


def place(z, rng):
    g = Grid(z)
    z["props"] = [p for p in z.get("props", []) if p.get("type") != "forage"]
    g.blocked = {(int(p["x"]), int(p["y"])) for p in z["props"] if p.get("type") != "building" and not p.get("walk")}
    g.blocked |= {(int(s["x"]), int(s["y"])) for s in z.get("signs", [])}
    spawn = tuple(int(v) for v in z.get("spawn", [0, 0]))
    clear = keep_clear(z, g)
    want = max(3, min(6, (g.w * g.h) // 700 + 2))
    base = g.reach(spawn)
    chosen = []
    # right beside a path first; a small zone with little path may reach a step or two further out
    for path_dist, apart in ((1, MIN_APART), (2, 5), (4, 4)):
        if len(chosen) >= want:
            break
        cands = []
        for y in range(2, g.h - 2):
            for x in range(2, g.w - 2):
                p = (x, y)
                if g.tile(p) not in SOFT or p in g.blocked or p in clear or g.gap(p):
                    continue
                if path_dist == 1 and not any(g.tile((x + dx, y + dy)) in PATHS for dx, dy in STEPS):
                    continue
                if path_dist > 1 and not g.near(p, PATHS, path_dist):
                    continue
                cands.append(p)
        rng.shuffle(cands)
        chosen = _pick(g, spawn, base, cands, chosen, want, apart)
    pal = palette(z)
    for i, p in enumerate(sorted(chosen, key=lambda q: (q[1], q[0]))):
        z["props"].append({"type": "forage", "variant": variant_for(z, g, p, pal, i), "x": p[0], "y": p[1]})
    return chosen


def _pick(g, spawn, base, cands, chosen, want, apart):
    for p in cands:
        if len(chosen) >= want:
            break
        if p in chosen or p not in base or any(abs(p[0] - q[0]) + abs(p[1] - q[1]) < apart for q in chosen):
            continue
        extra = set(chosen) | {p}
        if g.reach(spawn, extra) != base - extra:
            continue  # it would cut something off
        if any(g.gap(q) for q in chosen):
            continue
        g.blocked.add(p)
        if any(g.gap(q) for q in base if abs(q[0] - p[0]) <= 1 and abs(q[1] - p[1]) <= 1 and q != p and g.walk(q)):
            g.blocked.discard(p)
            continue  # it would make a neighbour a one-tile gap
        chosen.append(p)
    return chosen


def main():
    only = set(sys.argv[1:])
    total = 0
    for f in sorted(os.listdir(ZONES)):
        if not f.endswith(".json"):
            continue
        path = os.path.join(ZONES, f)
        z = load(path)
        if z.get("kind", "route") != "route" or z.get("region") == "dev" or z.get("stub"):
            continue
        if only and z["id"] not in only:
            continue
        rng = random.Random("forage:" + z["id"])
        chosen = place(z, rng)
        total += len(chosen)
        with open(path, "w", encoding="utf-8") as out:
            json.dump(z, out, indent=1, ensure_ascii=False)
        vs = [p["variant"] for p in z["props"] if p.get("type") == "forage"]
        print("%-22s %d  %s" % (z["id"], len(chosen), ", ".join(vs)))
    print("forage props:", total)


if __name__ == "__main__":
    main()
