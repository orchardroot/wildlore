# plan 6 group A: the Aberdeen south seam (edited in place) and the yorkshire_dales / sheffield stubs.
import json, os
from p6a_common import *

# Aberdeen's south border gap: columns 47-49 join the cobbled harbour path (x46-55, y43-45) to the grass below.
ABERDEEN_GAP = (47, 48, 49)


def build(OUT):
    aberdeen(OUT)
    stub(OUT, "yorkshire_dales", "Yorkshire Dales", "east", 20, "york")
    stub(OUT, "sheffield", "Sheffield", "north", 30, "york")


def aberdeen(OUT):
    path = OUT + "/aberdeen.json"
    d = json.load(open(path))
    rows = [list(r) for r in d["rows"]]
    h = len(rows)
    for y in (h - 2, h - 1):
        for x in ABERDEEN_GAP:
            rows[y][x] = "g"
    d["rows"] = ["".join(r) for r in rows]
    d["edges"]["south"] = {"to": "northumberland_coast", "offset": 0}
    json.dump(d, open(path, "w"), indent=1, sort_keys=True)


def stub(OUT, zid, name, side, first, to):
    """40x40 grass placeholder another builder replaces; one 2/3-wide gap on `side` back to `to`."""
    path = OUT + "/" + zid + ".json"
    if os.path.exists(path) and not json.load(open(path)).get("stub"):
        return
    z = Z(zid, name, 40, 40, fill=".", kind="town", region=YK, music="town_north")
    z.d["stage"] = "town"
    z.d["stub"] = True
    gap = {"east": (38, first, 2, 3), "north": (first, 0, 3, 2)}[side]
    z.border("T", 2, gaps=[gap])
    z.d["edges"][side] = {"to": to, "offset": 0}
    z.d["spawn"] = [20, 20]
    z.save(path)
