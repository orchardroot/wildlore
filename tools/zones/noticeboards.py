#!/usr/bin/env python3
"""Wildlore 2.0 parish noticeboards: puts one `noticeboard` prop near the middle of every town (kind "town", not the
dev gallery). The board faces south, so it wants its back to something (a building, hedge, wall or fence) and open
ground in front where you stand to read it. It never goes on a doorstep, a path pinch, an NPC's beat or the spawn,
and never cuts anywhere off. Appends to the zone's props and keeps the file's own JSON style. Safe to re-run (it
replaces its own prop).

    python3 tools/zones/noticeboards.py            # every town
    python3 tools/zones/noticeboards.py york bath
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from forage import Grid, keep_clear, STEPS, ZONES  # noqa: E402

STAND = {"path", "road", "cobbles", "grass", "flowers"}   # what the board itself may stand on
FRONT = {"path", "road", "cobbles", "grass", "flowers"}   # where you stand to read it
BACKING = {"building", "hedge", "drystone_wall", "fence", "tree_oak", "tree_pine", "rock", "void"}


def place(z):
    g = Grid(z)
    z["props"] = [p for p in z.get("props", []) if p.get("type") != "noticeboard"]
    g.blocked = {(int(p["x"]), int(p["y"])) for p in z["props"] if p.get("type") != "building" and not p.get("walk")}
    g.blocked |= {(int(s["x"]), int(s["y"])) for s in z.get("signs", [])}
    spawn = tuple(int(v) for v in z.get("spawn", [0, 0]))
    base = g.reach(spawn)
    if not base:
        return None
    clear = keep_clear(z, g)
    doors = [(int(w["x"]), int(w["y"])) for w in z.get("warps", [])]
    cx = sum(p[0] for p in base) / len(base)
    cy = sum(p[1] for p in base) / len(base)
    cands = []
    for p in base:
        x, y = p
        if g.tile(p) not in STAND or p in clear or p in doors or g.gap(p):
            continue
        front = (x, y + 1)
        if front not in base or g.tile(front) not in FRONT or front in g.blocked:
            continue
        if any((x + dx, y + dy) in doors for dx in range(-1, 2) for dy in range(-1, 3)):
            continue
        backed = g.tile((x, y - 1)) in BACKING or (x, y - 1) in g.blocked
        score = abs(x - cx) + abs(y - cy) * 1.2 - (6 if backed else 0) - (2 if g.tile(front) in {"path", "road", "cobbles"} else 0)
        cands.append((score, y, x))
    cands.sort()
    for _, y, x in cands:
        p = (x, y)
        if g.reach(spawn, {p}) != base - {p}:
            continue  # it would cut something off
        g.blocked.add(p)
        pinch = any(g.gap(q) for q in base if abs(q[0] - x) <= 1 and abs(q[1] - y) <= 1 and q != p and g.walk(q))
        g.blocked.discard(p)
        if pinch:
            continue
        z["props"].append({"type": "noticeboard", "x": x, "y": y})
        return p
    return None


def main():
    only = set(sys.argv[1:])
    n = 0
    for f in sorted(os.listdir(ZONES)):
        if not f.endswith(".json"):
            continue
        path = os.path.join(ZONES, f)
        raw = open(path, encoding="utf-8").read()
        z = json.loads(raw)
        if z.get("kind") != "town" or z.get("region") == "dev" or (only and z["id"] not in only):
            continue
        p = place(z)
        if p is None:
            print("%-14s NO SPOT" % z["id"])
            continue
        out = json.dumps(z, indent=1, ensure_ascii="\\u" in raw)
        open(path, "w", encoding="utf-8").write(out + ("\n" if raw.endswith("\n") else ""))
        n += 1
        print("%-14s %d,%d" % (z["id"], p[0], p[1]))
    print("noticeboards:", n)


if __name__ == "__main__":
    main()
