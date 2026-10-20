"""Wave 21, the South East off London (region south_east): the South Downs and Brighton to the south, the Kent Downs,
Canterbury and Dover to the east. Writes the zones, their interiors, dialogue and trainers, and opens London's
south and east sides (a small, idempotent edit of data/zones/london.json).

Usage: python3 tools/zones/se_southeast.py data/zones"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from se_common import *  # noqa: E402
import se_downs, se_brighton, se_kent, se_canterbury, se_dover  # noqa: E402


def open_london(out):
    """a lane south out of London to the Downs, the road east out to Kent; friendly blockers until the Moot is won."""
    path = out + "/london.json"
    d = json.load(open(path))
    if "south" in d["edges"]:
        return
    rows = [list(r) for r in d["rows"]]
    for y in range(61, 66):
        for x in range(51, 54):
            rows[y][x] = "="
    for y in range(26, 29):
        rows[y][79] = "="
    d["rows"] = ["".join(r) for r in rows]
    d["edges"]["south"] = {"to": "south_downs", "offset": -21}
    d["edges"]["east"] = {"to": "kent_downs", "offset": -6}
    d["signs"].append({"x": 55, "y": 62, "text": "SOUTH: THE SOUTH DOWNS AND BRIGHTON. The London to Brighton road, 54 miles, mostly downhill once you're over the Downs."})
    d["signs"].append({"x": 77, "y": 25, "text": "EAST: THE KENT DOWNS, CANTERBURY AND DOVER. The old road to the Channel, walked by pilgrims, Romans and lorries."})
    lines_s = "Road closed, I'm afraid. Every coach in the South East is booked to Stonehenge for the Moot. Come back once the Moot's been won and the roads are clear."
    lines_e = "Sorry, the Kent road's shut while the Moot's on. The Channel's not going anywhere. Come back when the Moot's been won."
    for i, x in enumerate(range(51, 54)):
        d["npcs"].append({"id": "london_south_gate_%d" % i, "sprite": "steelworker", "x": x, "y": 62, "facing": "up", "move": "still",
                          "text": lines_s, "name": "Highways Officer", "hide_if": "moot_won"})
    for i, y in enumerate(range(26, 29)):
        d["npcs"].append({"id": "london_east_gate_%d" % i, "sprite": "steelworker", "x": 79, "y": y, "facing": "left", "move": "still",
                          "text": lines_e, "name": "Highways Officer", "hide_if": "moot_won"})
    open(path, "w").write(json.dumps(d, indent=1, ensure_ascii=False))


def main(out):
    se_downs.build(out)
    se_brighton.build(out)
    se_kent.build(out)
    se_canterbury.build(out)
    se_dover.build(out)
    write_all(out)
    open_london(out)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "data/zones")
