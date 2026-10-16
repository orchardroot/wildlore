"""Rail fix for Galway and Sligo: each terminus line runs off the west map edge and ends in buffer stops.
Run: python3 tools/zones/world_iwest_rail.py data/zones"""
import sys, json, os
OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
for zone, row, x_end in (("galway", 32, 13), ("sligo", 45, 15)):
    p = os.path.join(OUT, zone + ".json")
    d = json.load(open(p))
    r = d["rows"][row]
    first = r.index("!")
    d["rows"][row] = "!" * first + r[first:]
    if not any(q["type"] == "buffer_stop" for q in d["props"]):
        d["props"].append({"type": "buffer_stop", "x": x_end, "y": row})
    json.dump(d, open(p, "w"), indent=1, ensure_ascii=False)
