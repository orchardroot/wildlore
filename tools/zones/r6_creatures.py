# Wider Isles, region R6: the South Wales valleys. Two appendix lines: the Cobblet (a coal-country coblyn) and
# the Steamlet (Trevithick's engine, as a beast).
#   python3 tools/zones/r6_creatures.py
# Writes data/creatures/{cobblet,steamlet}.json and art/recipes/creatures/*.json, and appends dex_order and knacks
# (idempotent). Sprites: godot --headless --path . -s res://tools/spritegen.gd -- cobblet seamknocker steamlet penydarren
import json, os, re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HAB = ["rhondda", "merthyr", "blaenavon"]


def sp(id, name, types, base, catch, xp, learn, evolves, dex_text, fact, hab=None):
    return {"id": id, "name": name, "types": types, "base": dict(zip(["hp", "atk", "def", "lore", "ward", "spd"], base)),
            "growth": "medium", "catch_rate": catch, "base_xp": xp, "learnset": learn, "evolves": evolves,
            "habitat": hab or HAB, "appendix": True, "dex": {"text": dex_text, "fact": fact}, "sprite": id}


COB1 = [[1, "pebble_flick"], [1, "fairy_pinch"], [5, "grit_in_eye"], [9, "tylwyth_teg_tease"], [13, "flint_flick"], [17, "hard_hat"],
        [21, "slate_slide"], [25, "hobs_mischief"], [29, "mizzle"]]
COB2 = COB1 + [[38, "hollow_hill_hammer"], [42, "quarry_blast"], [46, "megalith_mutter"], [50, "bewitching_hour"]]
STM1 = [[1, "spark_shower"], [1, "kindle"], [5, "rivet"], [9, "kettle_scald"], [13, "coal_chuck"], [17, "galvanise"], [21, "forge_hammer"],
        [25, "smoke_alarm"], [29, "hull_clang"]]
STM2 = STM1 + [[38, "chimney_crash"], [42, "blast_furnace"], [46, "girder_sweep"], [50, "aga_roast"]]

LINES = {
    "cobblet": [
        sp("cobblet", "Cobblet", ["stone", "fae"], [54, 52, 58, 62, 54, 46], 150, 66, COB1, {"to": "seamknocker", "level": 38},
           "A knee-high coblyn in a yellow hard hat, found where the coal runs thin. It knocks on the rock three times and waits, and if you dig where it knocked you usually find something. Usually.",
           "The coblynau are the knockers of Welsh mining lore: small, ugly, helpful spirits who tapped on the rock to lead miners to the rich seams, and who were not to be laughed at. Miners left them a little of their lunch."),
        sp("seamknocker", "Seamknocker", ["stone", "fae"], [86, 82, 96, 96, 84, 56], 55, 190, COB2, None,
           "The old master of the seam. Its hammer rings out a whole shift's worth of directions, and the coal itself seems to lean toward whatever it taps. It dislikes whistling underground.",
           "Welsh miners had firm rules about luck underground: no whistling, no swearing, and respect for the coblynau, whose knocking could mean a rich seam ahead, or a warning that the roof was about to come in.", ["rhondda", "blaenavon"]),
    ],
    "steamlet": [
        sp("steamlet", "Steamlet", ["iron", "hearth"], [50, 60, 60, 58, 42, 38], 120, 64, STM1, {"to": "penydarren", "level": 38},
           "A small, furious boiler on iron wheels with a chimney too tall for its body. It chuffs along a rail it has no business being on and bets everyone it can pull more than they think.",
           "On 21 February 1804 Richard Trevithick's engine hauled ten tons of iron, five wagons and about seventy men nearly ten miles along the Penydarren tramroad from Merthyr to Abercynon. It was the first journey by a steam locomotive on rails."),
        sp("penydarren", "Penydarren", ["iron", "hearth"], [84, 100, 98, 84, 66, 50], 50, 188, STM2, None,
           "A great black locomotive-beast with a flywheel on its flank and a chimney that pours smoke like a promise. It is never late, only early in a way that makes the signal box nervous.",
           "Trevithick's Penydarren locomotive was a wager: the Merthyr ironmaster Samuel Homfray bet 500 guineas that it could haul ten tons of iron along the tramroad, and it did. But the engine was heavy, the cast-iron plates cracked under it, and it was not used again.", ["rhondda", "merthyr"]),
    ],
}


def pal(**k):
    return k


# --- recipes (art/recipes/creatures); layers are drawn bottom to top, centre x is 48
def shadow(w=56):
    return {"shape": "ellipse", "at": [48, 92], "size": [w, 6], "colour": "#00000040", "rim": False, "shade": False}


RECIPES = {
    "cobblet": {
        "id": "cobblet",
        "palette": {"skin": "#8d9b78", "skin2": "#6f7e5e", "coat": "#5a5048", "coat2": "#75685c", "beard": "#d9d2ba", "helm": "#e0b232",
                    "helm2": "#b88a1c", "lamp": "#fff4a8", "wood": "#7a5530", "metal": "#8a929c", "boot": "#3a302a", "ink": "#14100c"},
        "layers": [
            shadow(),
            {"shape": "line", "points": [[74, 44], [80, 86]], "width": 3, "colour": "wood"},
            {"shape": "poly", "points": [[66, 44], [86, 40], [88, 47], [70, 52]], "colour": "metal"},
            {"shape": "ellipse", "at": [37, 87], "size": [16, 9], "colour": "boot", "mirror": True},
            {"shape": "ellipse", "at": [48, 70], "size": [40, 38], "colour": "coat", "pattern": "speckle", "pcolour": "coat2", "density": 30},
            {"shape": "ellipse", "at": [29, 68], "size": [12, 22], "colour": "coat", "mirror": True},
            {"shape": "circle", "at": [28, 79], "r": 5, "colour": "skin2", "mirror": True},
            {"shape": "poly", "points": [[32, 44], [14, 32], [30, 54]], "colour": "skin", "mirror": True},
            {"shape": "ellipse", "at": [48, 46], "size": [36, 32], "colour": "skin", "pattern": "speckle", "pcolour": "skin2", "density": 14},
            {"shape": "ellipse", "at": [48, 59], "size": [26, 16], "colour": "beard", "front_only": True, "rim": False},
            {"shape": "ellipse", "at": [48, 50], "size": [9, 11], "colour": "skin2", "front_only": True},
            {"shape": "ellipse", "at": [48, 36], "size": [42, 8], "colour": "helm2", "rim": False},
            {"shape": "ellipse", "at": [48, 31], "size": [34, 20], "colour": "helm"},
            {"shape": "circle", "at": [48, 26], "r": 4, "colour": "lamp", "front_only": True, "shade": False},
        ],
        "eyes": [{"at": [40, 44], "r": 3.5, "colour": "#ffd860", "mirror": True}],
    },
    "seamknocker": {
        "id": "seamknocker",
        "palette": {"skin": "#7f8c72", "skin2": "#5d6a52", "coat": "#463e3a", "coat2": "#62564c", "beard": "#e4dcc2", "helm": "#e8b830",
                    "helm2": "#b8861a", "lamp": "#fff4a8", "wood": "#6a4a28", "metal": "#9aa2ac", "boot": "#2e2622", "glow": "#ffb84a",
                    "coal": "#1c1a1c", "ink": "#14100c"},
        "layers": [
            shadow(70),
            {"shape": "ellipse", "at": [20, 88], "size": [22, 9], "colour": "coal", "pattern": "speckle", "pcolour": "glow", "density": 10},
            {"shape": "line", "points": [[78, 30], [72, 86]], "width": 4, "colour": "wood"},
            {"shape": "poly", "points": [[62, 28], [92, 20], [94, 36], [64, 40]], "colour": "metal"},
            {"shape": "ellipse", "at": [34, 86], "size": [18, 10], "colour": "boot", "mirror": True},
            {"shape": "ellipse", "at": [48, 66], "size": [56, 50], "colour": "coat", "pattern": "speckle", "pcolour": "coat2", "density": 34},
            {"shape": "line", "points": [[40, 56], [46, 68], [42, 80]], "width": 2, "colour": "glow", "shade": False, "front_only": True},
            {"shape": "ellipse", "at": [24, 62], "size": [14, 26], "colour": "coat", "mirror": True},
            {"shape": "circle", "at": [23, 76], "r": 6, "colour": "skin2", "mirror": True},
            {"shape": "poly", "points": [[30, 40], [10, 26], [28, 52]], "colour": "skin", "mirror": True},
            {"shape": "ellipse", "at": [48, 42], "size": [40, 34], "colour": "skin", "pattern": "speckle", "pcolour": "skin2", "density": 16},
            {"shape": "ellipse", "at": [48, 57], "size": [32, 20], "colour": "beard", "front_only": True, "rim": False},
            {"shape": "ellipse", "at": [48, 47], "size": [10, 12], "colour": "skin2", "front_only": True},
            {"shape": "spikes", "at": [48, 28], "size": [30, 8], "count": 5, "len": 9, "from": -170, "to": -10, "colour": "glow", "rim": False},
            {"shape": "ellipse", "at": [48, 32], "size": [46, 9], "colour": "helm2", "rim": False},
            {"shape": "ellipse", "at": [48, 26], "size": [38, 22], "colour": "helm"},
            {"shape": "circle", "at": [48, 20], "r": 4.5, "colour": "lamp", "front_only": True, "shade": False},
        ],
        "eyes": [{"at": [39, 41], "r": 4, "colour": "#ffd860", "mirror": True}],
    },
    "steamlet": {
        "id": "steamlet",
        "palette": {"iron": "#454a52", "iron2": "#626872", "brass": "#c49a40", "wheel": "#2c3036", "coal": "#1e1c1e", "steam": "#e8ecf0",
                    "glow": "#ff8a2a", "ink": "#101214"},
        "layers": [
            shadow(60),
            {"shape": "circle", "at": [58, 18], "r": 7, "colour": "steam", "rim": False, "shade": False},
            {"shape": "circle", "at": [66, 10], "r": 5, "colour": "#ffffffc0", "rim": False, "shade": False},
            {"shape": "ellipse", "at": [62, 40], "size": [9, 26], "colour": "coal"},
            {"shape": "ellipse", "at": [62, 27], "size": [14, 5], "colour": "iron2"},
            {"shape": "ellipse", "at": [48, 62], "size": [64, 40], "colour": "iron", "pattern": "stripes", "pcolour": "iron2", "period": 8},
            {"shape": "ellipse", "at": [48, 62], "size": [8, 42], "colour": "brass", "rim": False, "front_only": True},
            {"shape": "ellipse", "at": [26, 66], "size": [18, 30], "colour": "iron2"},
            {"shape": "circle", "at": [72, 80], "r": 11, "colour": "wheel"},
            {"shape": "circle", "at": [72, 80], "r": 4, "colour": "brass", "rim": False},
            {"shape": "circle", "at": [32, 82], "r": 9, "colour": "wheel"},
            {"shape": "circle", "at": [32, 82], "r": 3.5, "colour": "brass", "rim": False},
            {"shape": "line", "points": [[72, 80], [64, 70]], "width": 2, "colour": "brass", "shade": False},
            {"shape": "ellipse", "at": [30, 62], "size": [10, 8], "colour": "glow", "front_only": True, "rim": False, "shade": False},
        ],
        "eyes": [{"at": [44, 56], "r": 5, "colour": "#ffd890", "mirror": False}, {"at": [56, 56], "r": 5, "colour": "#ffd890", "mirror": False}],
    },
    "penydarren": {
        "id": "penydarren",
        "palette": {"iron": "#3a3e46", "iron2": "#5c626c", "brass": "#cfa448", "wheel": "#24282e", "coal": "#18161a", "steam": "#eef1f4",
                    "glow": "#ff7a22", "glow2": "#ffd060", "ink": "#0e1012"},
        "layers": [
            shadow(78),
            {"shape": "circle", "at": [70, 10], "r": 9, "colour": "steam", "rim": False, "shade": False},
            {"shape": "circle", "at": [82, 6], "r": 6, "colour": "#ffffffb0", "rim": False, "shade": False},
            {"shape": "ellipse", "at": [66, 36], "size": [11, 38], "colour": "coal"},
            {"shape": "ellipse", "at": [66, 18], "size": [18, 6], "colour": "iron2"},
            {"shape": "ellipse", "at": [48, 62], "size": [78, 46], "colour": "iron", "pattern": "stripes", "pcolour": "iron2", "period": 9},
            {"shape": "ellipse", "at": [30, 62], "size": [8, 48], "colour": "brass", "rim": False, "front_only": True},
            {"shape": "ellipse", "at": [66, 62], "size": [8, 48], "colour": "brass", "rim": False, "front_only": True},
            {"shape": "ellipse", "at": [84, 66], "size": [18, 24], "colour": "iron2"},
            {"shape": "circle", "at": [38, 58], "r": 24, "colour": "wheel"},
            {"shape": "circle", "at": [38, 58], "r": 19, "colour": "iron2", "rim": False},
            {"shape": "line", "points": [[38, 36], [38, 80]], "width": 3, "colour": "wheel", "shade": False, "front_only": True},
            {"shape": "line", "points": [[16, 58], [60, 58]], "width": 3, "colour": "wheel", "shade": False, "front_only": True},
            {"shape": "line", "points": [[22, 42], [54, 74]], "width": 3, "colour": "wheel", "shade": False, "front_only": True},
            {"shape": "line", "points": [[54, 42], [22, 74]], "width": 3, "colour": "wheel", "shade": False, "front_only": True},
            {"shape": "circle", "at": [38, 58], "r": 5, "colour": "brass", "rim": False},
            {"shape": "circle", "at": [76, 86], "r": 10, "colour": "wheel"},
            {"shape": "circle", "at": [76, 86], "r": 4, "colour": "brass", "rim": False},
            {"shape": "circle", "at": [20, 86], "r": 8, "colour": "wheel"},
            {"shape": "circle", "at": [20, 86], "r": 3, "colour": "brass", "rim": False},
            {"shape": "poly", "points": [[70, 70], [86, 70], [84, 78], [72, 78]], "colour": "glow", "front_only": True, "shade": False},
            {"shape": "line", "points": [[74, 74], [84, 74]], "width": 2, "colour": "glow2", "shade": False, "front_only": True},
        ],
        "eyes": [{"at": [60, 50], "r": 6, "colour": "#ffe0a0", "mirror": False}, {"at": [76, 50], "r": 6, "colour": "#ffe0a0", "mirror": False}],
    },
}


def main():
    for line, species in LINES.items():
        json.dump({"line": line, "species": species}, open(os.path.join(ROOT, "data/creatures", line + ".json"), "w"), indent=2)
    for sid, rec in RECIPES.items():
        json.dump(rec, open(os.path.join(ROOT, "art/recipes/creatures", sid + ".json"), "w"), indent=1)
    # dex_order: append the four ids at the end by text, only if missing
    p = os.path.join(ROOT, "data/dex_order.json")
    txt = open(p).read()
    new = [s for s in ("cobblet", "seamknocker", "steamlet", "penydarren") if '"%s"' % s not in txt]
    if new:
        i = txt.rstrip().rfind("]")
        body = txt[:i].rstrip()
        txt = body + "".join(',\n  "%s"' % s for s in new) + "\n]\n"
        open(p, "w").write(txt)
    # knacks: definitions and species, by text insertion
    p = os.path.join(ROOT, "data/knacks.json")
    txt = open(p).read()
    if '"cwm_mizzle"' not in txt:
        defs = ('    "cwm_mizzle": {"name": "Cwm Mizzle", "desc": "Valley drizzle puts a song in the rock: its stone and fae moves hit harder in drizzle, fog or a downpour.", '
                '"msg": "{name} knocks, and the mizzle sings back!", "power_weather": {"weather": ["drizzle", "downpour", "fog"], "mult": 1.3, "types": ["stone", "fae"]}},\n'
                '    "full_head": {"name": "Full Head of Steam", "desc": "Comes out with the pressure up: its Attack rises as it arrives.", '
                '"msg": "{name} arrives with a full head of steam!", "entry_stage": {"to": "self", "stat": "atk", "stages": 1}},\n')
        txt = txt.replace('  "knacks": {\n', '  "knacks": {\n' + defs, 1)
        spec = ('    "cobblet": "cwm_mizzle",\n    "seamknocker": "cwm_mizzle",\n    "steamlet": "full_head",\n    "penydarren": "full_head",\n')
        txt = txt.replace('  "species": {\n', '  "species": {\n' + spec, 1)
        open(p, "w").write(txt)


if __name__ == "__main__":
    main()
