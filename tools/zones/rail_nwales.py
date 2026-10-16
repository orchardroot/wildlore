"""Rail pass (2026-10-16) for North Wales: each station line becomes a terminus (buffer stop at the west end)
running east off the map edge, with level crossings where paths/roads meet it.
Run: python3 tools/zones/rail_nwales.py data/zones   (edits zone JSON in place; safe to re-run)"""
import sys, os, json

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"

# zone: (row, buffer_x, crossing xs); track runs from buffer_x to the east edge.
FIX = {
    "holyhead": (30, 35, {47, 55}),                 # doors of the two houses open onto the line
    "llanberis": (12, 46, {56, 57, 58}),            # the north-south road
    "llangollen": (27, 43, set()),
}
for zid, (row, bx, cross) in FIX.items():
    p = os.path.join(OUT, zid + ".json")
    d = json.load(open(p))
    r = d["rows"][row]
    w = len(r)
    chars = list(r)
    for x in range(bx, w):
        chars[x] = "&" if x in cross else "!"
    d["rows"][row] = "".join(chars)
    if not any(q["type"] == "buffer_stop" and q["x"] == bx and q["y"] == row for q in d["props"]):
        d["props"].append({"type": "buffer_stop", "x": bx, "y": row})
    json.dump(d, open(p, "w"), indent=1, ensure_ascii=False)
