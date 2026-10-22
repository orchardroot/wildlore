# Wave 45 L: sprite recipes for the four new lines abroad, drawn by recolouring and dressing existing house-style
# recipes so they sit with the rest of the Fieldbook. Then render them:
#   $(tools/get_godot.sh) --headless --path . -s res://tools/spritegen.gd -- choiquet choique mooslet bullmoose hellbendlet hellbender ankou
# Usage (repo root): python3 tools/zones/abroad_recipes.py
import json, os, re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DIR = os.path.join(ROOT, "art", "recipes", "creatures")


def recolour(src, new_id, colours=None, palette=None, extra=(), extra_face=(), eyes=None):
    txt = open(os.path.join(DIR, src + ".json")).read()
    for a, b in (colours or {}).items():
        txt = re.sub(re.escape(a), b, txt, flags=re.I)
    d = json.loads(txt)
    d["id"] = new_id
    if palette:
        d["palette"].update(palette)
    d["layers"].extend(extra)
    d.setdefault("face_layers", []).extend(extra_face)
    if eyes:
        for e in d.get("eyes", []):
            e["colour"] = eyes
    json.dump(d, open(os.path.join(DIR, new_id + ".json"), "w"), indent=1)


# Darwin's rhea: grey-brown, white-spotted, with a dull beak; the young from the crane chick, the adult from the crane
RHEA = {"#b4b8c0": "#a8987e", "#9aa0aa": "#f2eee2", "#9ca2ac": "#8a7a62", "#e2e4e8": "#ddd2bc", "#c8ccd2": "#bcae94",
        "#d8dce0": "#cfc2aa", "#585e6c": "#6e5e4a", "#d83030": "#7a6a54", "#e8c860": "#c4ac84"}
RHEA2 = {"#b8bcc6": "#a29278", "#aaaeb8": "#8e7e64", "#8a8e98": "#f0ebde", "#6a6e78": "#6e5e4a", "#dadde4": "#d8ccb4",
         "#ececee": "#e6dcc8", "#3c3f4c": "#4a3e30", "#3a3c44": "#5a4c3a", "#2c2e38": "#3a3026", "#d42a2a": "#6e5e4a",
         "#d8c070": "#c4ac84"}
# moose: dark brown all over, pale legs, broad velvet antlers on the bull
MOOSE = {"br": "#5a4030", "br2": "#3e2c20", "w": "#a08a70", "w2": "#86725c", "blush": "#c89880"}
BULL = {"br": "#4a3426", "br2": "#2e2018", "w": "#8a7460", "w2": "#6e5c4a", "vel": "#c8b48c", "vel2": "#a08a66"}
# the Ankou: the banshee's shape in a black cloak, a wide Breton hat and a scythe
ANKOU = {"#3a2a5a": "#121216", "#4a3a6a": "#1c1c22", "#8a5a8a": "#34343c", "#f0ecfa": "#3e3e48", "#f6f2fc": "#46464f",
         "#ffffff": "#5a5a64", "#e4e8f8": "#3a3a44", "#dcdff0": "#33333c", "#d8d2f4": "#2e2e36", "#cac4ec": "#2a2a32",
         "#bcc2e0": "#26262e", "#b4aedc": "#22222a", "#d8dcee": "#30303a", "#f0b8d0": "#2a2a30"}


# hellbender: the skink's side-on lizard shape, recoloured mottled brown, the ember spines and sparks taken off, a pool
# of creek water underneath and wrinkled flanks (it breathes through those folds); the adult is longer and flatter.
HELL = {"sand": "#7a6a4c", "sand2": "#8c7c5c", "green": "#6a5a3e", "green2": "#4a3e2a", "belly": "#a0906c", "brown": "#4a3a28",
        "dune": "#6a98ae", "dune2": "#4a7a92", "claw": "#3a2e22", "ink": "#1e160e", "ember": "#7a6a4c", "ember2": "#7a6a4c"}


def _scale(d, sx, sy, cx=48, cy=92):
    def pt(p):
        return [round(cx + (p[0] - cx) * sx, 1), round(cy + (p[1] - cy) * sy, 1)]
    for l in d["layers"] + d.get("face_layers", []):
        if "at" in l:
            l["at"] = pt(l["at"])
        if "size" in l:
            l["size"] = [round(l["size"][0] * sx, 1), round(l["size"][1] * sy, 1)]
        if "points" in l:
            l["points"] = [pt(p) for p in l["points"]]
    for e in d.get("eyes", []):
        e["at"] = pt(e["at"])


def salamander(new_id, sx, sy, wrinkles):
    d = json.load(open(os.path.join(DIR, "duneskink.json")))
    d["id"] = new_id
    d["palette"].update(HELL)
    d["layers"] = [l for l in d["layers"] if l["shape"] != "tri" and not (l["shape"] == "circle" and l.get("colour", "").startswith("ember"))]
    for i in range(wrinkles):
        y = 76 + i * 3
        d["layers"].append({"shape": "line", "points": [[32, y], [40, y + 3], [48, y], [56, y + 3], [64, y], [72, y + 3]],
                            "width": 1.4, "colour": "brown", "shade": False})
    for e in d["eyes"]:
        e["r"] = 3.2
        e["colour"] = "#c8b060"
    _scale(d, sx, sy)
    json.dump(d, open(os.path.join(DIR, new_id + ".json"), "w"), indent=1)


def main():
    recolour("cranelet", "choiquet", colours=RHEA)
    recolour("levelcrane", "choique", colours=RHEA2)
    recolour("calfrein", "mooslet", palette=MOOSE)
    # the bull's antlers are broad palms, not the reindeer's tines
    recolour("reindeer", "bullmoose", palette=BULL,
             extra=[{"shape": "poly", "points": [[36, 26], [20, 24], [8, 14], [6, 4], [13, 8], [16, 0], [22, 7], [27, 0], [31, 8], [36, 4], [40, 16], [42, 26]],
                     "colour": "vel", "mirror": True, "pattern": "speckle", "pcolour": "vel2", "density": 10}])
    salamander("hellbendlet", 1.0, 1.0, 1)
    salamander("hellbender", 1.08, 1.06, 3)
    recolour("bansheen", "ankou", colours=ANKOU, eyes="#e8f0ff",
             extra=[{"shape": "line", "points": [[82, 18], [80, 92]], "width": 2.2, "colour": "#5a4030", "shade": False},
                    {"shape": "poly", "points": [[82, 16], [60, 10], [44, 16], [62, 14]], "colour": "#c8ccd4", "rim": False, "shade": False},
                    {"shape": "ellipse", "at": [48, 21], "size": [54, 7], "colour": "#0c0c0e", "rim": False},
                    {"shape": "ellipse", "at": [48, 15], "size": [26, 11], "colour": "#16161a", "rim": False}])
    print("abroad recipes written")


if __name__ == "__main__":
    main()
