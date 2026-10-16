#!/usr/bin/env python3
"""Puts the retired Keeper who reminds creatures of forgotten moves (story command "relearn") into every
Sanctuary interior. Idempotent: zones that already have one are left alone. Their lines live in
data/dialogue/common.json under "memory_coach", so one script serves every Sanctuary.

    python3 tools/zones/add_memory_coach.py data/zones
"""
import glob
import json
import os
import sys

NPC_ID = "memory_coach"
# first free floor tile wins: off the door-to-counter path, beside the furniture
CANDIDATES = [(8, 4), (2, 4), (8, 5), (2, 5), (9, 5), (1, 5)]


def free(z, x, y):
    rows = z["rows"]
    if not (0 <= y < len(rows) and 0 <= x < len(rows[y])) or rows[y][x] != "|":
        return False
    taken = {(p["x"], p["y"]) for p in z.get("props", [])}
    taken |= {(n["x"], n["y"]) for n in z.get("npcs", [])}
    taken |= {(w["x"], w["y"]) for w in z.get("warps", [])}
    taken |= {(s["x"], s["y"]) for s in z.get("signs", [])}
    taken.add(tuple(z["spawn"]))
    return (x, y) not in taken


def main(zone_dir):
    for path in sorted(glob.glob(os.path.join(zone_dir, "*_sanctuary.json"))):
        with open(path) as f:
            z = json.load(f)
        if any(n.get("id") == NPC_ID for n in z["npcs"]):
            continue
        spot = next((c for c in CANDIDATES if free(z, *c)), None)
        if spot is None:
            print("no room in", path)
            continue
        z["npcs"].append({"id": NPC_ID, "sprite": "poet", "x": spot[0], "y": spot[1], "facing": "down",
                          "move": "still", "script": NPC_ID, "name": "Retired Keeper"})
        with open(path, "w") as f:
            json.dump(z, f, indent=1, ensure_ascii=False)
        print("added to", os.path.basename(path), spot)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "data/zones")
