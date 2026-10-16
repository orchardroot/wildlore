"""Rail line fixes for Belfast, Bushmills, Derry~Londonderry and Dublin (see docs/superpowers/plans/2026-10-16-rail-rules.md).
Run: python3 tools/zones/world_ieast_rail.py data/zones   (idempotent, edits the zone JSON directly)"""
import sys, os, json

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"


def load(z):
    return json.load(open(os.path.join(OUT, z + ".json")))


def save(z, d):
    with open(os.path.join(OUT, z + ".json"), "w") as f:
        json.dump(d, f, indent=1, ensure_ascii=False)


def put(d, x, y, ch):
    r = d["rows"][y]
    d["rows"][y] = r[:x] + ch + r[x + 1:]


def lay(d, y, x0, x1, crossings=()):
    """track along row y from x0 to x1 inclusive; `&` where a path/road crosses (given x list)"""
    for x in range(x0, x1 + 1):
        put(d, x, y, "&" if x in crossings else "!")
        # drop scenery props that would sit on the track
        d["props"] = [p for p in d["props"]
                      if p.get("type") in ("building", "buffer_stop", "tunnel_portal")
                      or not (int(p["x"]) == x and int(p["y"]) == y)]


def cap(d, kind, x, y, **kw):
    if not any(p.get("type") == kind and int(p["x"]) == x and int(p["y"]) == y for p in d["props"]):
        d["props"].append(dict(type=kind, x=x, y=y, **kw))


# Belfast Great Victoria Street: through to the west edge, buffers at the east end
d = load("belfast")
lay(d, 41, 0, 15)
cap(d, "buffer_stop", 15, 41)
save("belfast", d)

# Bushmills Railway: heritage line runs off the west edge, terminus buffers at the east end
d = load("bushmills")
lay(d, 31, 0, 11)
cap(d, "buffer_stop", 11, 31)
save("bushmills", d)

# Derry~Londonderry Station: through to the east edge, buffers at the west end by the river path
d = load("derry")
lay(d, 11, 62, 71)
cap(d, "buffer_stop", 62, 11)
save("derry", d)

# Dublin Connolly: buffers at the east end; west across the road (level crossing) into a tunnel in a wooded knoll
d = load("dublin")
lay(d, 7, 29, 45, crossings=range(29, 34))
cap(d, "buffer_stop", 45, 7)
for (x, y) in [(27, 7), (27, 6), (27, 8), (28, 6), (28, 8)]:
    put(d, x, y, "T")
    d["props"] = [p for p in d["props"] if not (int(p["x"]) == x and int(p["y"]) == y and p.get("type") != "building")]
cap(d, "tunnel_portal", 28, 7)
save("dublin", d)
print("rail fixed")
