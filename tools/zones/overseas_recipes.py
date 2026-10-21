# Sprite recipes for the six wave 33 hub/Mediterranean creatures (art/recipes/creatures). Run from the repo root:
#   python3 tools/zones/overseas_recipes.py
#   godot --headless --path . -s res://tools/spritegen.gd -- macaquet levanter sapperling brineling brineflame tesserite
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def shadow(w=50):
    return {"shape": "ellipse", "at": [48, 92], "size": [w, 6], "colour": "#2a2a30", "rim": False, "shade": False}


R = {}

# --- Macaquet: a tailless Barbary macaque, sitting up on a wall, with a worried brow and a pale face -----------------
R["macaquet"] = {
    "id": "macaquet",
    "palette": {"fur": "#9a6a42", "fur2": "#b58558", "belly": "#d9bd8e", "face": "#e4b9a0", "dark": "#4a3020", "ink": "#2a1a10", "hand": "#c99a78", "wall": "#b9b19a"},
    "layers": [
        shadow(56),
        {"shape": "rect", "at": [48, 86], "size": [64, 12], "colour": "wall", "round": 2, "pattern": "speckle", "pcolour": "#9a927c", "density": 8},
        {"shape": "ellipse", "at": [34, 82], "size": [16, 11], "colour": "hand", "mirror": True},
        {"shape": "ellipse", "at": [48, 66], "size": [54, 50], "colour": "fur", "pattern": "speckle", "pcolour": "fur2", "density": 10},
        {"shape": "ellipse", "at": [48, 70], "size": [32, 34], "colour": "belly", "front_only": True},
        {"shape": "ellipse", "at": [24, 64], "size": [14, 36], "colour": "fur", "angle": 10, "mirror": True},
        {"shape": "ellipse", "at": [20, 80], "size": [11, 9], "colour": "hand", "mirror": True, "front_only": True},
        {"shape": "circle", "at": [28, 36], "r": 6, "colour": "face", "mirror": True},
        {"shape": "circle", "at": [48, 38], "r": 19, "colour": "fur2"},
        {"shape": "ellipse", "at": [48, 43], "size": [26, 22], "colour": "face", "front_only": True},
        {"shape": "ellipse", "at": [48, 30], "size": [28, 8], "colour": "fur", "front_only": True, "rim": False},
    ],
    "face_layers": [
        {"shape": "line", "points": [[38, 33], [46, 36]], "width": 2.4, "colour": "ink", "shade": False},
        {"shape": "line", "points": [[58, 33], [50, 36]], "width": 2.4, "colour": "ink", "shade": False},
        {"shape": "ellipse", "at": [48, 47], "size": [9, 6], "colour": "dark", "shade": False, "rim": False},
        {"shape": "line", "points": [[43, 51], [48, 53], [53, 51]], "width": 1.6, "colour": "ink", "shade": False},
    ],
    "eyes": [{"at": [41, 39], "r": 4.2, "colour": "#fff2d8", "mirror": True}],
    "back_marks": [
        {"shape": "ellipse", "at": [48, 72], "size": [24, 22], "colour": "#a37448"},
        {"shape": "line", "points": [[40, 56], [48, 62], [56, 56]], "width": 3, "colour": "#6c4630", "shade": False},
    ],
}

# --- Levanter: a banner cloud over a spur of rock -----------------------------------------------------------------------
R["levanter"] = {
    "id": "levanter",
    "palette": {"cloud": "#f1f3f6", "cloud2": "#d7dde6", "under": "#9aa6ba", "rock": "#a6a08e", "rock2": "#c4bda8", "ink": "#2b3446", "glow": "#fff5c8", "bolt": "#ffe27a"},
    "layers": [
        shadow(36),
        {"shape": "poly", "points": [[28, 92], [38, 70], [46, 58], [56, 68], [68, 92]], "colour": "rock", "pattern": "stripes", "pcolour": "rock2", "period": 6, "pangle": 100},
        {"shape": "ellipse", "at": [46, 44], "size": [70, 30], "colour": "under"},
        {"shape": "circle", "at": [20, 42], "r": 11, "colour": "cloud2"},
        {"shape": "circle", "at": [76, 44], "r": 12, "colour": "cloud2"},
        {"shape": "ellipse", "at": [48, 40], "size": [66, 32], "colour": "cloud", "pattern": "speckle", "pcolour": "cloud2", "density": 10},
        {"shape": "circle", "at": [34, 30], "r": 13, "colour": "cloud"},
        {"shape": "circle", "at": [58, 26], "r": 15, "colour": "cloud"},
        {"shape": "circle", "at": [46, 22], "r": 11, "colour": "cloud"},
        {"shape": "line", "points": [[8, 56], [20, 60], [30, 56]], "width": 3, "colour": "cloud2", "shade": False},
        {"shape": "line", "points": [[66, 58], [78, 62], [90, 58]], "width": 3, "colour": "cloud2", "shade": False},
    ],
    "face_layers": [
        {"shape": "line", "points": [[34, 33], [43, 36]], "width": 2.2, "colour": "ink", "shade": False},
        {"shape": "line", "points": [[62, 33], [53, 36]], "width": 2.2, "colour": "ink", "shade": False},
        {"shape": "line", "points": [[44, 47], [48, 49], [52, 47]], "width": 1.8, "colour": "ink", "shade": False},
        {"shape": "poly", "points": [[70, 54], [66, 64], [71, 63], [67, 74]], "colour": "bolt", "shade": False, "rim": False},
    ],
    "eyes": [{"at": [38, 38], "r": 5, "colour": "#fff8d8", "mirror": True}],
    "back_marks": [
        {"shape": "line", "points": [[22, 36], [48, 28], [74, 36]], "width": 3, "colour": "#c7ced9", "shade": False},
    ],
}

# --- Sapperling: a stocky tunneller in a tin hat, with a pickaxe --------------------------------------------------------
R["sapperling"] = {
    "id": "sapperling",
    "palette": {"coat": "#6b7480", "coat2": "#868f9b", "belly": "#b6bcc4", "hat": "#d8a838", "hat2": "#f0c85a", "dark": "#2e343c", "pick": "#8a8f98", "wood": "#7a5636", "lamp": "#fff0a0", "ink": "#1c2026", "nose": "#d9a0a0"},
    "layers": [
        shadow(54),
        {"shape": "line", "points": [[74, 90], [70, 52], [62, 36]], "width": 4, "colour": "wood", "front_only": True},
        {"shape": "poly", "points": [[52, 38], [62, 30], [74, 38], [66, 36]], "colour": "pick", "front_only": True},
        {"shape": "ellipse", "at": [36, 88], "size": [18, 9], "colour": "dark", "mirror": True},
        {"shape": "ellipse", "at": [48, 66], "size": [58, 54], "colour": "coat", "pattern": "stripes", "pcolour": "coat2", "period": 8, "pangle": 0},
        {"shape": "ellipse", "at": [48, 72], "size": [34, 34], "colour": "belly", "front_only": True},
        {"shape": "ellipse", "at": [22, 66], "size": [14, 32], "colour": "coat2", "angle": 8, "mirror": True},
        {"shape": "circle", "at": [48, 40], "r": 17, "colour": "coat2"},
        {"shape": "ellipse", "at": [48, 48], "size": [22, 16], "colour": "belly", "front_only": True},
        {"shape": "ellipse", "at": [48, 28], "size": [40, 20], "colour": "hat"},
        {"shape": "ellipse", "at": [48, 35], "size": [52, 7], "colour": "hat2", "rim": False},
        {"shape": "circle", "at": [48, 26], "r": 4.5, "colour": "lamp", "front_only": True, "shade": False},
    ],
    "face_layers": [
        {"shape": "ellipse", "at": [48, 47], "size": [8, 6], "colour": "nose", "shade": False, "rim": False},
        {"shape": "line", "points": [[43, 52], [48, 54], [53, 52]], "width": 1.6, "colour": "ink", "shade": False},
    ],
    "eyes": [{"at": [41, 41], "r": 4, "colour": "#f4f4f4", "mirror": True}],
    "back_marks": [
        {"shape": "rect", "at": [48, 70], "size": [26, 18], "colour": "#7b5a3a", "round": 3},
        {"shape": "line", "points": [[40, 60], [56, 60]], "width": 2.4, "colour": "#d8a838", "shade": False},
    ],
}

# --- Brineling: a grey-pink flamingo chick on one leg -------------------------------------------------------------------
R["brineling"] = {
    "id": "brineling",
    "palette": {"down": "#e6c7cf", "down2": "#f3dde2", "pink": "#e58fa6", "beak": "#f1b7a8", "tip": "#2f2a32", "leg": "#e0869c", "ink": "#2b2026", "water": "#9cc8d8", "salt": "#f4efe6"},
    "layers": [
        {"shape": "ellipse", "at": [48, 90], "size": [66, 10], "colour": "water", "rim": False, "shade": False},
        {"shape": "ellipse", "at": [48, 91], "size": [48, 5], "colour": "salt", "rim": False, "shade": False},
        {"shape": "line", "points": [[44, 78], [44, 90]], "width": 3.4, "colour": "leg"},
        {"shape": "line", "points": [[56, 78], [60, 70], [52, 66]], "width": 3.2, "colour": "leg", "front_only": True},
        {"shape": "ellipse", "at": [48, 66], "size": [46, 36], "colour": "down", "pattern": "speckle", "pcolour": "down2", "density": 12},
        {"shape": "ellipse", "at": [30, 64], "size": [18, 24], "colour": "pink", "angle": -10, "pattern": "stripes", "pcolour": "down", "period": 6, "pangle": 100},
        {"shape": "line", "points": [[56, 56], [64, 42], [58, 30]], "width": 8, "colour": "down"},
        {"shape": "circle", "at": [56, 26], "r": 11, "colour": "down2"},
        {"shape": "poly", "points": [[47, 28], [34, 34], [38, 40], [48, 36]], "colour": "beak", "front_only": True},
        {"shape": "poly", "points": [[36, 32], [34, 34], [38, 40], [40, 36]], "colour": "tip", "front_only": True, "rim": False},
    ],
    "face_layers": [],
    "eyes": [{"at": [53, 24], "r": 3.6, "colour": "#fff6e0"}],
    "back_marks": [
        {"shape": "line", "points": [[46, 58], [48, 70], [52, 58]], "width": 3, "colour": "#d7a0b0", "shade": False},
    ],
}

# --- Brineflame: a tall pink flamingo with a crest of flame ----------------------------------------------------------
R["brineflame"] = {
    "id": "brineflame",
    "palette": {"pink": "#e8607f", "pink2": "#f58aa0", "pale": "#f9c2cd", "beak": "#f3b9a8", "tip": "#2a2428", "leg": "#d9567a", "ink": "#2a1c22", "flame": "#ff9a2e", "flame2": "#ffd34a", "water": "#8fc1d6", "salt": "#f4efe6"},
    "layers": [
        {"shape": "ellipse", "at": [48, 91], "size": [72, 10], "colour": "water", "rim": False, "shade": False},
        {"shape": "ellipse", "at": [48, 92], "size": [52, 5], "colour": "salt", "rim": False, "shade": False},
        {"shape": "line", "points": [[42, 70], [40, 91]], "width": 3.6, "colour": "leg"},
        {"shape": "line", "points": [[58, 72], [66, 64], [56, 62]], "width": 3.4, "colour": "leg", "front_only": True},
        {"shape": "ellipse", "at": [44, 60], "size": [56, 40], "colour": "pink", "pattern": "speckle", "pcolour": "pink2", "density": 12},
        {"shape": "ellipse", "at": [32, 60], "size": [24, 28], "colour": "pink2", "angle": -14, "pattern": "stripes", "pcolour": "pink", "period": 6, "pangle": 100},
        {"shape": "poly", "points": [[18, 70], [12, 80], [24, 76]], "colour": "flame", "shade": False},
        {"shape": "poly", "points": [[26, 74], [22, 86], [32, 78]], "colour": "flame2", "shade": False},
        {"shape": "line", "points": [[58, 48], [68, 34], [60, 20]], "width": 8, "colour": "pink2"},
        {"shape": "circle", "at": [58, 16], "r": 11, "colour": "pale"},
        {"shape": "poly", "points": [[50, 18], [34, 24], [38, 32], [51, 25]], "colour": "beak", "front_only": True},
        {"shape": "poly", "points": [[38, 22], [34, 24], [38, 32], [42, 27]], "colour": "tip", "front_only": True, "rim": False},
        {"shape": "poly", "points": [[54, 7], [52, -2], [58, 4], [62, -4], [64, 6]], "colour": "flame", "shade": False, "rim": False},
        {"shape": "poly", "points": [[57, 7], [58, 1], [61, 7]], "colour": "flame2", "shade": False, "rim": False},
    ],
    "face_layers": [],
    "eyes": [{"at": [56, 14], "r": 3.8, "colour": "#fff6d8"}],
    "back_marks": [
        {"shape": "line", "points": [[40, 50], [46, 66], [56, 50]], "width": 3, "colour": "#fbb0c0", "shade": False},
        {"shape": "poly", "points": [[40, 74], [36, 88], [46, 82]], "colour": "#ff9a2e", "shade": False},
    ],
}

# --- Tesserite: a walking mosaic of small coloured tiles, a face made of tesserae ----------------------------------------
tiles = []
cols = ["#2f6ea8", "#c0623a", "#e0b04a", "#f1e8d2", "#3a8a78", "#8a4a5a"]
cx0, cy0, n = 30, 30, 0
for gy in range(7):
    for gx in range(7):
        x = 24 + gx * 8
        y = 34 + gy * 8
        if abs(gx - 3) + abs(gy - 3) > 5:
            continue
        c = cols[(gx * 2 + gy * 3 + (gx * gy)) % len(cols)]
        tiles.append({"shape": "rect", "at": [x, y], "size": [6.6, 6.6], "colour": c, "rim": False, "front_only": True})
R["tesserite"] = {
    "id": "tesserite",
    "palette": {"base": "#d6c6a4", "base2": "#bfae8a", "ink": "#2a2418", "foot": "#a8946c"},
    "layers": [
        shadow(52),
        {"shape": "rect", "at": [36, 88], "size": [14, 10], "colour": "foot", "round": 2, "mirror": True},
        {"shape": "ellipse", "at": [48, 62], "size": [62, 62], "colour": "base", "pattern": "speckle", "pcolour": "base2", "density": 12},
        {"shape": "ellipse", "at": [16, 62], "size": [14, 34], "colour": "base2", "angle": 8, "mirror": True},
        {"shape": "circle", "at": [48, 30], "r": 16, "colour": "base2"},
    ] + tiles + [
        {"shape": "rect", "at": [42, 30], "size": [5, 5], "colour": "#f1e8d2", "rim": False, "front_only": True, "mirror": True},
    ],
    "face_layers": [
        {"shape": "line", "points": [[40, 40], [48, 42], [56, 40]], "width": 1.8, "colour": "ink", "shade": False},
    ],
    "eyes": [{"at": [42, 30], "r": 3.2, "colour": "#fff8e0", "mirror": True}],
    "back_marks": [
        {"shape": "rect", "at": [48, 62], "size": [30, 30], "colour": "#c0623a", "round": 2},
        {"shape": "rect", "at": [48, 62], "size": [20, 20], "colour": "#2f6ea8", "round": 2},
        {"shape": "rect", "at": [48, 62], "size": [10, 10], "colour": "#e0b04a", "round": 2},
    ],
}


def main():
    for k, v in R.items():
        txt = json.dumps(v, indent=1)
        open(os.path.join(ROOT, "art", "recipes", "creatures", k + ".json"), "w").write(txt + "\n")
    print("recipes written:", ", ".join(R))


if __name__ == "__main__":
    main()
