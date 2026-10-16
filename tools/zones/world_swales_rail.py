"""Rail fixes for the swales group (rail rules 2026-10-16). Run: python3 tools/zones/world_swales_rail.py data/zones
Aberystwyth: cliff railway with buffers at both ends; main line a terminus (buffers west, off the east edge).
Cardiff Central: in from the west edge, buffers at the east end. St Davids Halt: buffers west, off the east edge."""
import json, sys, os

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"

# zone: (row tiles to turn into rail [(x0, x1, y)], buffer stops [(x, y)])
FIX = {
    "aberystwyth": ([(43, 55, 35)], [(15, 6), (15, 11), (33, 35)]),
    "cardiff": ([(0, 1, 26)], [(12, 26)]),
    "st_davids": ([(45, 47, 7)], [(36, 7)]),
}

for zone, (runs, bufs) in FIX.items():
    p = os.path.join(OUT, zone + ".json")
    d = json.load(open(p))
    for (x0, x1, y) in runs:
        for x in range(x0, x1 + 1):
            # trees in the way of the line are felled
            d["props"] = [q for q in d["props"] if not (q["type"] in ("oak", "pine", "birch", "bush")
                                                         and int(q["x"]) == x and int(q["y"]) == y)]
            assert not any(int(q["x"]) == x and int(q["y"]) == y for q in d["props"] if q["type"] != "building"), (zone, x, y, "prop")
            assert not any(int(n["x"]) == x and int(n["y"]) == y for n in d["npcs"]), (zone, x, y, "npc")
            assert not any(int(s["x"]) == x and int(s["y"]) == y for s in d.get("signs", [])), (zone, x, y, "sign")
            assert d["rows"][y][x] not in "BD", (zone, x, y)
            r = d["rows"][y]
            d["rows"][y] = r[:x] + "!" + r[x + 1:]
    for (x, y) in bufs:
        assert d["rows"][y][x] == "!", (zone, x, y)
        if not any(q["type"] == "buffer_stop" and int(q["x"]) == x and int(q["y"]) == y for q in d["props"]):
            d["props"].append({"type": "buffer_stop", "x": x, "y": y})
    json.dump(d, open(p, "w"), indent=1, ensure_ascii=False)
