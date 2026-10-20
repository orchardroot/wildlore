# 3.3 "Overseas", wave 33 agent 2 (South Atlantic): twelve new appendix creatures and their sprite recipes.
# Usage: python3 tools/zones/os_sa_creatures.py   (run from the repo root; writes data/creatures, art/recipes/creatures,
#   appends to data/dex_order.json and data/knacks.json by text insertion)
import json, re, os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

def sp(id, name, types, base, evolves, habitat, text, fact, learn, catch=60, xp=150, knack=""):
    return {"id": id, "name": name, "types": types, "base": dict(zip(["hp", "atk", "def", "lore", "ward", "spd"], base)),
            "growth": "medium", "catch_rate": catch, "base_xp": xp, "learnset": learn, "evolves": evolves, "habitat": habitat,
            "appendix": True, "dex": {"text": text, "fact": fact}, "sprite": id, "_knack": knack}

LINES = {
 "cindershell": [
  sp("cindershell", "Cindershell", ["tide", "hearth"], [62, 50, 66, 52, 54, 36], {"to": "ashmantle", "level": 34},
     ["ascension", "ascension_green_mountain"],
     "Crawls up Long Beach after dark, digs a hole with its back flippers and sulks about it for the rest of the night. The sand is warm underfoot. It thinks that is only fair.",
     "Green turtles cross about 2,000 kilometres of open Atlantic from Brazil to nest on Ascension, and return to the same beaches, often near where they hatched, years later.",
     [[1, "crab_pinch"], [1, "kindle"], [6, "brine_spray"], [11, "smoulder"], [16, "tide_tables"], [21, "tidal_surge"], [27, "hob_sizzle"], [33, "snug_as_a_bug"], [38, "moon_pull"]], 190, 62, "sea_legs"),
  sp("ashmantle", "Ashmantle", ["tide", "hearth"], [96, 74, 102, 80, 84, 48], None, [],
     "A shell the colour of cooled cinder, cracked with orange where it has lately been thinking about something. Has crossed an ocean to be on this one beach and will not discuss it.",
     "A nesting female green turtle can lay several clutches in a season, about a hundred eggs each, buried in the sand to be warmed by the sun; the warmth of the nest decides whether hatchlings are male or female.",
     [[1, "crab_pinch"], [1, "kindle"], [6, "brine_spray"], [11, "smoulder"], [16, "tide_tables"], [21, "tidal_surge"], [27, "hob_sizzle"], [33, "snug_as_a_bug"], [38, "moon_pull"], [44, "aga_roast"], [50, "wave_sweeper"]], 60, 165, "sea_legs"),
 ],
 "mistfrond": [
  sp("mistfrond", "Mistfrond", ["hedgerow", "fae"], [96, 70, 88, 112, 104, 66], None, ["ascension_green_mountain"],
     "A bundle of bamboo and tree fern that has put itself in charge of the cloud. It was planted here on purpose, and so was everything else on the mountain, which makes it the only local with paperwork.",
     "Much of the green forest on Green Mountain was planted from the 1840s, on the advice of Joseph Hooker of Kew and Charles Darwin, to make rain by trapping cloud on a bare volcanic peak.",
     [[1, "bramble_lash"], [1, "pixie_prick"], [8, "spore_puff"], [14, "green_fingers"], [20, "fog_lure"], [26, "thorn_volley"], [32, "mizzle"], [38, "fairy_ring"], [44, "elder_hex"], [50, "wild_hunt_bloom"]], 45, 178, "pea_souper"),
 ],
 "plodlet": [
  sp("plodlet", "Plodlet", ["stone", "kin"], [74, 52, 78, 40, 62, 18], {"to": "elderplod", "level": 38},
     ["st_helena_jamestown", "st_helena_plantation"],
     "Walks at the speed of a pleasant thought. Has never been late for anything, as nothing has ever been waiting.",
     "Seychelles giant tortoises are among the longest-lived animals alive; Jonathan, who lives on the lawn at Plantation House on St Helena, hatched around 1832 and is thought to be the oldest living land animal.",
     [[1, "pebble_flick"], [1, "hunker"], [7, "scrap"], [12, "dry_stone_wall"], [18, "boulder_bump"], [24, "cairn_stack"], [30, "sheepdog_herd"], [36, "slate_slide"], [42, "megalith_mutter"]], 190, 64, "solid_as_rock"),
  sp("elderplod", "Elderplod", ["stone", "kin"], [112, 78, 122, 58, 92, 22], None, [],
     "Ring on ring on its shell, like a tree that learned to walk. It has met eleven governors, and has opinions on nine of them.",
     "Jonathan the tortoise arrived on St Helena from the Seychelles in 1882, already fully grown, which puts his hatching at about 1832; a tortoise's shell rings cannot tell you its age.",
     [[1, "pebble_flick"], [1, "hunker"], [7, "scrap"], [12, "dry_stone_wall"], [18, "boulder_bump"], [24, "cairn_stack"], [30, "sheepdog_herd"], [36, "slate_slide"], [42, "megalith_mutter"], [48, "millstone_drop"], [54, "barge"]], 60, 168, "solid_as_rock"),
 ],
 "wirefoot": [
  sp("wirefoot", "Wirefoot", ["gale", "stone"], [78, 82, 70, 76, 84, 106], None, ["st_helena_plantation"],
     "Stands on legs like fence wire, watching the road crumble. It is the island's own and it is not leaving, which is more than can be said for the sheep.",
     "The St Helena plover, called the wirebird for its thin legs, lives nowhere else on Earth and is the island's national bird; it nests on bare, open pasture, so fewer than a thousand remain.",
     [[1, "gust_nudge"], [1, "pebble_flick"], [8, "bluster"], [14, "fell_run"], [20, "flint_flick"], [26, "kestrel_dive"], [32, "slate_slide"], [38, "swoop"], [44, "gale_warning"], [50, "peregrine_plunge"]], 45, 172, "footing"),
 ],
 "hopperlet": [
  sp("hopperlet", "Hopperlet", ["frost", "brawn"], [66, 58, 56, 42, 50, 50], {"to": "rockhopper", "level": 36},
     ["tristan_da_cunha"],
     "Does not walk. Leaps from rock to rock with both feet together, apologises to nothing, and falls in the sea on purpose.",
     "Northern rockhopper penguins nest in huge noisy colonies on Tristan da Cunha and Gough Island, and really do hop between rocks with both feet together instead of waddling.",
     [[1, "frozen_nip"], [1, "shove"], [6, "snow_flick"], [11, "scrap"], [16, "hard_frost"], [21, "frostbite_snap"], [27, "scrum_push"], [33, "ptarmigan_huddle"], [39, "haymaker"]], 190, 64, "frost_hardy"),
  sp("rockhopper", "Rockhopper", ["frost", "brawn"], [94, 102, 78, 60, 74, 76], None, [],
     "A yellow brow, a red eye and a temper to match. Will take a swing at a wave and, to be fair, usually wins.",
     "Rockhoppers have bright yellow crest feathers over each eye and red eyes; they have a famous temper, and fight neighbours over a few square centimetres of rock.",
     [[1, "frozen_nip"], [1, "shove"], [6, "snow_flick"], [11, "scrap"], [16, "hard_frost"], [21, "frostbite_snap"], [27, "scrum_push"], [33, "ptarmigan_huddle"], [39, "haymaker"], [45, "black_ice_skid"], [51, "arctic_tern_dive"]], 60, 165, "frost_hardy"),
 ],
 "crawfisher": [
  sp("crawfisher", "Crawfisher", ["tide", "iron"], [90, 98, 104, 62, 76, 56], None, ["tristan_da_cunha"],
     "Red as a postbox and about as willing to be moved. Spends the season in the cold deep and the rest of the year in a pot, a tin and the island economy.",
     "The Tristan rock lobster is the island's main export, and Tristan has no airstrip: the only way in is by ship from Cape Town, a voyage of around six days.",
     [[1, "crab_pinch"], [1, "rivet"], [8, "brine_spray"], [14, "hull_clang"], [20, "galvanise"], [26, "forge_hammer"], [32, "rip_current"], [38, "riveters_brace"], [44, "girder_sweep"], [50, "spring_tide"]], 45, 170, "armour_plate"),
 ],
 "thumbrail": [
  sp("thumbrail", "Thumbrail", ["bog", "spirit"], [58, 52, 60, 100, 102, 92], None, ["tristan_da_cunha"],
     "Small enough to sit on a thumb and has chosen a very large island to be small on. Never learned to fly. Has had no need to.",
     "The Inaccessible Island rail, about the size of a sparrow, is the smallest flightless bird in the world; it lives only on Inaccessible Island, in the Tristan da Cunha group.",
     [[1, "squelch"], [1, "whisper"], [8, "peat_spit"], [14, "murky_gaze"], [20, "ghost_light"], [26, "sundew_snap"], [32, "deathwatch_tap"], [38, "will_o_wisp"], [44, "barrow_chill"], [50, "passing_bell"]], 45, 172, "make_do_and_mend"),
 ],
 "warrah": [
  sp("warrah", "Warrah", ["spirit", "night"], [92, 106, 76, 82, 80, 112], None, ["falklands_camp", "falklands_stanley"],
     "The only land mammal the Falkland Islands ever had, a fox-wolf with a white tail tip, and it walked up to visitors without a care. That was the mistake.",
     "The Falkland Islands wolf, or warrah, was the islands' only native land mammal, and was hunted to extinction by 1876; Darwin noted that it was tame, and predicted its end.",
     [[1, "shadow_nip"], [1, "whisper"], [8, "eerie_wail"], [14, "moonlit_pounce"], [20, "keening"], [26, "out_of_the_murk"], [32, "vixen_scream"], [38, "dark_of_the_moon"], [44, "washer_at_the_ford"], [50, "hellhound_howl"]], 30, 185, "not_quite_extinct"),
 ],
 "pandolph": [
  sp("pandolph", "Pandolph", ["tide", "frost"], [88, 80, 72, 96, 90, 98], None, ["falklands_camp", "falklands_stanley"],
     "Black and white, round-finned and rather pleased about it. Plays in the kelp off the beach and has never once been mistaken for a panda, only for a lovely idea.",
     "Commerson's dolphin is small, black and white, and has a rounded fin; it is common round the Falklands and Patagonia, and is sometimes called the panda dolphin.",
     [[1, "brine_spray"], [1, "snow_flick"], [8, "undertow"], [14, "sleet_shower"], [20, "tidal_surge"], [26, "haar_chill"], [32, "moon_pull"], [38, "hoarfrost"], [44, "wave_sweeper"], [50, "whiteout"]], 45, 172, "waterproof"),
 ],
 "johnnyrook": [
  sp("johnnyrook", "Johnny Rook", ["brawn", "night"], [84, 104, 78, 60, 70, 100], None, ["falklands_camp", "falklands_stanley"],
     "Orange of face, bold of eye, quick with the zip on your rucksack. It has a plan for your sandwich and you have no plan at all.",
     "The striated caracara, called the Johnny rook in the Falklands, is a bold, curious bird of prey that investigates and steals from visitors; it is found in few places beyond the southern tip of South America.",
     [[1, "shadow_nip"], [1, "shove"], [8, "glower"], [14, "owl_swoop"], [20, "scrum_push"], [26, "moonlit_pounce"], [32, "haymaker"], [38, "dark_of_the_moon"], [44, "kestrel_dive"], [50, "strongmans_yell"]], 45, 170, "brass_neck"),
 ],
}

def stage_json(line, species):
    return {"line": line, "species": [{k: v for k, v in s.items() if k != "_knack"} for s in species]}

# ---------------------------------------------------------------- recipes
def pal(**kw): return kw
def L(shape, at=None, size=None, colour="ink", **kw):
    d = {"shape": shape, "colour": colour}
    if at is not None: d["at"] = at
    if size is not None: d["size"] = size
    d.update(kw); return d
def poly(points, colour, **kw): return dict({"shape": "poly", "points": points, "colour": colour}, **kw)
def line(points, w, colour, **kw): return dict({"shape": "line", "points": points, "width": w, "colour": colour}, **kw)
def eyes(at, r=3.5, colour="eye", mirror=True, **kw): return dict({"at": at, "r": r, "colour": colour, "pupil": [1.5, 2], "mirror": mirror}, **kw)

RECIPES = {}
def recipe(id, palette, layers, face=(), eye=(), **kw):
    r = {"id": id, "palette": palette, "layers": layers}
    if face: r["face_layers"] = list(face)
    if eye: r["eyes"] = list(eye)
    r.update(kw); RECIPES[id] = r

# green turtle: low dome, flippers out
def turtle(id, big):
    s = 1.0 if big else 0.82
    p = pal(shell="#4c6a38" if not big else "#3a3836", shell2="#7a9a4c" if not big else "#5a5652", skin="#a8b86a" if not big else "#8c8470",
            skin2="#7e8c48" if not big else "#6a6458", ember="#f0702c", ink="#2a1c18", eye="#f2d84a", sand="#d8c48e")
    layers = [L("ellipse", [48, 90], [70*s, 10], "sand", rim=False, pattern="speckle", pcolour="#bca870", density=30),
              L("ellipse", [20, 70], [26*s, 11], "skin", angle=-25, mirror=True),
              L("ellipse", [34, 86], [16*s, 8], "skin", angle=18, mirror=True),
              L("ellipse", [48, 58], [64*s, 44*s], "shell"),
              L("ellipse", [48, 52], [50*s, 28*s], "shell2", rim=False, pattern="speckle", pcolour="shell", density=34),
              L("ellipse", [48, 44], [18*s, 10*s], "shell", rim=False),
              L("ellipse", [48, 30], [20, 16], "skin")]
    if big:
        layers += [line([[30, 56], [40, 50], [36, 62]], 1.6, "ember", shade=False, front_only=True), line([[66, 54], [58, 60], [64, 66]], 1.6, "ember", shade=False, front_only=True),
                   line([[48, 40], [50, 52], [44, 60]], 1.6, "ember", shade=False, front_only=True)]
    else:
        layers += [line([[34, 52], [48, 46], [62, 52]], 1.3, "shell", shade=False), line([[40, 66], [48, 58], [56, 66]], 1.3, "shell", shade=False)]
    face = [line([[44, 35], [48, 38], [52, 35]], 1.2, "ink", shade=False)]
    recipe(id, p, layers, face, [eyes([42, 29], 3.2)])
turtle("cindershell", False); turtle("ashmantle", True)

# mistfrond: fronds and a cloud
recipe("mistfrond", pal(frond="#4c9a52", frond2="#8cc860", stem="#7a6a3e", mist="#e4eef0", mist2="#c4d6dc", ink="#1c2a22", eye="#f2f2a8", bud="#f4a8c8"),
 [L("ellipse", [48, 91], [60, 9], "frond", rim=False, pattern="speckle", pcolour="frond2", density=36),
  poly([[48, 30], [14, 22], [20, 40], [40, 46]], "frond"), poly([[48, 30], [82, 22], [76, 40], [56, 46]], "frond"),
  poly([[48, 26], [26, 6], [34, 30], [46, 40]], "frond2"), poly([[48, 26], [70, 6], [62, 30], [50, 40]], "frond2"),
  L("ellipse", [48, 66], [40, 42], "stem"),
  L("ellipse", [48, 60], [46, 36], "mist", rim=False),
  L("ellipse", [30, 70], [22, 12], "mist2", rim=False), L("ellipse", [68, 74], [24, 12], "mist2", rim=False),
  L("circle", [48, 46], r=15, colour="frond2"),
  poly([[30, 62], [18, 56], [24, 70]], "frond"), poly([[66, 62], [78, 56], [72, 70]], "frond"),
  L("circle", [62, 36], r=3, colour="bud", rim=False)],
 [L("ellipse", [48, 50], [20, 7], "ink", shade=False)],
 [eyes([42, 45], 3.4)])

# tortoise
def tortoise(id, big):
    s = 1.0 if big else 0.8
    p = pal(shell="#6c6a48", shell2="#8e8a60", skin="#a49a74", skin2="#7e7656", moss="#5e8a40", ink="#2a241a", eye="#f0d850", grass="#7a9a4c")
    layers = [L("ellipse", [48, 90], [72*s, 10], "grass", rim=False, pattern="speckle", pcolour="moss", density=30),
              L("ellipse", [26, 82], [14*s, 12*s], "skin", mirror=True),
              L("ellipse", [48, 58], [66*s, 50*s], "shell"),
              L("ellipse", [48, 50], [48*s, 32*s], "shell2", rim=False),
              line([[48, 36], [48, 62]], 1.3, "shell", shade=False), line([[32, 46], [64, 46]], 1.3, "shell", shade=False), line([[34, 58], [62, 58]], 1.3, "shell", shade=False),
              L("ellipse", [48, 30], [20*s+4, 20*s+2], "skin")]
    if big:
        layers += [L("ellipse", [30, 40], [14, 8], "moss", rim=False, angle=-20), L("ellipse", [64, 38], [16, 8], "moss", rim=False, angle=20), L("circle", [54, 31], r=2, colour="moss", rim=False)]
    face = [line([[43, 36], [48, 38], [53, 36]], 1.2, "ink", shade=False)]
    recipe(id, p, layers, face, [eyes([43, 29], 2.8)])
tortoise("plodlet", False); tortoise("elderplod", True)

# wirebird: plover on wire legs
recipe("wirefoot", pal(back="#a48a64", back2="#7e6a48", belly="#f2ecd8", band="#2a2420", bill="#2a2420", leg="#d8a8a0", ink="#1c1814", eye="#f4d878", rock="#9a8e80"),
 [L("ellipse", [48, 91], [52, 7], "rock", rim=False, pattern="speckle", pcolour="#bcae9a", density=30),
  line([[42, 70], [40, 90]], 1.4, "leg", shade=False), line([[54, 70], [58, 90]], 1.4, "leg", shade=False),
  L("ellipse", [48, 56], [48, 34], "belly"), L("ellipse", [44, 50], [40, 24], "back", angle=-8),
  L("ellipse", [38, 52], [14, 8], "back2", rim=False, mirror=False),
  poly([[66, 52], [86, 62], [68, 60]], "back2"),
  L("ellipse", [52, 36], [24, 22], "belly"), L("ellipse", [50, 28], [22, 10], "back"),
  line([[40, 38], [64, 38]], 2.2, "band", shade=False, front_only=True),
  poly([[62, 36], [74, 38], [62, 41]], "bill")],
 [], [eyes([54, 34], 3.2, mirror=False)])

# rockhopper
def penguin(id, big):
    s = 1.0 if big else 0.8
    p = pal(black="#2c3040", black2="#464c62", belly="#f4f2ee", crest="#f2c42c", crest2="#e89a20", bill="#d84a2a", foot="#e8a0a0", ink="#1c1c28", eye="#d82a2a", rock="#8a8e98")
    layers = [L("ellipse", [48, 91], [58, 8], "rock", rim=False, pattern="speckle", pcolour="#b0b4bc", density=30),
              L("ellipse", [38, 90], [14, 6], "foot", mirror=True),
              L("ellipse", [48, 62], [48*s, 62*s], "black"),
              L("ellipse", [48, 68], [32*s, 46*s], "belly", front_only=True),
              L("ellipse", [48, 66], [30*s, 40*s], "black2", back_only=True, rim=False),
              L("ellipse", [24, 64], [10, 30*s], "black2", angle=12, mirror=True),
              L("circle", [48, 34], r=15*s+2, colour="black")]
    crest = [poly([[34, 26], [18, 14], [28, 30]], "crest"), poly([[62, 26], [78, 14], [68, 30]], "crest")]
    if big:
        crest += [poly([[36, 24], [24, 8], [40, 26]], "crest2"), poly([[60, 24], [72, 8], [56, 26]], "crest2")]
    layers += crest
    face = [poly([[44, 36], [52, 36], [49, 46]], "bill")]
    recipe(id, p, layers, face, [eyes([41, 31], 3.4)])
penguin("hopperlet", False); penguin("rockhopper", True)

# Tristan rock lobster
recipe("crawfisher", pal(red="#c8342a", red2="#e2603c", dark="#8a2420", belly="#f0c8a0", ink="#2a1410", eye="#f4f0d0", rock="#6e7480"),
 [L("ellipse", [48, 91], [70, 9], "rock", rim=False, pattern="speckle", pcolour="#8e94a0", density=30),
  line([[34, 74], [14, 86]], 2, "dark", mirror=True), line([[38, 78], [22, 92]], 2, "dark", mirror=True), line([[56, 78], [74, 92]], 2, "dark"),
  line([[40, 30], [18, 4]], 1.5, "red2", shade=False, mirror=True),
  poly([[40, 66], [56, 66], [62, 90], [34, 90]], "red"), poly([[38, 82], [58, 82], [64, 94], [32, 94]], "dark"),
  L("ellipse", [48, 56], [38, 44], "red"), L("ellipse", [48, 46], [28, 22], "red2", rim=False, pattern="speckle", pcolour="red", density=30),
  L("ellipse", [48, 33], [26, 22], "red"),
  poly([[36, 24], [40, 12], [44, 24]], "dark"), poly([[52, 24], [56, 12], [60, 24]], "dark"),
  L("ellipse", [22, 56], [14, 18], "red", angle=-20, mirror=True), L("ellipse", [14, 50], [9, 11], "dark", mirror=True)],
 [], [eyes([40, 31], 3.2, "eye")])

# Inaccessible Island rail: tiny round dark bird
recipe("thumbrail", pal(body="#4e4036", body2="#6e5c4a", belly="#7e8088", bill="#d8a8a0", leg="#c89890", ink="#1c1814", eye="#d83a2a", moss="#5e8a40", mist="#cfd8dc"),
 [L("ellipse", [48, 91], [50, 8], "moss", rim=False, pattern="speckle", pcolour="#7aa850", density=36),
  line([[42, 80], [40, 91]], 1.6, "leg", shade=False), line([[54, 80], [56, 91]], 1.6, "leg", shade=False),
  L("ellipse", [48, 64], [48, 44], "body"), L("ellipse", [48, 70], [34, 26], "belly", front_only=True, rim=False),
  L("ellipse", [48, 60], [40, 24], "body2", back_only=True, rim=False),
  L("ellipse", [30, 62], [12, 24], "body2", angle=12, mirror=True),
  L("circle", [48, 38], r=15, colour="body"), L("ellipse", [48, 31], [22, 8], "body2", rim=False)],
 [poly([[42, 40], [54, 40], [57, 46], [48, 49], [40, 46]], "bill")], [eyes([41, 36], 3.2)])

# Falklands wolf
recipe("warrah", pal(fur="#b8a488", fur2="#8e7c62", pale="#e8dcc4", white="#f8f4ea", ink="#241c16", eye="#e8d060", nose="#2a2018", mist="#d4dce0"),
 [L("ellipse", [48, 91], [64, 8], "mist", rim=False),
  line([[34, 76], [32, 92]], 5, "fur2", mirror=True), line([[60, 76], [62, 92]], 5, "fur2"),
  L("ellipse", [44, 62], [56, 36], "fur"), L("ellipse", [44, 70], [40, 20], "pale", rim=False, front_only=True),
  poly([[66, 58], [92, 70], [88, 78], [62, 68]], "fur2"), L("circle", [90, 74], r=5, colour="white"),
  L("ellipse", [34, 44], [26, 28], "fur"),
  poly([[24, 28], [28, 12], [36, 28]], "fur2"), poly([[38, 26], [44, 12], [48, 28]], "fur2"),
  L("ellipse", [28, 36], [24, 20], "fur"),
  poly([[8, 40], [22, 32], [22, 46]], "pale"), L("circle", [9, 41], r=2.6, colour="nose", rim=False)],
 [], [eyes([24, 34], 3.0, mirror=False)])

# Commerson's dolphin
recipe("pandolph", pal(white="#f4f4f6", black="#2a2e3a", black2="#464c5c", blue="#8ab8d4", blue2="#5e90b4", ink="#14161e", eye="#f4f4f6", foam="#e8f2f8"),
 [L("ellipse", [48, 88], [76, 10], "blue2", rim=False, pattern="speckle", pcolour="blue", density=40),
  L("ellipse", [48, 62], [70, 44], "white"), L("ellipse", [48, 50], [66, 26], "black"),
  L("ellipse", [48, 50], [64, 6], "black", rim=False),
  poly([[40, 44], [50, 14], [62, 46]], "black2"),
  poly([[8, 56], [26, 62], [14, 76]], "white"), poly([[6, 74], [16, 62], [22, 78]], "black2", front_only=False),
  L("ellipse", [24, 60], [18, 14], "black", angle=30, mirror=True),
  L("ellipse", [62, 56], [24, 22], "black"),
  poly([[70, 60], [88, 66], [70, 70]], "white", rim=True), L("ellipse", [68, 68], [14, 8], "white", rim=False)],
 [line([[72, 66], [84, 67]], 1.2, "ink", shade=False)], [eyes([60, 52], 3.0, "eye", mirror=False)])

# striated caracara
recipe("johnnyrook", pal(brown="#4a3a32", brown2="#6e5a4a", streak="#d8c4a0", face="#e8742c", face2="#f09a48", bill="#c8c4b4", leg="#e8a838", ink="#1c1410", eye="#e8c868", rock="#7e8088"),
 [L("ellipse", [48, 91], [60, 8], "rock", rim=False, pattern="speckle", pcolour="#a4a6ae", density=30),
  line([[40, 76], [38, 91]], 3, "leg"), line([[56, 76], [58, 91]], 3, "leg"),
  L("ellipse", [48, 62], [50, 46], "brown"), L("ellipse", [48, 66], [32, 32], "streak", front_only=True, pattern="speckle", pcolour="brown2", density=40),
  L("ellipse", [30, 60], [16, 36], "brown2", angle=8, mirror=True), poly([[40, 78], [56, 78], [60, 94], [36, 94]], "brown2", back_only=True),
  L("circle", [48, 34], r=15, colour="brown"), L("ellipse", [48, 38], [26, 22], "face", front_only=True)],
 [poly([[43, 38], [54, 38], [52, 49], [48, 52], [44, 47]], "bill"), poly([[40, 30], [34, 36], [42, 38]], "face2")], [eyes([42, 33], 3.4)])

# ---------------------------------------------------------------- writers
def write():
    for line_id, species in LINES.items():
        json.dump(stage_json(line_id, species), open(f"{ROOT}/data/creatures/{line_id}.json", "w"), indent=1, ensure_ascii=False)
    for rid, r in RECIPES.items():
        json.dump(r, open(f"{ROOT}/art/recipes/creatures/{rid}.json", "w"), indent=1)
    ids = [s["id"] for sp_ in LINES.values() for s in sp_]
    # dex_order: text insertion at the end of the appendix block
    p = f"{ROOT}/data/dex_order.json"
    txt = open(p).read()
    for i in ids:
        if f'"{i}"' not in txt:
            txt = re.sub(r'"\n\]\s*$', '",\n  "%s"\n]' % i, txt.rstrip() + "\n", count=1) if False else txt.rstrip()[:-1].rstrip() + ',\n  "%s"\n]\n' % i
    open(p, "w").write(txt)
    p = f"{ROOT}/data/knacks.json"
    txt = open(p).read()
    add = "".join(',\n    "%s": "%s"' % (s["id"], s["_knack"]) for sp_ in LINES.values() for s in sp_ if f'"{s["id"]}":' not in txt)
    if add:
        idx = txt.rstrip().rfind("}\n}") if False else None
        body = txt.rstrip()
        assert body.endswith("}\n}"), body[-20:]
        body = body[:-3].rstrip() + add + "\n  }\n}\n"
        open(p, "w").write(body)
    print("creatures:", ", ".join(ids))

if __name__ == "__main__":
    write()
