# Shared helpers for the South East (Sussex and Kent) zones off London: wave 21, region "south_east".
from ie_common import *
from wcommon import _stand
from zlib import landmark

SE = "south_east"
FLOOR = 94   # London's band: every zone and trainer here is scaled from this par (see core/par_level.gd)
LV = (94, 96)

# Kent and Sussex ground: paler downland turf, chalk cliffs with white faces, chalk tracks and cropped grass.
CHALK = {"tile": "cliff", "colour": "#e8e4d6", "side": "#efece2"}
CHALK_PATH = {"tile": "path", "colour": "#ece7da"}
DOWN_TURF = {"tile": "grass", "colour": "#7f9f52"}
SHORT = {"tile": "tall_grass", "colour": "#7a9a4c", "prop": "short"}
SHINGLE = {"tile": "sand", "colour": "#a39d90"}


def se_say(who, *lines):
    return say(who, *lines)


def setf(flag, value=True):
    return {"do": "set", "flag": flag, "value": value}


def IF(flag, then, els=None, eq=None):
    c = {"do": "if", "flag": flag, "then": then, "else": els or []}
    if eq is not None:
        c["eq"] = eq
    return c


def give(item, n=1):
    return {"do": "give_item", "item": item, "n": n}


def fight(tid):
    return {"do": "battle", "trainer": tid}


def standing(n):
    return {"do": "standing", "nation": "england", "amount": n}


def plaque(z, x, y, pid, title, text):
    """a heritage plaque (collected by the Gazetteer): ids are unique across the game."""
    z.d["signs"].append({"x": x, "y": y, "text": text, "plaque": pid, "title": title})


def sign(z, x, y, text):
    z.d["signs"].append({"x": x, "y": y, "text": text})


def talker(zid, nid, sprite, x, y, who, lines, facing="down", move="still", **kw):
    """an NPC dict for an interior (or anywhere) whose script is a run of lines."""
    DLG.setdefault(zid, {})[nid] = say(who, *lines)
    d = {"id": nid, "sprite": sprite, "x": x, "y": y, "facing": facing, "move": move, "script": nid, "name": who}
    d.update(kw)
    return d


def scripted(zid, nid, sprite, x, y, who, cmds, facing="down", move="still", **kw):
    DLG.setdefault(zid, {})[nid] = cmds
    d = {"id": nid, "sprite": sprite, "x": x, "y": y, "facing": facing, "move": move, "script": nid, "name": who}
    d.update(kw)
    return d


def tdef(tid, name, cls, sprite, party, intro, win, after, money, **kw):
    """a trainer's data (scaled from FLOOR); place it with tnpc() or fight it from a script."""
    t = {"id": tid, "name": name, "class": cls, "sprite": sprite,
         "party": [p if isinstance(p, dict) else {"species": p[0], "level": p[1]} for p in party], "ai": "trainer",
         "money": money, "intro": say(name, *intro), "win": win, "after": after, "scaled_floor": FLOOR}
    t.update(kw)
    TRN[tid] = t
    return t


def tnpc(z, tid, x, y, facing, move="still"):
    _stand(z, x, y)
    z.npc(id=tid, sprite=TRN[tid]["sprite"], x=x, y=y, facing=facing, move=move, trainer=tid)


def room(out, town, zid, name, door, kind, npcs, w=13, h=10, edit=None, extra_props=(), furnish=True):
    """a walk-in interior behind the town door at `door`; returns the arrival tile for the town's warp."""
    z = landmark(out, zid, name, town, (door[0], door[1] + 1), kind, npcs, w, h, furnish=furnish, write=False)
    for p in extra_props:
        z.d["props"] = [q for q in z.d["props"] if not (q["x"] == p["x"] and q["y"] == p["y"] and q["type"] != "rug")]
        z.d["props"].append(p)
    if edit:
        edit(z)
    z.save(out + "/" + zid + ".json")
    return (w // 2, h - 3)


def door_to(z, out, town, zid, name, door, kind, npcs, **kw):
    arr = room(out, town, zid, name, door, kind, npcs, **kw)
    z.warp(door[0], door[1], zid, arr[0], arr[1], "up")


def P(t, x, y, **kw):
    d = {"type": t, "x": x, "y": y}
    d.update(kw)
    return d


WALK = set(".,#=:sf_D|+&wgkcqpjy")


def smooth_walk(z, passes=20):
    """walkable neighbours differ by at most one height level; cliffs, sea and walls may drop further."""
    def ok(ch):
        return ch not in "^k$~oTPHWFBRh!r%"
    for _ in range(passes):
        ch = False
        for y in range(z.h):
            for x in range(z.w):
                for dx, dy in ((1, 0), (0, 1)):
                    xx, yy = x + dx, y + dy
                    if xx < z.w and yy < z.h and ok(z.g[y][x]) and ok(z.g[yy][xx]):
                        a, b = z.hg[y][x], z.hg[yy][xx]
                        if a - b > 1:
                            z.hg[y][x] = b + 1; ch = True
                        elif b - a > 1:
                            z.hg[yy][xx] = a + 1; ch = True
        if not ch:
            break


def scale_zone(z):
    z.d["scaled_floor"] = FLOOR
