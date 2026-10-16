"""Rail fixes (nwest): give the Sheffield, Lancaster and Keswick lines somewhere to go.
Run: python3 tools/zones/rail_nwest.py data/zones   (edits zone JSON in place, safe to re-run)
Each station is a terminus: a buffer_stop on one end of the line, the other end carried off the map edge."""
import sys, os, json

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"


def patch(zid, row, x0, x1, buffer_at, fill_from=None):
    """Make row `row` rail from x0..x1 inclusive, buffer stop at `buffer_at`."""
    p = os.path.join(OUT, zid + ".json")
    d = json.load(open(p))
    r = d["rows"][row]
    r = r[:x0] + "!" * (x1 - x0 + 1) + r[x1 + 1:]
    d["rows"][row] = r
    # clear anything standing on the new track (decorative props only; never signs, npcs or warps)
    rail = {(x, row) for x in range(x0, x1 + 1)}
    keep = []
    for pr in d["props"]:
        if pr["type"] != "building" and (pr["x"], pr["y"]) in rail and pr["type"] not in ("buffer_stop", "tunnel_portal"):
            print("  removed prop", zid, pr)
            continue
        keep.append(pr)
    d["props"] = keep
    for lst in ("signs", "npcs", "warps"):
        for o in d[lst]:
            assert (o["x"], o["y"]) not in rail, (zid, lst, o)
    if not any(pr["type"] == "buffer_stop" and (pr["x"], pr["y"]) == buffer_at for pr in d["props"]):
        d["props"].append({"type": "buffer_stop", "x": buffer_at[0], "y": buffer_at[1]})
    with open(p, "w") as f:
        json.dump(d, f, indent=1, ensure_ascii=False)


def set_tile(zid, x, y, ch):
    p = os.path.join(OUT, zid + ".json")
    d = json.load(open(p))
    r = d["rows"][y]
    d["rows"][y] = r[:x] + ch + r[x + 1:]
    with open(p, "w") as f:
        json.dump(d, f, indent=1, ensure_ascii=False)


# Sheffield: buffers at the west end (53,47), line runs east off the map (map is 80 wide)
patch("sheffield", 47, 53, 79, (53, 47))
# Lancaster: buffers at the west end (35,30), line runs east off the map (60 wide)
patch("lancaster", 30, 35, 59, (35, 30))
# Keswick: line comes in off the west edge and stops at buffers at 12,37; the path at x13 stays open
set_tile("keswick", 13, 37, ":")
patch("keswick", 37, 0, 12, (12, 37))
