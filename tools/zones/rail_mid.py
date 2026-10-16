"""Rail fixes (group mid): Birmingham, Nottingham, London, Douglas. Edits town JSON in place; idempotent.
Run: python3 tools/zones/rail_mid.py data/zones"""
import sys, os, json

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"


def load(z):
    return json.load(open(os.path.join(OUT, z + ".json")))


def save(z, d):
    json.dump(d, open(os.path.join(OUT, z + ".json"), "w"), indent=1, ensure_ascii=False)


def put(d, x, y, ch):
    r = d["rows"][y]
    d["rows"][y] = r[:x] + ch + r[x + 1:]


def cap(d, typ, x, y, **kw):
    d["props"] = [p for p in d["props"] if not (p["type"] in ("buffer_stop", "tunnel_portal") and p["x"] == x and p["y"] == y)]
    p = {"type": typ, "x": x, "y": y}
    p.update(kw)
    d["props"].append(p)


# Birmingham New Street: buffers at the west end, the line runs off the east edge
d = load("birmingham")
for x in range(53, 64):
    put(d, x, 8, "!")
cap(d, "buffer_stop", 40, 8)
save("birmingham", d)

# Nottingham: terminus at the west end, runs off the east edge
d = load("nottingham")
for x in range(57, 72):
    put(d, x, 44, "!")
cap(d, "buffer_stop", 45, 44)
save("nottingham", d)

# London King's Cross: buffers at the west end, east end goes into a brick tube mouth
d = load("london")
cap(d, "buffer_stop", 47, 24)
cap(d, "tunnel_portal", 56, 24, variant=1)
save("london", d)

# Douglas: horse tramway down x=43 (trams parked at both stops), railway along row 31
d = load("douglas")
for y in range(0, 4):
    put(d, 43, y, "!")
for y in (12, 24, 36, 47):
    put(d, 43, y, "&")
for y in range(48, 54):
    put(d, 43, y, "!")
for y in (16, 18, 39, 41):
    cap(d, "buffer_stop", 43, y)
for x in range(0, 3):
    put(d, x, 31, "!")
cap(d, "buffer_stop", 20, 31)
save("douglas", d)
