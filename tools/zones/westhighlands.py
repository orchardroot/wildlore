#!/usr/bin/env python3
"""West Highlands region (3.0 wave 21): Loch Lomond, Oban, Tobermory, Staffa, Iona; three new creature lines,
items, shops, quests, quiz, map entries. Run from the repo root:  python3 tools/zones/westhighlands.py

Writes new files, and applies small additive edits to shared files (idempotent: each edit checks first).
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
import wh_lib
from wh_lib import ROOT, write_all
import wh_loch
import wh_oban
import wh_tober


def path(*p):
    return os.path.join(ROOT, *p)


def jdump(obj, *p, indent=1):
    with open(path(*p), "w") as f:
        json.dump(obj, f, indent=indent, ensure_ascii=False)
        f.write("\n")


def edit(rel, old, new, marker=None):
    s = open(path(rel)).read()
    if (marker or new) in s:
        return
    assert old in s, (rel, old[:40])
    open(path(rel), "w").write(s.replace(old, new, 1))


# ---------------------------------------------------------------- creatures
def sp(sid, name, types, base, catch, xp, learn, evolves, habitat, text, fact, knack_sprite=None):
    return {"id": sid, "name": name, "types": types, "base": dict(zip(["hp", "atk", "def", "lore", "ward", "spd"], base)),
            "growth": "medium", "catch_rate": catch, "base_xp": xp, "learnset": learn, "evolves": evolves,
            "habitat": habitat, "appendix": True, "dex": {"text": text, "fact": fact}, "sprite": sid}


CREATURES = {
    "staffling": [
        sp("staffling", "Staffling", ["stone", "storm"], (55, 62, 62, 40, 38, 43), 170, 60,
           [[1, "pebble_flick"], [1, "static_snap"], [5, "grit_in_eye"], [9, "hail_pelt"], [13, "boulder_bump"], [17, "wind_shear"],
            [21, "hard_hat"], [26, "thunderclap"], [31, "rip_current"], [36, "megalith_mutter"], [42, "ball_lightning"], [48, "minch_squall"]],
           {"to": "fingalith", "level": 30}, ["staffa_cave"],
           "A stack of tidy six-sided columns with a grumpy cloud on top. It hums when the swell comes in, and loses patience when you hum back.",
           "Staffa's basalt columns formed about 60 million years ago when lava cooled and cracked into hexagons, the same process that built the Giant's Causeway."),
        sp("fingalith", "Fingalith", ["stone", "storm"], (85, 100, 98, 60, 62, 70), 60, 168,
           [[1, "pebble_flick"], [1, "static_snap"], [5, "grit_in_eye"], [9, "hail_pelt"], [13, "boulder_bump"], [17, "wind_shear"],
            [21, "hard_hat"], [26, "thunderclap"], [31, "rip_current"], [36, "megalith_mutter"], [42, "ball_lightning"], [48, "minch_squall"],
            [54, "bolt_from_the_blue"]],
           None, ["staffa_cave"],
           "A whole cathedral of basalt that has learnt to walk. Every wave that rolls through it comes out as a chord, and a faintly smug one.",
           "In 1829 the composer Felix Mendelssohn visited Fingal's Cave on Staffa, and its echoing arches inspired the opening of his Hebrides Overture."),
    ],
    "lekling": [
        sp("lekling", "Lekling", ["brawn", "hedgerow"], (62, 68, 50, 28, 42, 55), 180, 60,
           [[1, "shove"], [1, "glower"], [5, "flex"], [9, "nettle_sting"], [13, "scrum_push"], [17, "bramble_lash"], [21, "terrace_roar"],
            [24, "swoop"], [28, "strongmans_yell"], [33, "hawthorn_hammer"], [38, "caber_toss"], [44, "haymaker"]],
           {"to": "lekbruiser", "level": 27}, ["loch_lomond", "oban", "tobermory"],
           "A stout dark grouse that struts in tight circles and challenges anything that moves, including the wind and its own reflection.",
           "Capercaillie is from the Gaelic capall-coille, 'horse of the wood'. The males gather at a lek in spring to display, and have been known to attack walkers."),
        sp("lekbruiser", "Lekbruiser", ["brawn", "hedgerow"], (96, 118, 82, 42, 66, 80), 60, 170,
           [[1, "shove"], [1, "glower"], [5, "flex"], [9, "nettle_sting"], [13, "scrum_push"], [17, "bramble_lash"], [21, "terrace_roar"],
            [24, "swoop"], [28, "strongmans_yell"], [33, "hawthorn_hammer"], [38, "caber_toss"], [44, "haymaker"], [50, "pit_pony_charge"]],
           None, [],
           "The size of a turkey and twice as sure of itself. It has won the Heavy Events at the Oban Games every year, mostly by looking at the other entrants.",
           "Capercaillie were hunted out of Scotland by the 1780s and reintroduced from Sweden in 1837. Today they are rare again, with only a few hundred left."),
    ],
    "cailleach": [
        sp("cailleach", "Cailleach", ["frost", "tide"], (95, 55, 80, 118, 92, 50), 25, 250,
           [[1, "snow_flick"], [1, "rip_current"], [5, "rime_breath"], [9, "sea_fret"], [14, "hoarfrost"], [19, "undertow"], [24, "sleet_shower"],
            [30, "haar_chill"], [36, "spring_tide"], [42, "whiteout"], [48, "moon_pull"], [54, "the_haar"], [60, "black_ice_skid"]],
           None, [],
           "The old wash-woman of winter. She scrubs her plaid in the whirlpool until it comes out white, and that is the first frost. Speaks to you as if you were a very promising lamb.",
           "The Corryvreckan whirlpool between Jura and Scarba can be heard from miles away. In 1947 George Orwell and his family nearly drowned there when their boat was caught."),
    ],
}
KNACKS = {"staffling": "storm_chaser", "fingalith": "storm_chaser", "lekling": "cocky", "lekbruiser": "cocky", "cailleach": "frost_hardy"}


def recipes():
    R = {}
    R["staffling"] = {
        "id": "staffling",
        "palette": {"bas": "#4a4e58", "bas2": "#33363e", "top": "#6c7280", "bolt": "#ffe040", "cloud": "#8e98aa", "cloud2": "#6c7688",
                    "sea": "#3a6a8a", "ink": "#101216", "eye": "#f0f2f4", "foam": "#d8e8f0"},
        "layers": [
            {"shape": "ellipse", "at": [48, 90], "size": [74, 8], "colour": "sea", "rim": False, "shade": False},
            {"shape": "rect", "at": [28, 68], "size": [16, 40], "colour": "bas", "round": 1, "pattern": "stripes", "pcolour": "bas2", "period": 6, "pangle": 90},
            {"shape": "rect", "at": [68, 70], "size": [16, 36], "colour": "bas", "round": 1, "pattern": "stripes", "pcolour": "bas2", "period": 6, "pangle": 90},
            {"shape": "rect", "at": [48, 62], "size": [22, 54], "colour": "bas", "round": 1, "pattern": "stripes", "pcolour": "bas2", "period": 7, "pangle": 90},
            {"shape": "ellipse", "at": [28, 48], "size": [16, 6], "colour": "top"},
            {"shape": "ellipse", "at": [68, 52], "size": [16, 6], "colour": "top"},
            {"shape": "ellipse", "at": [48, 35], "size": [22, 7], "colour": "top"},
            {"shape": "ellipse", "at": [48, 82], "size": [60, 8], "colour": "foam", "rim": False, "shade": False, "pattern": "speckle", "pcolour": "sea", "density": 10},
            {"shape": "ellipse", "at": [48, 20], "size": [48, 18], "colour": "cloud", "pattern": "speckle", "pcolour": "cloud2", "density": 14},
            {"shape": "ellipse", "at": [30, 24], "size": [22, 14], "colour": "cloud"},
            {"shape": "ellipse", "at": [66, 24], "size": [24, 14], "colour": "cloud"},
            {"shape": "poly", "points": [[50, 28], [42, 40], [48, 40], [44, 50], [56, 36], [50, 36]], "colour": "bolt", "shade": False, "rim": False},
        ],
        "face_layers": [{"shape": "line", "points": [[42, 66], [48, 69], [54, 66]], "width": 1.4, "colour": "ink", "shade": False},
                        {"shape": "line", "points": [[39, 55], [46, 58]], "width": 2, "colour": "ink", "shade": False, "mirror": True}],
        "eyes": [{"at": [42, 60], "r": 4, "colour": "eye", "pupil": [2, 3], "mirror": True}],
        "back_marks": [{"shape": "rect", "at": [48, 64], "size": [12, 40], "colour": "bas2", "rim": False, "under": True}],
    }
    R["fingalith"] = {
        "id": "fingalith",
        "palette": {"bas": "#454952", "bas2": "#2e3138", "top": "#666c7a", "bolt": "#ffe650", "sea": "#3a6a8a", "sea2": "#8cc0dc",
                    "dark": "#12141a", "ink": "#0c0e12", "eye": "#ffe650", "foam": "#d8e8f0"},
        "layers": [
            {"shape": "ellipse", "at": [48, 91], "size": [88, 8], "colour": "sea", "rim": False, "shade": False},
            {"shape": "rect", "at": [14, 66], "size": [14, 50], "colour": "bas", "round": 1, "pattern": "stripes", "pcolour": "bas2", "period": 6, "pangle": 90},
            {"shape": "rect", "at": [82, 66], "size": [14, 50], "colour": "bas", "round": 1, "pattern": "stripes", "pcolour": "bas2", "period": 6, "pangle": 90},
            {"shape": "rect", "at": [27, 58], "size": [14, 62], "colour": "bas", "round": 1, "pattern": "stripes", "pcolour": "bas2", "period": 6, "pangle": 90},
            {"shape": "rect", "at": [69, 58], "size": [14, 62], "colour": "bas", "round": 1, "pattern": "stripes", "pcolour": "bas2", "period": 6, "pangle": 90},
            {"shape": "poly", "points": [[22, 30], [34, 14], [62, 14], [74, 30], [74, 52], [22, 52]], "colour": "bas", "pattern": "stripes", "pcolour": "bas2", "period": 6, "pangle": 90},
            {"shape": "poly", "points": [[34, 40], [38, 26], [58, 26], [62, 40], [62, 84], [34, 84]], "colour": "dark", "rim": False},
            {"shape": "ellipse", "at": [48, 82], "size": [34, 8], "colour": "sea2", "rim": False, "shade": False, "pattern": "stripes", "pcolour": "sea", "period": 4, "pangle": 0},
            {"shape": "poly", "points": [[48, 18], [40, 32], [46, 32], [42, 44], [54, 28], [48, 28]], "colour": "bolt", "shade": False, "rim": False},
            {"shape": "ellipse", "at": [48, 14], "size": [40, 8], "colour": "top"},
        ],
        "face_layers": [{"shape": "line", "points": [[40, 60], [48, 64], [56, 60]], "width": 1.6, "colour": "ink", "shade": False}],
        "eyes": [{"at": [41, 52], "r": 4, "colour": "eye", "pupil": [2, 3], "mirror": True}],
        "back_marks": [{"shape": "rect", "at": [48, 52], "size": [30, 40], "colour": "bas2", "rim": False, "under": True, "pattern": "stripes", "pcolour": "bas", "period": 5, "pangle": 90}],
    }
    R["lekling"] = {
        "id": "lekling",
        "palette": {"body": "#2c3038", "body2": "#444a56", "breast": "#2e5a44", "red": "#d02a24", "beak": "#e8e0c8", "tail": "#20242c", "tail2": "#cfd3da",
                    "leg": "#8a5a3a", "grass": "#6a8a3c", "ink": "#0e1014", "eye": "#f0f2f4"},
        "layers": [
            {"shape": "ellipse", "at": [48, 90], "size": [60, 6], "colour": "grass", "rim": False, "shade": False},
            {"shape": "poly", "points": [[48, 60], [10, 24], [28, 10], [48, 6], [68, 10], [86, 24]], "colour": "tail", "pattern": "stripes", "pcolour": "tail2", "period": 6, "pangle": 90},
            {"shape": "line", "points": [[40, 88], [38, 76]], "width": 3, "colour": "leg", "shade": False, "mirror": True},
            {"shape": "ellipse", "at": [48, 66], "size": [46, 40], "colour": "body", "pattern": "speckle", "pcolour": "body2", "density": 16},
            {"shape": "ellipse", "at": [48, 68], "size": [28, 26], "colour": "breast", "rim": False, "front_only": True},
            {"shape": "ellipse", "at": [48, 38], "size": [26, 24], "colour": "body", "pattern": "speckle", "pcolour": "body2", "density": 14},
            {"shape": "ellipse", "at": [38, 33], "size": [8, 4], "colour": "red", "rim": False, "front_only": True, "mirror": True},
            {"shape": "poly", "points": [[42, 40], [48, 52], [54, 40]], "colour": "beak", "front_only": True},
        ],
        "face_layers": [{"shape": "line", "points": [[36, 38], [42, 40]], "width": 2.4, "colour": "ink", "shade": False, "mirror": True}],
        "eyes": [{"at": [40, 36], "r": 3.2, "colour": "eye", "pupil": [2, 2], "mirror": True}],
        "back_marks": [{"shape": "ellipse", "at": [48, 62], "size": [36, 32], "colour": "body2", "rim": False, "under": True}],
    }
    R["lekbruiser"] = json.loads(json.dumps(R["lekling"]).replace('"lekling"', '"lekbruiser"'))
    lb = R["lekbruiser"]
    lb["layers"][1] = {"shape": "poly", "points": [[48, 64], [2, 30], [18, 4], [48, 0], [78, 4], [94, 30]], "colour": "tail", "pattern": "stripes", "pcolour": "tail2", "period": 6, "pangle": 90}
    lb["layers"][3] = {"shape": "ellipse", "at": [48, 68], "size": [64, 50], "colour": "body", "pattern": "speckle", "pcolour": "body2", "density": 16}
    lb["layers"][4] = {"shape": "ellipse", "at": [48, 70], "size": [40, 34], "colour": "breast", "rim": False, "front_only": True}
    lb["layers"][5] = {"shape": "ellipse", "at": [48, 36], "size": [32, 28], "colour": "body", "pattern": "speckle", "pcolour": "body2", "density": 14}
    lb["layers"][6] = {"shape": "ellipse", "at": [36, 30], "size": [11, 5], "colour": "red", "rim": False, "front_only": True, "mirror": True}
    lb["layers"][7] = {"shape": "poly", "points": [[40, 38], [48, 54], [56, 38]], "colour": "beak", "front_only": True}
    lb["eyes"] = [{"at": [39, 33], "r": 3.6, "colour": "eye", "pupil": [2, 2], "mirror": True}]
    lb["face_layers"] = [{"shape": "line", "points": [[32, 33], [41, 38]], "width": 3, "colour": "ink", "shade": False, "mirror": True}]
    R["cailleach"] = {
        "id": "cailleach",
        "palette": {"plaid": "#eef2f6", "plaid2": "#b8cde0", "cloak": "#44587a", "cloak2": "#2c3c58", "skin": "#c8d4dc", "hair": "#f4f8fc",
                    "water": "#3e7898", "water2": "#9ccce4", "foam": "#e4f0f8", "staff": "#6a4a30", "ink": "#101820", "eye": "#9ae0ff"},
        "layers": [
            {"shape": "ellipse", "at": [48, 88], "size": [88, 14], "colour": "water", "pattern": "stripes", "pcolour": "water2", "period": 5, "pangle": 20},
            {"shape": "ellipse", "at": [48, 88], "size": [56, 8], "colour": "foam", "rim": False, "shade": False, "pattern": "stripes", "pcolour": "water2", "period": 4, "pangle": -20},
            {"shape": "line", "points": [[82, 84], [80, 14]], "width": 3, "colour": "staff", "shade": False},
            {"shape": "poly", "points": [[34, 38], [16, 84], [80, 84], [62, 38]], "colour": "cloak", "pattern": "stripes", "pcolour": "cloak2", "period": 6, "pangle": 80},
            {"shape": "poly", "points": [[34, 36], [22, 70], [40, 76], [48, 50], [58, 76], [74, 70], [62, 36]], "colour": "plaid", "pattern": "stripes", "pcolour": "plaid2", "period": 4, "pangle": 0},
            {"shape": "poly", "points": [[34, 14], [18, 56], [30, 50], [48, 8], [66, 50], [78, 56], [62, 14]], "colour": "hair"},
            {"shape": "ellipse", "at": [48, 28], "size": [24, 28], "colour": "skin"},
            {"shape": "poly", "points": [[40, 12], [44, 2], [48, 10], [52, 2], [56, 12]], "colour": "foam", "rim": False},
        ],
        "face_layers": [{"shape": "line", "points": [[43, 38], [48, 40], [53, 38]], "width": 1.2, "colour": "ink", "shade": False},
                        {"shape": "line", "points": [[38, 24], [45, 27]], "width": 2.2, "colour": "ink", "shade": False, "mirror": True}],
        "eyes": [{"at": [42, 29], "r": 3, "colour": "eye", "pupil": [1.5, 2], "mirror": True}],
        "back_marks": [{"shape": "poly", "points": [[34, 36], [22, 80], [74, 80], [62, 36]], "colour": "plaid", "rim": False, "under": True, "pattern": "stripes", "pcolour": "plaid2", "period": 4, "pangle": 0}],
    }
    return R


def write_creatures():
    for line, lst in CREATURES.items():
        jdump({"line": line, "species": lst}, "data", "creatures", line + ".json", indent=2)
    for sid, r in recipes().items():
        jdump(r, "art", "recipes", "creatures", sid + ".json", indent=1)
    order = path("data", "dex_order.json")
    s = open(order).read()
    ids = [x["id"] for lst in CREATURES.values() for x in lst]
    new = [i for i in ids if '"%s"' % i not in s]
    if new:
        s = s.rstrip()
        assert s.endswith("]")
        s = s[:-1].rstrip() + "".join(',\n  "%s"' % i for i in new) + "\n]\n"
        open(order, "w").write(s)
    k = path("data", "knacks.json")
    s = open(k).read()
    add = [(i, KNACKS[i]) for i in ids if '"%s":' % i not in s]
    if add:
        tail = '"zigzlet": "cocky"\n  }\n}'
        assert tail in s
        s = s.replace(tail, '"zigzlet": "cocky",\n' + ",\n".join('    "%s": "%s"' % a for a in add) + "\n  }\n}")
        open(k, "w").write(s)


# ---------------------------------------------------------------- items, shops, quests, quiz
ITEMS = [
    {"id": "oban_scallops", "name": "Oban Scallops", "kind": "heal", "price": 520, "battle": True, "field": True, "amount": 160,
     "desc": "Hand-dived Hebridean scallops, seared in butter and eaten on the pier with a seagull watching. Restores 160 HP."},
    {"id": "mull_cheddar", "name": "Isle of Mull Cheddar", "kind": "pp", "price": 450, "battle": True, "field": True, "amount": 12,
     "desc": "A strong, crumbly cheddar made on a farm near Tobermory, and a prize winner. Restores 12 PP to every move."},
    {"id": "oban_dram", "name": "Peaty Dram", "kind": "cure", "price": 300, "battle": True, "field": True,
     "cures": ["chilled", "soaked", "asleep"],
     "desc": "A wee dram of smoky island malt, as made in a distillery older than the Union's second century. Cures chills, soaking and sleep."},
    {"id": "highland_medal", "name": "Heavy Events Medal", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": True,
     "desc": "A hefty medal from the Argyllshire Gathering, big enough to use as a doorstop. Brawn moves like it.",
     "effect_text": "Brawn moves hit 20% harder.", "charm": {"effect": "boost", "type": "brawn", "mult": 1.2},
     "msg": "{name}'s Heavy Events Medal clinked with pride!"},
    {"id": "outlaws_sporran", "name": "Outlaw's Sporran", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": True,
     "desc": "A leather purse on a chain, said to be carried by those who knew the hills better than the Duke's men did. Good for catching things.",
     "effect_text": "Raises catch rates by 20%.", "charm": {"effect": "catch", "mult": 1.2}, "msg": "{name}'s sporran jingled."},
    {"id": "cailleachs_plaid", "name": "Scrap of the Cailleach's Plaid", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": True,
     "desc": "A strip of tartan as white as snow that is never quite dry. Cold to the touch, and strangely comforting.",
     "effect_text": "Frost moves hurt it 25% less.", "charm": {"effect": "resist", "type": "frost", "mult": 0.75},
     "msg": "{name}'s plaid kept the frost off!"},
    {"id": "iona_pebble", "name": "Iona Pebble", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": True,
     "desc": "A green marble pebble from Iona's south beach. Pilgrims have carried them home for good luck for centuries.",
     "effect_text": "Survives one knockout a battle.", "charm": {"effect": "endure"}, "msg": "{name} held on thanks to its Iona Pebble!"},
    {"id": "calmac_timetable", "name": "CalMac Timetable", "kind": "key", "price": 0, "battle": False, "field": True,
     "desc": "A well-thumbed ferry timetable with a coffee ring on the cover. Nobody has ever read it all the way through."},
]
STOCK_BASE = json.load(open(path("data", "shops", "glasgow_corner_shop.json")))["stock"] if os.path.exists(path("data", "shops", "glasgow_corner_shop.json")) else []


def shops():
    jdump({"id": "oban_corner_shop", "name": "Oban Corner Shop", "stock": STOCK_BASE + ["oban_scallops", "mull_cheddar", "oban_dram"]}, "data", "shops", "oban_corner_shop.json", indent=None)
    jdump({"id": "tobermory_corner_shop", "name": "Tobermory Corner Shop", "stock": STOCK_BASE + ["mull_cheddar", "oban_dram"]}, "data", "shops", "tobermory_corner_shop.json", indent=None)
    jdump({"id": "oban_seafood", "name": "Pier Seafood Shack", "stock": ["oban_scallops", "cup_of_tea", "flask_of_tea"]}, "data", "shops", "oban_seafood.json", indent=None)


QUESTS = {"quests": [
    {"id": "westhighlands_hop", "title": "Island Hopping", "region": "westhighlands", "town": "oban", "giver": "Morag",
     "summary": "Work out the one day plan that fits a distillery tour, a Staffa boat and Iona's abbey.",
     "start_flag": "q_westhighlands_hop_started",
     "steps": [
         {"flag": "q_westhighlands_hop_1", "text": "Take the Oban ferry to Tobermory and ask the distillery guide when the tour starts.", "zone": "tobermory_distillery"},
         {"flag": "q_westhighlands_hop_2", "text": "Ask the skipper at the boat office when the Staffa boat sails.", "zone": "tobermory_boats"},
         {"flag": "q_westhighlands_hop_3", "text": "Sail to Iona and ask the pilgrim when the abbey closes.", "zone": "iona_abbey"},
         {"flag": "q_westhighlands_hop_4", "text": "Take the plan back to Morag at the CalMac terminal in Oban.", "zone": "oban_calmac"}],
     "done_flag": "q_westhighlands_hop_done", "reward": "Isle of Mull Cheddar, an Iona Pebble charm, a CalMac Timetable and Scottish standing."},
    {"id": "westhighlands_rob", "title": "Rob Roy's Outlaw Trail", "region": "westhighlands", "town": "loch_lomond", "giver": "Red Mac",
     "summary": "Follow the MacGregor outlaw's trail round Loch Lomond and face the Duke's Factor.",
     "start_flag": "q_westhighlands_rob_started",
     "steps": [
         {"flag": "q_westhighlands_rob_1", "text": "Visit Rob Roy's Cave on the east shore.", "zone": "loch_lomond_cave"},
         {"flag": "q_westhighlands_rob_2", "text": "Hear the story at Balquhidder Kirk.", "zone": "loch_lomond_kirk"},
         {"flag": "trainer_whl_factor", "text": "Beat Montrose's Factor, lurking by the loch east of the cave.", "zone": "loch_lomond"},
         {"flag": "q_westhighlands_rob_done", "text": "Report to Red Mac near Balloch.", "zone": "loch_lomond"}],
     "done_flag": "q_westhighlands_rob_done", "reward": "The Outlaw's Sporran charm and Scottish standing."},
    {"id": "westhighlands_games", "title": "The Heavy Events", "region": "westhighlands", "town": "oban", "giver": "Games Marshal",
     "summary": "Win the caber, the hammer and the stones at the Oban Highland Games.",
     "start_flag": "q_westhighlands_games_started",
     "steps": [
         {"flag": "trainer_obn_caber", "text": "Beat Fergus at the caber.", "zone": "oban"},
         {"flag": "trainer_obn_hammer", "text": "Beat Isla at the hammer.", "zone": "oban"},
         {"flag": "trainer_obn_stones", "text": "Beat Dougal at the stones.", "zone": "oban"},
         {"flag": "q_westhighlands_games_5", "text": "Collect your medal from the Games Marshal.", "zone": "oban"}],
     "done_flag": "q_westhighlands_games_done", "reward": "The Heavy Events Medal charm, tablet and Scottish standing, then a rematch with the champion."},
    {"id": "westhighlands_cailleach", "title": "The Washing of the Plaid", "region": "westhighlands", "town": "oban", "giver": "Old Hamish",
     "summary": "Hear the tale of the Corryvreckan and meet the Cailleach at the end of the pier.",
     "start_flag": "q_westhighlands_cail_started",
     "steps": [
         {"flag": "q_westhighlands_cail_1", "text": "Ask the curator at the War and Peace Museum about the Corryvreckan.", "zone": "oban_warmuseum"},
         {"flag": "caught_cailleach", "text": "Meet the Cailleach at the end of the North Pier and win her over.", "zone": "oban"},
         {"flag": "q_westhighlands_cail_3", "text": "Tell Old Hamish.", "zone": "oban"}],
     "done_flag": "q_westhighlands_cail_done", "reward": "The Cailleach joins you, plus a scrap of her plaid and two scallop suppers."},
]}

QUIZ = [
    ("scotland", "What is the Gaelic-derived name for Oban, and what does it mean?", "An t-Oban, 'the little bay'", ["An t-Oban, 'the big harbour'", "Obar, 'mouth of the river'", "An Oban, 'the stony beach'"], "Oban stands on a sheltered bay behind the island of Kerrera."),
    ("scotland", "Which folly above Oban looks like the Colosseum?", "McCaig's Tower", ["Wallace's Folly", "Dunollie Tower", "The Hermitage"], "It was built between 1897 and 1902 to give local stonemasons work."),
    ("scotland", "What is the most southerly Munro?", "Ben Lomond", ["Ben Nevis", "Ben Macdui", "Ben Vorlich"], "Ben Lomond is 974 metres high."),
    ("scotland", "Which is the largest freshwater loch in Great Britain by surface area?", "Loch Lomond", ["Loch Ness", "Loch Awe", "Loch Tay"], "Loch Ness holds more water, but Loch Lomond has the larger surface."),
    ("scotland", "Which composer was inspired by Fingal's Cave on Staffa?", "Felix Mendelssohn", ["Edward Elgar", "Ralph Vaughan Williams", "Frederick Delius"], "He visited in 1829 and wrote the Hebrides Overture."),
    ("scotland", "Which saint landed on Iona in 563?", "St Columba", ["St Andrew", "St Mungo", "St Ninian"], "He founded a monastery that became a famous centre of learning."),
    ("scotland", "The Corryvreckan whirlpool lies between Jura and which other island?", "Scarba", ["Mull", "Islay", "Lismore"], "George Orwell nearly drowned in it in 1947."),
    ("scotland", "What is a caber?", "A long, heavy pole of larch that is tossed in the Highland Games", ["A wooden bowl", "A cloth cap", "A kind of bagpipe"], "The aim is to make it flip over end to end and land pointing straight away from you."),
    ("scotland", "Which outlaw's cave is on the shore of Loch Lomond?", "Rob Roy MacGregor's", ["William Wallace's", "Bonnie Prince Charlie's", "Robert the Bruce's"], "Walter Scott wrote a novel about him in 1817."),
    ("scotland", "What is the Gaelic name for a ceilidh?", "Ceilidh, a visit or gathering", ["Slainte, a toast", "Machair, a meadow", "Bothy, a hut"], "It originally meant a visit to a neighbour's house for songs and stories."),
]


def quiz():
    q = path("data", "quiz", "questions.json")
    s = open(q).read()
    marker = "An t-Oban, 'the little bay'"
    if marker in s:
        return
    lines = ['\t{"cat": "geography", "region": "%s", "q": %s, "a": %s, "wrong": %s, "fact": %s}' % (
        r, json.dumps(qq, ensure_ascii=False), json.dumps(a, ensure_ascii=False), json.dumps(w, ensure_ascii=False), json.dumps(f, ensure_ascii=False)) for r, qq, a, w, f in QUIZ]
    s = s.rstrip()
    assert s.endswith("]")
    s = s[:-1].rstrip() + ",\n" + ",\n".join(lines) + "\n]\n"
    open(q, "w").write(s)


def shared_edits():
    # Glasgow: open its west side as a road out
    gp = path("data", "zones", "glasgow.json")
    z = json.load(open(gp))
    if "west" not in z["edges"]:
        z["edges"]["west"] = {"to": "loch_lomond", "offset": 0.0}
        for y in (28, 29, 30):
            r = list(z["rows"][y])
            r[0] = r[1] = "="
            z["rows"][y] = "".join(r)
        z["signs"].append({"text": "WEST ROAD. Loch Lomond, the Trossachs and on to Oban, Gateway to the Isles. Take the high road. Or the low road. The low road has fewer cyclists.", "x": 3, "y": 27})
        with open(gp, "w") as f:
            json.dump(z, f, indent=1)
    # world map
    wm = path("data", "world_map.json")
    s = open(wm).read()
    if '"oban"' not in s:
        s = s.replace('"kirkwall":{"name":"Kirkwall","x":618,"y":70,"nation":"scotland","island":"orkney"},',
                      '"kirkwall":{"name":"Kirkwall","x":618,"y":70,"nation":"scotland","island":"orkney"},"oban":{"name":"Oban","x":427,"y":414,"nation":"scotland","island":"gb"},"tobermory":{"name":"Tobermory","x":381,"y":386,"nation":"scotland","island":"gb"},', 1)
        s = s.replace('"loch_ness":{"x":504,"y":295},', '"loch_ness":{"x":504,"y":295},"loch_lomond":{"x":493,"y":462},"staffa":{"x":366,"y":394},"iona":{"x":356,"y":420},', 1)
        s = s.replace('["aberdeen","kirkwall"]],', '["aberdeen","kirkwall"],["oban","tobermory"]],', 1)
        s = s.replace('"aberdeen_kirkwall":[684.6', '"oban_tobermory":[418.0,408.0,404.0,398.0,390.0,392.0,381.0,386.0],"aberdeen_kirkwall":[684.6', 1)
        s = s.replace('[501.5,717.0,490.0,727.7,480.8,726.4]],', '[501.5,717.0,490.0,727.7,480.8,726.4],[519.2,487.8,493.0,462.0,455.0,438.0,427.0,414.0]],', 1)
        open(wm, "w").write(s)
    fp = path("data", "ferries.json")
    f = json.load(open(fp))
    if "oban_tobermory" not in f:
        f["oban_tobermory"] = {"a": "oban", "b": "tobermory", "ship": "the Isle of Mull",
                               "music": "ferry_north_channel",
                               "card": "The big red-and-blue ferry slides out past Kerrera and Lismore, and across the Firth of Lorn. Mull rises up green and grey. Somebody's collie is sick on the car deck. Welcome to the Hebrides."}
        with open(fp, "w") as fh:
            json.dump(f, fh, indent=1)
            fh.write("\n")
    edit("story/story_data.gd", '"birmingham": "Alright, bab!",', '"oban": "Halò!", "tobermory": "Halò!", "loch_lomond": "Halò!", "birmingham": "Alright, bab!",', '"oban": "Halò!"')
    # habitats (additive): new lines are placed in the zones of this region
    for sid in ["staffling", "fingalith", "lekling", "lekbruiser"]:
        pass


def items_file():
    jdump(ITEMS, "data", "items", "westhighlands.json", indent=1)
    jdump(QUESTS, "data", "quests", "westhighlands.json", indent=1) if os.makedirs(path("data", "quests"), exist_ok=True) is None else None


def main():
    wh_loch.build()
    wh_oban.build()
    wh_oban.trainers()
    wh_tober.build()
    write_all()
    write_creatures()
    items_file()
    shops()
    quiz()
    shared_edits()
    allp = sorted(set(p for z in wh_lib.ZONES.values() for p in [s.get("plaque") for s in z.get("signs", [])] if p))
    print("zones", len(wh_lib.ZONES), "trainers", len(wh_lib.TRAINERS), "plaques", len(allp))


if __name__ == "__main__":
    main()
