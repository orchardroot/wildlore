# Opens Exe Estuary's east wall on to Poole (idempotent), with the friendly gate: marshals who let you through once you
# hold the Storm Stone (badge four), the band the islands are written at.
#   python3 tools/zones/ci_anchor.py data/zones
import json, sys
OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
p = OUT + "/exe_estuary.json"
d = json.load(open(p))
if "east" not in d["edges"]:
    rows = [list(r) for r in d["rows"]]
    for y in (11, 12, 13):
        for x in (68, 69):
            rows[y][x] = "g"
        for x in range(53, 60):  # a shallow ford across the estuary mouth to the eastern shore
            rows[y][x] = "w"
    d["rows"] = ["".join(r) for r in rows]
    d["edges"]["east"] = {"to": "poole", "offset": 0}
    for y in (11, 12, 13):
        d["npcs"].append({"id": "poole_marshal_%d" % (y - 10), "sprite": "warden_grunt", "x": 66, "y": y, "facing": "right",
                          "move": "still", "script": "poole_marshal", "hide_if": "badge_storm"})
    d["signs"].append({"x": 64, "y": 14, "text": "EAST: Poole Quay, and the ferries to Jersey and Guernsey. WEST: Exeter and the moor."})
    json.dump(d, open(p, "w"), indent=1)
    open(p, "a").write("\n")

# the marshals' line goes into Exe Estuary's existing dialogue file
p = OUT.rsplit("/", 1)[0] + "/dialogue/exe_estuary.json"
dd = json.load(open(p))
if "poole_marshal" not in dd:
    dd["poole_marshal"] = [
        {"do": "say", "who": "Marshal", "text": "Road's shut for the Harbour Regatta marshals' briefing. We're only letting through trainers who've won the Storm Stone at Cardiff. It's safety, apparently. Or a bit of a lark."},
        {"do": "say", "who": "Marshal", "text": "Come back when you've got it, and we'll wave you through with a flag."}]
    json.dump(dd, open(p, "w"), indent=1, ensure_ascii=False)
    open(p, "a").write("\n")
