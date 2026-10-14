# Shared helpers for the Mid and South Wales zone scripts (wales_south.py and the ws_*.py parts).
import sys, json, math, random, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from zlib import Z, sanctuary, shop

DLG = {}   # zone id -> {script id: [commands]}
TRN = {}   # trainer id -> trainer json


def say(who, *lines):
    return [{"do": "say", "who": who, "text": t} for t in lines]


def _stand(z, x, y):
    """make sure an NPC's tile is walkable and free of props."""
    clear_prop(z, x, y)
    if z.g[y][x] in "RPT^BH~$o/!%WF":
        z.set(x, y, "k" if "k" in z.legend else ".")


def chat(z, nid, sprite, x, y, who, lines, facing="down", move="still"):
    _stand(z, x, y)
    z.npc(id=nid, sprite=sprite, x=x, y=y, facing=facing, move=move, script=nid)
    DLG.setdefault(z.d["id"], {})[nid] = say(who, *lines)


def script(zid, key, cmds):
    DLG.setdefault(zid, {})[key] = cmds


def trainer(z, tid, name, cls, sprite, party, x, y, facing, intro, win, after, money, move="still"):
    _stand(z, x, y)
    z.npc(id=tid, sprite=sprite, x=x, y=y, facing=facing, move=move, trainer=tid)
    TRN[tid] = {"id": tid, "name": name, "class": cls, "sprite": sprite,
                "party": [{"species": s, "level": l} for s, l in party], "ai": "trainer", "money": money,
                "intro": say(name, *intro), "win": win, "after": after}


def path(z, pts, ch="#", w=1):
    """thick polyline through axis-aligned points; w extends right/down."""
    for (x1, y1), (x2, y2) in zip(pts, pts[1:]):
        z.rect(min(x1, x2), min(y1, y2), abs(x2 - x1) + w, abs(y2 - y1) + w, ch)


def wild(z, rows, name="grass"):
    z.d["encounters"].setdefault(name, [])
    for (sp, lo, hi, wt, extra) in rows:
        e = {"species": sp, "min": lo, "max": hi, "weight": wt}
        e.update(extra)
        z.d["encounters"][name].append(e)


def scatter_props(z, kind, x, y, w, h, n, seed, variants=3, avoid=(".", ",", "s"), **kw):
    r = random.Random(seed)
    done = tries = 0
    taken = {(p["x"], p["y"]) for p in z.d["props"]}
    while done < n and tries < n * 40:
        tries += 1
        xx, yy = r.randrange(x, x + w), r.randrange(y, y + h)
        if 0 <= xx < z.w and 0 <= yy < z.h and z.g[yy][xx] in avoid and (xx, yy) not in taken:
            z.prop(kind, xx, yy, variant=r.randrange(variants), **kw)
            taken.add((xx, yy))
            done += 1


def clear_prop(z, x, y):
    z.d["props"] = [p for p in z.d["props"] if not (p["x"] == x and p["y"] == y and p["type"] != "building")]


def station(z, x, y, w, door, label):
    """station building (h=2) at x,y; platform row under it, rail below that. Returns the platform tile."""
    z.building(x, y, w, 2, "station", label, door=door)
    z.rect(x, y + 2, w, 1, "_")
    z.rect(x - 1, y + 3, w + 2, 1, "!")
    z.d["station"] = {"x": x + door, "y": y + 2}
    return (x + door, y + 2)


def rail_guard(z, x, y, lines, facing="right"):
    z.npc(id="rail_guard", sprite="rail_guard", x=x, y=y, facing=facing, move="still", script="rail_guard")
    script(z.d["id"], "rail_guard", say("Rail Guard", *lines) + [{"do": "rail"}])


def sea(z, edge, y0, y1):
    """west sea: open sea up to edge(y)-2, a shallow fringe at edge(y)-1."""
    for y in range(y0, y1):
        e = edge(y)
        for x in range(0, e - 1):
            z.set(x, y, "$")
        z.set(e - 1, y, "w")


def beach(z, edge, y0, y1, sand=3, dune=6):
    for y in range(y0, y1):
        e = edge(y)
        for x in range(e, e + sand):
            z.set(x, y, "s")
        for x in range(e + sand, e + sand + dune):
            z.set(x, y, ",")


def nurse(town, name_lines):
    cmds = [{"do": "say", "who": "Nurse", "text": name_lines[0]},
            {"do": "choice", "text": "What can we do for you?", "options": ["Heal my team", "Open the Ark", "Just looking"], "set": "_nurse_choice"},
            {"do": "if", "flag": "_nurse_choice", "eq": 0,
             "then": [{"do": "say", "who": "Nurse", "text": name_lines[1]}, {"do": "heal"}, {"do": "say", "who": "Nurse", "text": name_lines[2]}],
             "else": [{"do": "if", "flag": "_nurse_choice", "eq": 1,
                       "then": [{"do": "say", "who": "Nurse", "text": name_lines[3]}, {"do": "ark"}],
                       "else": [{"do": "say", "who": "Nurse", "text": name_lines[4]}]}]}]
    DLG[town + "_sanctuary"] = {"nurse": cmds}


def shopkeeper(town, a, b):
    DLG[town + "_shop"] = {"shopkeeper": say("Shopkeeper", a) + [{"do": "shop", "id": town + "_corner_shop"}] + say("Shopkeeper", b)}


def write_all(out):
    root = os.path.dirname(os.path.dirname(os.path.abspath(out)))
    os.makedirs(os.path.join(root, "data", "dialogue"), exist_ok=True)
    os.makedirs(os.path.join(root, "data", "trainers"), exist_ok=True)
    for zid, d in DLG.items():
        json.dump(d, open(os.path.join(root, "data", "dialogue", zid + ".json"), "w"), indent=1)
    for tid, t in TRN.items():
        json.dump(t, open(os.path.join(root, "data", "trainers", tid + ".json"), "w"), indent=1)
