"""Adds regional dressing to the existing town zones: bunting between lamp posts and along terrace fronts,
flagpoles at castles, town halls and ferry terminals, washing lines beside houses, hanging baskets on lamp
posts and pub fronts. Everything except a flagpole hangs overhead (`walk`), and a flagpole is only placed
where it keeps every walkable tile reachable. Idempotent: a town that already has a piece of a kind is left alone.

    python3 tools/zones/dress_towns.py data/zones [--dry]
"""
import json, glob, os, random, re, sys

WALK = set(".,#=:sfwD|+_&")
GRASS = set(".f")
NEW = ("bunting", "flagpole", "washing_line", "hanging_basket")

# market and seaside towns that get bunting
BUNTING = ["macclesfield", "chester", "keswick", "lancaster", "kilkenny", "sligo", "buxton", "llangollen", "glastonbury",
           "st_davids", "bushmills", "aberystwyth", "whitby", "penzance", "dingle", "douglas", "holyhead", "cairnryan",
           "portree", "llanberis", "bath", "galway", "fort_william", "kirkwall", "york"]
# villages and small towns with hanging baskets on their lamp posts
BASKETS = ["bushmills", "buxton", "cairnryan", "dingle", "fort_william", "keswick", "llanberis", "llangollen", "macclesfield",
           "penzance", "portree", "st_davids", "sligo", "kirkwall", "glastonbury", "lancaster", "whitby", "aberystwyth",
           "douglas", "holyhead", "kilkenny", "bath", "chester", "york"]
# terraced streets with washing out
WASHING = ["manchester", "liverpool", "sheffield", "newcastle", "cardiff", "aberystwyth", "whitby", "dublin", "belfast",
           "birmingham", "nottingham", "holyhead", "llanberis", "penzance", "cork", "derry", "glasgow", "aberdeen"]
# flag by region/town (variants: 0 dragon, 1 saltire, 2 tricolour, 3 triskelion, 4 St George, 5 St Piran, 6 Union).
# Northern Ireland gets none, to keep clear of the argument.
FLAG = {"wales": 0, "scotland": 1, "ireland_rep": 2, "man": 3, "england": 4, "cornwall": 5}
REGION_FLAG = {"mid_wales": 0, "south_wales": 0, "north_wales": 0, "scotland": 1, "ireland_west": 2, "ireland_east": 2,
               "man": 3, "cornwall": 5, "cheshire": 4, "cumbria": 4, "south_england": 4, "midlands": 4, "manchester": 4,
               "merseyside": 4, "north_east": 4, "yorkshire": 4, "peak": 4}
NO_FLAG = {"belfast", "derry", "bushmills"}          # Northern Ireland
REPUBLIC = {"dublin", "cork", "kilkenny", "galway", "sligo", "dingle", "newgrange"}  # region "ireland" is mixed
FLAG_SITES = re.compile(r"castle|town hall|city hall|guildhall|moot hall|council house|ferry terminal|market hall|memorial hall|tower of london", re.I)
PUBS = re.compile(r"\b(arms|inn|pub|tavern|head|crown|bar|hotel)\b", re.I)


class Town:
    def __init__(s, d):
        s.d = d
        s.rows = d["rows"]
        s.w = len(s.rows[0])
        s.h = len(s.rows)
        s.props = d["props"]
        s.block = set()
        for p in s.props:
            if p["type"] != "building" and not p.get("walk"):
                s.block.add((int(p["x"]), int(p["y"])))
        for g in d.get("signs", []):
            s.block.add((int(g["x"]), int(g["y"])))
        for n in d["npcs"]:
            if n.get("move", "still") == "still":
                s.block.add((int(n["x"]), int(n["y"])))
        s.taken = set(s.block)
        s.used = set()  # tiles a new piece sits on

    def ch(s, x, y):
        return s.rows[y][x] if 0 <= x < s.w and 0 <= y < s.h else "T"

    def reach_count(s, extra=()):
        blocked = s.block | set(extra)
        starts = [(int(s.d["spawn"][0]), int(s.d["spawn"][1]))] + [(int(w["x"]), int(w["y"])) for w in s.d["warps"]]
        seen = set()
        todo = [p for p in starts if p not in blocked and s.ch(*p) in WALK]
        seen.update(todo)
        while todo:
            x, y = todo.pop()
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                q = (x + dx, y + dy)
                if q in seen or q in blocked or s.ch(*q) not in WALK:
                    continue
                seen.add(q)
                todo.append(q)
        return seen

    def special(s):
        pts = {(int(s.d["spawn"][0]), int(s.d["spawn"][1]))}
        for w in s.d["warps"]:
            pts.add((int(w["x"]), int(w["y"])))
        for n in s.d["npcs"]:
            pts.add((int(n["x"]), int(n["y"])))
        for side in s.d.get("edges", {}):
            pass
        return pts

    def border(s, x, y):
        return x <= 1 or y <= 1 or x >= s.w - 2 or y >= s.h - 2

    def add(s, t, x, y, **kw):
        p = {"type": t, "x": x, "y": y}
        p.update(kw)
        s.props.append(p)


def buildings(t):
    return [p for p in t.props if p["type"] == "building"]


def region_flag(d):
    zid = d["id"]
    if zid in NO_FLAG:
        return None
    if zid in REPUBLIC:
        return 2
    return REGION_FLAG.get(d.get("region", ""))


def bunting(t, rng):
    lamps = sorted({(int(p["x"]), int(p["y"])) for p in t.props if p["type"] == "lamp_post"})
    pairs = []
    for (x, y) in lamps:
        for (x2, y2) in lamps:
            if y2 == y and 2 <= x2 - x <= 7:
                if all(t.ch(xx, y) in WALK and t.ch(xx, y) != "D" for xx in range(x, x2 + 1)):
                    pairs.append(((x, y), (x2, y2), "h"))
    rng.shuffle(pairs)
    used = set()
    n = 0
    for a, b, o in pairs:
        span = {(a[0] + i * (1 if o == "h" else 0), a[1] + i * (1 if o == "v" else 0)) for i in range(0, (b[0] - a[0] if o == "h" else b[1] - a[1]) + 1)}
        if span & used or a in used or b in used:
            continue
        # near the middle of the map rather than the rim, where people actually walk
        if t.border(*a) or t.border(*b):
            continue
        used |= span
        length = (b[0] - a[0]) if o == "h" else (b[1] - a[1])
        if o == "h":
            t.add("bunting", a[0], a[1], variant=length, walk=True)
        else:
            t.add("bunting", a[0], a[1], variant=length, rot=270, walk=True)
        n += 1
        if n >= 3:
            break
    if n < 2:
        # along a terrace front: the row of street just south of a long shopfront
        fronts = [p for p in buildings(t) if int(p["w"]) >= 4 and p.get("style") in ("terrace", "tudor", "white_render", "cream_render", "red_brick", "stone")
                  and "Cathedral" not in p.get("label", "")]
        rng.shuffle(fronts)
        for p in fronts:
            bx, by, bw, bh = int(p["x"]), int(p["y"]), int(p["w"]), int(p["h"])
            y = by + bh
            if all(t.ch(x, y) in WALK for x in range(bx, bx + bw)) and not t.border(bx, y) and not t.border(bx + bw, y):
                t.add("bunting", bx, y, variant=bw - 1, walk=True)
                n += 1
                break
    return n


def flags(t, rng, flag):
    if flag is None:
        return 0
    base = t.reach_count()
    n = 0
    sites = [p for p in buildings(t) if FLAG_SITES.search(p.get("label", ""))]
    for p in sites:
        if n >= 2:
            break
        bx, by, bw, bh = int(p["x"]), int(p["y"]), int(p["w"]), int(p["h"])
        label = p.get("label", "")
        variant = 6 if t.d["id"] == "london" and "Tower of London" in label else flag
        cands = []
        for dy in (0, 1, 2):
            for x in (bx - 1, bx + bw):
                cands.append((x, by + bh - 1 + dy))
            for x in (bx - 2, bx + bw + 1):
                cands.append((x, by + bh - 1 + dy))
        cands += [(bx + bw // 2 - 3, by + bh), (bx + bw // 2 + 3, by + bh)]
        sp = t.special()
        for (x, y) in cands:
            if not (0 <= x < t.w and 0 <= y < t.h) or t.border(x, y):
                continue
            if t.ch(x, y) not in GRASS or (x, y) in t.taken or (x, y) in sp:
                continue
            # in the open, not wedged into an alley between two buildings
            if sum(1 for ax in (-1, 0, 1) for ay in (-1, 0, 1) if (ax or ay) and t.ch(x + ax, y + ay) in WALK) < 7:
                continue
            if any(abs(x - qx) + abs(y - qy) <= 1 for (qx, qy) in sp):
                continue
            # never against a doorstep or a path: leave the 8 tiles round it passable
            if t.reach_count({(x, y)}) != base - {(x, y)}:
                continue
            # fly the flag away from the building, so it is not lost against the roof
            t.add("flagpole", x, y, variant=variant, **({"rot": 180} if x >= bx + bw else {}))
            t.block.add((x, y))
            t.taken.add((x, y))
            base = t.reach_count()
            n += 1
            break
    return n


def baskets(t, rng):
    lamps = [(int(p["x"]), int(p["y"])) for p in t.props if p["type"] == "lamp_post"]
    rng.shuffle(lamps)
    n = 0
    for (x, y) in lamps[:max(2, len(lamps) // 2)][:6]:
        t.add("hanging_basket", x, y, rot=rng.choice([0, 90, 180, 270]), walk=True)
        n += 1
    for p in buildings(t):
        if n >= 8:
            break
        if PUBS.search(p.get("label", "")):
            bx, by, bw, bh = int(p["x"]), int(p["y"]), int(p["w"]), int(p["h"])
            door = [x for x in range(bx, bx + bw) if t.ch(x, by + bh - 1) == "D"]
            if not door:
                continue
            for x in (door[0] - 1, door[0] + 1):
                if bx <= x < bx + bw and t.ch(x, by + bh - 1) == "B":
                    t.add("hanging_basket", x, by + bh - 1, variant=1, walk=True)
                    n += 1
    return n


def washing(t, rng):
    houses = [p for p in buildings(t) if p.get("style") in ("terrace", "red_brick", "cream_render", "white_render", "slate_cottage", "tudor")
              and int(p["h"]) <= 4 and "Cathedral" not in p.get("label", "") and not PUBS.search(p.get("label", ""))]
    rng.shuffle(houses)
    n = 0
    for p in houses:
        bx, by, bw, bh = int(p["x"]), int(p["y"]), int(p["w"]), int(p["h"])
        placed = False
        for run in (3, 4):
            for y in range(by + 1, by + bh):
                for x0 in (bx + bw, bx - run):
                    xs = range(x0, x0 + run)
                    ys = (y, y + 1)
                    # grass all round, so the line never crosses a path or a doorstep
                    if all(t.ch(x, yy) in GRASS and (x, yy) not in t.taken and (x, yy) not in t.used and not t.border(x, yy) for x in xs for yy in ys):
                        t.add("washing_line", x0, y, variant=run - 1, walk=True)
                        for x in xs:
                            for yy in ys:
                                t.used.add((x, yy))
                        n += 1
                        placed = True
                        break
                if placed:
                    break
            if placed:
                break
        if n >= 2:
            break
    return n


def dress(path, dry=False):
    d = json.load(open(path))
    if d.get("kind") != "town" or d["id"] == "mesh_gallery":
        return None
    zid = d["id"]
    if any(p["type"] in NEW for p in d["props"]):
        return None
    t = Town(d)
    rng = random.Random("dress:" + zid)
    out = {}
    if zid in BUNTING:
        out["bunting"] = bunting(t, rng)
    out["flags"] = flags(t, rng, region_flag(d))
    if zid in BASKETS:
        out["baskets"] = baskets(t, rng)
    if zid in WASHING:
        out["washing"] = washing(t, rng)
    if any(out.values()) and not dry:
        json.dump(d, open(path, "w"), indent=1)
    return out


if __name__ == "__main__":
    total = {}
    for path in sorted(glob.glob(os.path.join(sys.argv[1], "*.json"))):
        r = dress(path, dry="--dry" in sys.argv)
        if r:
            print(os.path.basename(path), r)
            for k, v in r.items():
                total[k] = total.get(k, 0) + v
    print(total)
