# Shared helpers for the 3.3 "Overseas" territory generators (wave 33). Every zone and trainer is scaled from FLOOR.
import os, json, re, sys, importlib.util
# this directory's zlib.py (the zone-builder library) shadows nothing in Python builds where zlib is built in, so load it by path
_spec = importlib.util.spec_from_file_location("zlib", os.path.join(os.path.dirname(os.path.abspath(__file__)), "zlib.py"))
_zl = importlib.util.module_from_spec(_spec)
sys.modules["zlib"] = _zl
_spec.loader.exec_module(_zl)
from p6a_common import *
from wcommon import _stand
from zlib import landmark
from sc_common import mound

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
FLOOR = 95
HOME_ZONE = "raf_brize_norton"   # agent 1's RAF hub; the flight home is only wired once its zone file exists
HOME_AT = (20, 20)               # TODO(merge): set to the terminal's arrival tile in data/zones/raf_brize_norton.json


def have_home():
    return os.path.exists(os.path.join(ROOT, "data", "zones", HOME_ZONE + ".json"))


def have_nation():
    return '"overseas"' in open(os.path.join(ROOT, "core", "standing.gd")).read()


def plaque(z, x, y, pid, title, text):
    _stand(z, x, y)
    z.d["signs"].append({"x": x, "y": y, "plaque": pid, "title": title, "text": text})


def npc(id, sprite, x, y, script=None, facing="down", move="still", name=None, **kw):
    d = {"id": id, "sprite": sprite, "x": x, "y": y, "facing": facing, "move": move}
    if script:
        d["script"] = script
    if name:
        d["name"] = name
    d.update(kw)
    return d


def cmd_if(flag, then, els=None, eq=None):
    c = {"do": "if", "flag": flag, "then": then}
    if els is not None:
        c["else"] = els
    if eq is not None:
        c["eq"] = eq
    return c


def setf(flag, value=True):
    return {"do": "set", "flag": flag, "value": value}


def give(item, n=1):
    return {"do": "give_item", "item": item, "n": n}


def choice(text, options, flag):
    return {"do": "choice", "text": text, "options": options, "set": flag}


def when(cond, then, els=None):
    c = {"do": "when", "cond": cond, "then": then}
    if els is not None:
        c["else"] = els
    return c


def standing(amount=2):
    return [{"do": "standing", "nation": "overseas", "amount": amount}] if have_nation() else []


def battle(tid):
    return {"do": "battle", "trainer": tid, "intro": True}


def wild_set(z, rows, kind="grass"):
    wild(z, [(sp, FLOOR, FLOOR + 1, wt, extra) for (sp, wt, extra) in rows], kind)


def scaled(tids):
    for t in tids:
        TRN[t]["scaled_floor"] = FLOOR


def door_to(z, bx, by, bw, bh, dx, style, label, zid, w=13, h=10):
    """a building with a door on its bottom row, warping into interior `zid`; returns the tile below the door."""
    z.building(bx, by, bw, bh, style, label, door=dx)
    z.warp(bx + dx, by + bh - 1, zid, w // 2, h - 3, "up")
    return (bx + dx, by + bh)


def town_buildings(z, zid, sanct, shopx):
    """Sanctuary and shop doors: sanct = (x, y, style), shopx = (x, y, style); returns the two return tiles."""
    sx, sy, sstyle = sanct
    z.building(sx, sy, 6, 4, sstyle, "Sanctuary", door=3)
    z.warp(sx + 3, sy + 3, zid + "_sanctuary", 5, 6, "up")
    hx, hy, hstyle = shopx
    z.building(hx, hy, 5, 4, hstyle, "Shop", door=2)
    z.warp(hx + 2, hy + 3, zid + "_shop", 4, 5, "up")
    return (sx + 3, sy + 4), (hx + 2, hy + 4)


def interior(OUT, zid, name, town, ret, kind, npcs, w=13, h=10, props=(), signs=(), rows=None):
    z = landmark(OUT, zid, name, town, ret, kind, npcs, w=w, h=h, write=False)
    for (t, x, y, kw) in props:
        clear_prop(z, x, y)
        z.prop(t, x, y, **kw)
    for (x, y, text) in signs:
        z.d["signs"].append({"x": x, "y": y, "text": text})
    if rows:
        for (x, y, w2, h2, ch) in rows:
            z.rect(x, y, w2, h2, ch)
    finish(z)
    z.save(OUT + "/" + zid + ".json")
    return z


def sanctuary_and_shop(OUT, zid, tname, ret_s, ret_h, nurse_lines, shop_lines, stock, music_shop=""):
    sanctuary(OUT, zid, tname, ret_s)
    shop(OUT, zid, tname, ret_h)
    nurse(zid, nurse_lines)
    shopkeeper(zid, *shop_lines)
    json.dump({"id": zid + "_corner_shop", "name": tname + " Shop", "stock": stock},
              open(ROOT + "/data/shops/" + zid + "_corner_shop.json", "w"), indent=1)
    # the Retired Keeper every Sanctuary has (see add_memory_coach.py)
    p = OUT + "/" + zid + "_sanctuary.json"
    d = json.load(open(p))
    if not any(n.get("id") == "memory_coach" for n in d["npcs"]):
        d["npcs"].append({"id": "memory_coach", "sprite": "poet", "x": 8, "y": 4, "facing": "down", "move": "still",
                          "script": "memory_coach", "name": "Retired Keeper"})
    json.dump(d, open(p, "w"), indent=1, ensure_ascii=False)


def check(z):
    """warn about signs, NPCs and warps standing inside a building, or on water or rock."""
    rects = [(p["x"], p["y"], p["w"], p["h"]) for p in z.d["props"] if p["type"] == "building"]
    pts = [(s["x"], s["y"], "sign") for s in z.d["signs"]] + [(n["x"], n["y"], n["id"]) for n in z.d["npcs"]]
    for (x, y, what) in pts:
        for (bx, by, bw, bh) in rects:
            if bx <= x < bx + bw and by <= y < by + bh:
                print("  WARN %s: %s at (%d,%d) is inside a building" % (z.d["id"], what, x, y))
        if z.g[y][x] in "$~oRTP^":
            print("  WARN %s: %s at (%d,%d) is on %s" % (z.d["id"], what, x, y, z.g[y][x]))


def return_npc(z, zid, x, y, sprite, who, text, line, facing="down", name=None, flight=True):
    """the airfield or harbour hand who sends you home. Needs the RAF hub's zone; until it exists he only talks."""
    _stand(z, x, y)
    z.npc(id=zid + "_return", sprite=sprite, x=x, y=y, facing=facing, move="still", script=zid + "_return", name=name or who)
    cmds = say(who, text)
    if have_home():
        cmds += [choice("Head home to RAF Brize Norton?", ["Yes, take me home", "Not yet"], "_home_choice"),
                 cmd_if("_home_choice", say(who, line) + [{"do": "fade_out"}, {"do": "warp", "zone": HOME_ZONE, "x": HOME_AT[0], "y": HOME_AT[1], "facing": "down"}],
                        say(who, "Whenever you're ready. The seat will keep."), eq=0)]
    script(zid, zid + "_return", cmds)


def finish_zone(z):
    for w in z.d["warps"]:
        clear_prop(z, w["x"], w["y"] + 1)          # keep every doorstep clear of scattered scenery
    finish(z)
    check(z)


def sa_write_json(path, obj):
    json.dump(obj, open(ROOT + "/" + path, "w"), indent=1, ensure_ascii=False)


def write_registry(rid, name, zone, x, y, via, blurb, flight_line, port=""):
    d = {"id": rid, "name": name, "arrival": {"zone": zone, "x": x, "y": y}, "via": via, "port": port,
         "unlock_flag": "champion", "blurb": blurb, "flight_line": flight_line}
    os.makedirs(ROOT + "/data/overseas", exist_ok=True)
    sa_write_json("data/overseas/%s.json" % rid, d)


def write_quests(rid, quests):
    sa_write_json("data/quests/overseas_%s.json" % rid, {"quests": quests})


def write_items(name, items):
    sa_write_json("data/items/%s.json" % name, items)


def heal_item(id, name, price, amount, desc):
    return {"id": id, "name": name, "kind": "heal", "price": price, "battle": True, "field": True, "amount": amount, "desc": desc}


def charm_item(id, name, desc, effect_text, charm, msg, price=0):
    return {"id": id, "name": name, "kind": "charm", "price": price, "battle": False, "field": True, "wild": False, "desc": desc,
            "effect_text": effect_text, "charm": charm, "msg": msg}


def key_item(id, name, desc):
    return {"id": id, "name": name, "kind": "key", "price": 0, "battle": False, "field": True, "desc": desc}


def append_quiz(region, qs):
    """append quiz questions (cat, q, a, wrong[3], fact) to data/quiz/questions.json by text insertion."""
    p = ROOT + "/data/quiz/questions.json"
    txt = open(p).read()
    add = []
    for (cat, q, a, wrong, fact) in qs:
        if json.dumps(q) in txt:
            continue
        add.append(json.dumps({"cat": cat, "region": region, "q": q, "a": a, "wrong": wrong, "fact": fact}, ensure_ascii=False))
    if add:
        body = txt.rstrip()
        assert body.endswith("]")
        open(p, "w").write(body[:-1].rstrip() + ", " + ", ".join(add) + "]\n")
