"""Interior furnishing presets for landmark() interiors, and a re-furnisher for the ones already generated.

furnish(...) works on plain data (rows, props, npcs, ...) so zlib.landmark() can use it while building a zone
and `python3 tools/zones/furnish.py data/zones` can add the same dressing to the existing interiors. It only
adds props on free floor tiles, never moves an NPC, exit or existing prop, and refuses any blocking piece that
would cut a free tile off from the exit or leave an NPC with nobody able to stand next to it.

Wall pieces (picture, clock, menu_board, fireplace, dresser) sit on row 1 against the north wall. `rot` turns a
piece: 0 back to the north wall, 90 west, 180 south, 270 east.
"""
import json, random, sys, glob, os

FLOOR = "|+D"
# props that block their tile (everything but these hangs or lies flat)
SOFT = {"rug", "wall_picture", "clock", "menu_board", "bunting", "washing_line", "hanging_basket"}
# things a wall picture, clock or menu can hang over without clashing
LOW = {"fryer", "sofa", "display_case", "table", "bench", "bed", "piano", "bollard", "planter"}
# things a rug may lie under
RUGGABLE = {"table", "bench"}
NEW_TYPES = {"fireplace", "kitchen_dresser", "fryer", "menu_board", "piano", "telescope", "plant_stand", "sofa",
             "display_case", "rug", "wall_picture", "clock"}


class Room:
    def __init__(s, rows, props, npcs, warps, spawn, signs=()):
        s.rows = [list(r) for r in rows]
        s.h = len(rows)
        s.w = len(rows[0])
        s.props = list(props)
        s.npcs = npcs
        s.warps = warps
        s.spawn = tuple(spawn)
        s.occ = {}      # (x, y) -> prop type, for blocking props
        s.signs = {(int(g["x"]), int(g["y"])) for g in signs}
        s.npc_at = {(int(n["x"]), int(n["y"])) for n in npcs}
        s.exits = {(int(w["x"]), int(w["y"])) for w in warps}
        for p in s.props:
            if p.get("type") != "building" and not p.get("walk", False):
                s.occ[(int(p["x"]), int(p["y"]))] = p["type"]
        s.wall = {}     # tile -> wall-hung piece types already there
        s.new = []
        for p in s.props:
            if p.get("walk") and p["type"] in ("wall_picture", "clock", "menu_board"):
                s.wall[(int(p["x"]), int(p["y"]))] = p["type"]

    def ch(s, x, y):
        if 0 <= x < s.w and 0 <= y < s.h:
            return s.rows[y][x]
        return "x"

    def floor(s, x, y):
        return s.ch(x, y) in FLOOR

    def blocked(s, extra=None):
        b = {t for t in s.occ} | s.signs | s.npc_at
        if extra:
            b |= extra
        return b

    def reach(s, blocked):
        start = s.spawn
        seen = {start}
        todo = [start]
        while todo:
            x, y = todo.pop()
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                q = (x + dx, y + dy)
                if q in seen or q in blocked:
                    continue
                if s.ch(*q) in FLOOR:
                    seen.add(q)
                    todo.append(q)
        return seen

    def talkable(s, seen):
        for (nx, ny) in s.npc_at:
            ok = False
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                q = (nx + dx, ny + dy)
                if q in seen:
                    ok = True
                elif s.ch(*q) == "C" and (nx + 2 * dx, ny + 2 * dy) in seen:
                    ok = True
            if not ok:
                return False
        return True

    def free(s, x, y):
        """A floor tile nothing stands on or occupies."""
        return s.floor(x, y) and (x, y) not in s.occ and (x, y) not in s.npc_at and (x, y) not in s.signs \
            and (x, y) not in s.exits and (x, y) != s.spawn

    def safe_to_block(s, x, y):
        """Would blocking (x, y) keep the exit, every other free tile and every NPC reachable?"""
        if not s.free(x, y):
            return False
        # keep a clear lane at the door and the arrival tile
        dx = s.w // 2
        if y >= s.h - 3 and abs(x - dx) <= 1:
            return False
        # not next to a wandering NPC's tile, and not on the arrival tile's neighbours
        for (nx, ny) in s.npc_at:
            if abs(nx - x) + abs(ny - y) == 1:
                return False
        before = s.reach(s.blocked())
        after = s.reach(s.blocked({(x, y)}))
        if not s.exits <= after:
            return False
        if (before - {(x, y)}) - after:
            return False
        return s.talkable(after)

    def add_block(s, t, x, y, **kw):
        if not s.safe_to_block(x, y):
            return False
        s.occ[(x, y)] = t
        p = {"type": t, "x": x, "y": y}
        p.update(kw)
        s.new.append(p)
        return True

    def wall_ok(s, x):
        if not s.floor(x, 1) or (x, 1) in s.wall or (x, 1) in s.exits or (x, 1) in s.signs:
            return False
        t = s.occ.get((x, 1))
        return t is None or t in LOW

    def add_wall(s, t, x, **kw):
        if not s.wall_ok(x):
            return False
        s.wall[(x, 1)] = t
        p = {"type": t, "x": x, "y": 1, "walk": True}
        p.update(kw)
        s.new.append(p)
        return True

    def add_rug(s, x, y, w, h, variant):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                if not s.floor(xx, yy) or s.occ.get((xx, yy), "table") not in RUGGABLE or (xx, yy) in s.exits:
                    return False
        s.new.append({"type": "rug", "x": x, "y": y, "w": w, "h": h, "variant": variant, "walk": True})
        return True


def _wall_free(room, order):
    return [x for x in order if room.free(x, 1)]


def _near(room, targets, rng, jitter=0.0):
    return sorted(targets, key=lambda x: abs(x - room.w // 2) + rng.random() * jitter)


def furnish(kind, name, zid, rows, props, npcs, warps, spawn, signs=()):
    """New prop dicts to add to the interior described by the arguments."""
    r = Room(rows, props, npcs, warps, spawn, signs)
    rng = random.Random("furnish:" + zid)
    w, h = r.w, r.h
    dx = w // 2
    xs = list(range(1, w - 1))
    chippy = kind == "cafe" and any(k in name.lower() for k in ("chip", "fish"))

    def wall_block(t, prefer=None, **kw):
        order = prefer if prefer is not None else _near(r, xs, rng, 3.0)
        for x in order:
            if r.add_block(t, x, 1, **kw):
                return True
        return False

    def wall_deco(t, n=1, prefer=None, **kw):
        order = prefer if prefer is not None else _near(r, xs, rng, 4.0)
        done = 0
        for x in order:
            if done >= n:
                break
            if r.add_wall(t, x, **kw if t != "wall_picture" else dict(kw, variant=rng.randrange(3))):
                done += 1
        return done

    def pictures(n, variant=None):
        order = _near(r, xs, rng, 4.0)
        done = 0
        for x in order:
            if done >= n:
                break
            # keep pictures apart from each other and from the clock
            if any(abs(x - px) < 2 and y == 1 for (px, y) in r.wall):
                continue
            if r.add_wall("wall_picture", x, variant=rng.randrange(3) if variant is None else variant):
                done += 1

    def rug(rw, rh, centre_y=None):
        cy = centre_y if centre_y is not None else (h - 2) / 2.0
        cands = []
        for y in range(2, h - 2):
            for x in range(1, w - rw):
                cands.append((abs(x + rw / 2.0 - w / 2.0) + abs(y + rh / 2.0 - cy) + rng.random(), x, y))
        for _, x, y in sorted(cands):
            if r.add_rug(x, y, rw, rh, rng.randrange(4)):
                return True
        return False

    def floor_piece(t, spots, **kw):
        spots = list(spots)
        for (x, y, *rest) in spots:
            extra = dict(kw)
            if rest:
                extra["rot"] = rest[0]
            if r.add_block(t, x, y, **extra):
                return True
        return False

    def west(y_from=3):  # armchair/sofa spots against the west wall, back to the wall
        return [(1, y, 90) for y in range(y_from, h - 4)]

    def east(y_from=3):
        return [(w - 2, y, 270) for y in range(y_from, h - 4)]

    def corners():
        return [(1, h - 4), (w - 2, h - 4), (1, 2), (w - 2, 2)]

    if kind == "home":
        wall_block("fireplace", _near(r, xs, rng, 2.0))
        rug(3, 2)
        floor_piece("sofa", west(3) + east(5), variant=rng.randrange(3) * 2)
        floor_piece("sofa", east(3) + west(5), variant=rng.randrange(3) * 2 + 1)
        wall_deco("clock")
        pictures(2)
        floor_piece("plant_stand", corners(), variant=rng.randrange(2))
    elif kind == "cottage":
        wall_block("fireplace", _near(r, xs, rng, 2.0))
        wall_block("kitchen_dresser", [x for x in reversed(_near(r, xs, rng, 2.0))])
        rug(3, 2)
        floor_piece("sofa", west(3) + east(3), variant=rng.randrange(3) * 2 + 1)
        wall_deco("clock")
        pictures(1)
        floor_piece("plant_stand", corners())
    elif kind == "cafe":
        if chippy:
            behind = [x for x in range(1, w - 1) if r.ch(x, 2) == "C"]
            wall_block("fryer", behind + _near(r, xs, rng, 2.0))
            fry = [p["x"] for p in r.new if p["type"] == "fryer"]
            wall_deco("menu_board", prefer=fry + _near(r, xs, rng, 2.0))
            wall_block("kitchen_dresser", list(reversed(_near(r, xs, rng, 2.0))))
        else:
            wall_deco("menu_board", prefer=_near(r, xs, rng, 2.0))
            wall_block("kitchen_dresser", list(reversed(_near(r, xs, rng, 2.0))))
        wall_deco("clock")
        pictures(2)
        floor_piece("plant_stand", corners(), variant=rng.randrange(2))
        floor_piece("sofa", east(3) + west(3), variant=rng.randrange(3) * 2 + 1)
    elif kind == "library":
        wall_block("fireplace", [dx])
        wall_deco("clock", prefer=[dx + 1, dx - 1])
        pictures(1)
        rug(4, 2)
        floor_piece("sofa", west(2) + east(2), variant=rng.randrange(3) * 2 + 1)
        floor_piece("sofa", east(2) + west(2), variant=rng.randrange(3) * 2 + 1)
        floor_piece("telescope", [(w - 2, h - 4), (1, h - 4), (w - 2, 2)])
        floor_piece("plant_stand", corners())
    elif kind == "museum":
        for (x, y) in [(2, 3), (w - 3, 3), (2, 5), (w - 3, 5), (dx - 2, 4), (dx + 2, 4), (2, 6), (w - 3, 6)]:
            if sum(1 for p in r.new if p["type"] == "display_case") >= 4:
                break
            r.add_block("display_case", x, y, variant=rng.randrange(3))
        pictures(3)
        wall_deco("clock")
        rug(3, 3)
        floor_piece("telescope", [(1, h - 4), (w - 2, h - 4), (1, 2)])
        floor_piece("plant_stand", corners())
    elif kind == "hall":
        wall_block("fireplace", _near(r, xs, rng, 2.0))
        rug(4, 3)
        pictures(3, variant=1)
        wall_deco("clock")
        floor_piece("piano", [(1, 2, 90), (w - 2, 2, 270), (1, 3, 90), (w - 2, 3, 270)])
        floor_piece("sofa", west(4) + east(4), variant=rng.randrange(3) * 2 + 1)
        floor_piece("plant_stand", corners())
    elif kind == "church":
        rug(1, max(2, h - 6))
        floor_piece("piano", [(1, 2, 90), (w - 2, 2, 270), (1, 1), (w - 2, 1)])
        pictures(2, variant=0)
        wall_deco("clock")
        floor_piece("plant_stand", corners(), variant=1)
    elif kind == "theatre":
        floor_piece("piano", [(w - 3, 1), (3, 1), (1, 2, 90), (w - 2, 2, 270)])
        rug(1, max(2, h - 6))
        pictures(3, variant=1)
        wall_deco("clock")
        floor_piece("plant_stand", corners())
        floor_piece("sofa", west(6) + east(6), variant=rng.randrange(3) * 2 + 1)
    elif kind == "mill":
        wall_block("kitchen_dresser", _near(r, xs, rng, 2.0))
        wall_deco("clock")
        pictures(1)
        rug(2, 2)
        floor_piece("plant_stand", corners())
    elif kind == "workshop":
        wall_block("kitchen_dresser", _near(r, xs, rng, 2.0))
        wall_deco("clock")
        pictures(1)
        rug(2, 2)
        floor_piece("plant_stand", corners())
    elif kind == "school":
        wall_deco("clock", prefer=[dx])
        pictures(2, variant=0)
        floor_piece("piano", [(1, 2, 90), (w - 2, 2, 270), (1, 3, 90), (w - 2, 3, 270)])
        floor_piece("telescope", [(1, h - 4), (w - 2, h - 4), (w - 2, 2)])
        rug(3, 2, centre_y=2)
        floor_piece("plant_stand", corners())
    elif kind == "castle":
        wall_block("fireplace", _near(r, xs, rng, 2.0))
        rug(2, max(3, h - 6))
        pictures(3, variant=1)
        floor_piece("display_case", [(2, 3), (w - 3, 3), (2, 5), (w - 3, 5)], variant=2)
        wall_deco("clock")
    return r.new


def guess_kind(zid, rows, props, npcs, warps, spawn, name):
    """Recover which landmark() kind made an interior by regenerating it and comparing."""
    import zlib
    w, h = len(rows[0]), len(rows)
    for k in zlib.LANDMARK_KINDS:
        z = zlib.landmark("/dev/null", zid, name, "t", (0, 0), k, [], w, h, furnish=False, write=False)
        grid = ["".join(g) for g in z.g]
        if grid == rows and all(p in props for p in z.d["props"]):
            return k
    return None


def refurnish_all(zone_dir, dry=False):
    summary = {}
    changed = 0
    for path in sorted(glob.glob(os.path.join(zone_dir, "*.json"))):
        d = json.load(open(path))
        if d.get("kind") != "interior":
            continue
        if any(p["type"] in NEW_TYPES for p in d["props"]):
            continue  # already furnished
        kind = guess_kind(d["id"], d["rows"], d["props"], d["npcs"], d["warps"], d["spawn"], d["name"])
        if kind is None:
            continue
        new = furnish(kind, d["name"], d["id"], d["rows"], d["props"], d["npcs"], d["warps"], d["spawn"], d.get("signs", []))
        summary.setdefault(kind, []).append(len(new))
        if new:
            changed += 1
            if not dry:
                d["props"].extend(new)
                json.dump(d, open(path, "w"), indent=1)
    for k, v in sorted(summary.items()):
        print("%-9s %3d zones, %.1f new props each" % (k, len(v), sum(v) / len(v)))
    print("changed", changed)


if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    sys.path.insert(0, here)
    refurnish_all(sys.argv[1], dry="--dry" in sys.argv)
