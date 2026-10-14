# Plan 4 group B seams (idempotent). Run from the repo root: python3 tools/zones/ie_seams.py
#  - llanberis: open its WEST border at rows 10-12 and a gap in the drystone wall below, add the west edge to anglesey
#  - data/ferries.json: holyhead_dublin
#  - stubs ring_of_kerry and boyne_valley (group C replaces them), unless a real zone already exists
import json, os
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
Zd = os.path.join(ROOT, "data", "zones")

# llanberis
p = os.path.join(Zd, "llanberis.json")
d = json.load(open(p))
rows = [list(r) for r in d["rows"]]
for y in (10, 11, 12):
    for x in (0, 1, 2):
        rows[y][x] = "."
for x in (9, 10, 11):          # a gap in the drystone wall so the west pocket joins the village paths
    rows[14][x] = "."
d["rows"] = ["".join(r) for r in rows]
d["edges"]["west"] = {"to": "anglesey", "offset": 0}
json.dump(d, open(p, "w"), indent=1)

# ferries
p = os.path.join(ROOT, "data", "ferries.json")
f = json.load(open(p))
f["holyhead_dublin"] = {"a": "holyhead", "b": "dublin", "ship": "the Ulysses",
                        "card": "The Ulysses heaves across the Irish Sea. A seagull inspects your sandwich and decides it is not a Dublin sandwich yet."}
json.dump(f, open(p, "w"), indent=1)


def stub(zid, name, side, edge_to, gap_lo):
    """40x40 grass, tree border 2 thick, one 3-tile gap on `side` (rows or columns gap_lo..gap_lo+2)."""
    p = os.path.join(Zd, zid + ".json")
    if os.path.exists(p) and not json.load(open(p)).get("stub"):
        return
    n = 40
    rows = [["T" if (x < 2 or y < 2 or x >= n - 2 or y >= n - 2) else "." for x in range(n)] for y in range(n)]
    for k in range(gap_lo, gap_lo + 3):
        for t in (0, 1):
            if side == "east":
                rows[k][n - 1 - t] = "."
            else:
                rows[n - 1 - t][k] = "."
    d = {"id": zid, "name": name, "region": "ireland", "kind": "route", "music": "route_ireland", "stub": True,
         "weather": {"drizzle": 40, "clear": 30, "fog": 10, "sunshine": 20}, "stage": "grass",
         "props": [], "warps": [], "npcs": [], "encounters": {}, "signs": [], "spawn": [20, 20],
         "edges": {side: {"to": edge_to, "offset": 0}}, "rows": ["".join(r) for r in rows]}
    json.dump(d, open(p, "w"), indent=1)


stub("ring_of_kerry", "Ring of Kerry", "east", "cork", 20)
stub("boyne_valley", "Boyne Valley", "south", "dublin", 30)
