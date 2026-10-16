"""Rail line fixes for Aberdeen, Fort William and Inverness (rail-rules 2026-10-16). Idempotent.
Run: python3 tools/zones/rail_scnorth.py data/zones"""
import sys, os, json
OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"


def put(td, x, y, ch):
    r = td["rows"][y]
    td["rows"][y] = r[:x] + ch + r[x + 1:]


def cap(td, t, x, y, **kw):
    if not any(p["type"] == t and int(p["x"]) == x and int(p["y"]) == y for p in td["props"]):
        td["props"].append(dict(type=t, x=x, y=y, **kw))


def edit(zone, fn):
    p = os.path.join(OUT, zone + ".json")
    td = json.load(open(p))
    fn(td)
    json.dump(td, open(p, "w"), indent=1, ensure_ascii=False)


def aberdeen(td):  # terminus on the quay: line comes in off the west edge, buffers at the harbour end
    for x in range(0, 46): put(td, x, 43, "!")
    for x in (3, 4, 23, 24, 25): put(td, x, 43, "&")  # footpath at Fittie lane and the Union Terrace road
    cap(td, "buffer_stop", 45, 43)


def fort_william(td):  # terminus beside the loch; the West Highland line runs off the east edge
    for x in range(35, 56): put(td, x, 31, "!")
    cap(td, "buffer_stop", 35, 31)


def inverness(td):  # buffers at the west end of the platform, line off the east edge towards Aberdeen
    for x in range(40, 64): put(td, x, 39, "!")
    cap(td, "buffer_stop", 40, 39)


edit("aberdeen", aberdeen)
edit("fort_william", fort_william)
edit("inverness", inverness)
