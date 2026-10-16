"""Rail line ends for bath, glastonbury, penzance (2026-10-16 rail rules). Run: python3 tools/zones/rail_sw.py data/zones"""
import sys, json, os
OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"


def load(z): return json.load(open(os.path.join(OUT, z + ".json")))
def save(z, d): json.dump(d, open(os.path.join(OUT, z + ".json"), "w"), indent=1, ensure_ascii=False)


def put(d, x, y, ch):
    r = d["rows"][y]; d["rows"][y] = r[:x] + ch + r[x + 1:]


def prop(d, t, x, y):
    if not any(p["type"] == t and int(p["x"]) == x and int(p["y"]) == y for p in d["props"]):
        d["props"].append({"type": t, "x": x, "y": y})


# Bath and Glastonbury: the line runs off the west edge, buffers at the east end
for z, y, xe in (("bath", 36, 14), ("glastonbury", 29, 13)):
    d = load(z)
    for x in range(0, 3): put(d, x, y, "!")
    prop(d, "buffer_stop", xe, y)
    save(z, d)

# Penzance: buffers at the harbour end, tunnel into a wooded hill at the west end
d = load("penzance")
for x in (33, 34): put(d, x, 29, "!")
for x, y in ((32, 28), (32, 29), (32, 30), (33, 28), (33, 30), (34, 28), (34, 30)): put(d, x, y, "T")
prop(d, "tunnel_portal", 33, 29)
prop(d, "buffer_stop", 46, 29)
save("penzance", d)
