# Part of england_north.py (exec'd in its namespace): Chat Moss.

# ====================================================================
# CHAT MOSS  72 x 40, bog route: Manchester (east) to Liverpool (west)
# ====================================================================
c = Z("chat_moss", "Chat Moss", 72, 40, kind="route", region="manchester", music="route_moor", fill="g",
      weather={"drizzle": 38, "fog": 24, "clear": 20, "downpour": 10, "sunshine": 8})
c.d["stage"] = "bog"
c.legend["g"] = {"tile": "grass", "colour": "#7f8248"}
c.legend["p"] = {"tile": "grass", "colour": "#5b4733"}
c.legend["m"] = {"tile": "tall_grass", "colour": "#a0b64e", "prop": "none"}
c.legend["h"] = HEATHER
c.legend["c"] = {"tile": "grass", "colour": "#b5be86"}
c.legend["b"] = BIRCH; c.legend["r"] = REEDS
c.border("T", 3, gaps=[(69, 24, 3, 3), (0, 20, 3, 3)])
c.scatter(0, 0, 72, 40, "b", 70, 301, only="T")
# the mossland itself: patches of peat, sphagnum, cotton grass
for (cx, cy, rx, ry) in [(15, 7, 8, 4), (30, 30, 9, 4), (52, 8, 8, 4), (64, 33, 6, 3), (45, 20, 5, 3), (8, 31, 6, 3), (20, 20, 5, 3), (60, 18, 5, 3)]:
    ell(c, cx, cy, rx, ry, "p", only="g")
for (cx, cy, rx, ry) in [(12, 26, 5, 3), (24, 12, 5, 3), (40, 34, 6, 3), (56, 27, 4, 3), (50, 14, 4, 3), (66, 21, 3, 3), (38, 7, 3, 3), (10, 16, 4, 3), (28, 22, 4, 2), (53, 36, 5, 2)]:
    ell(c, cx, cy, rx, ry, "m", only="gp")
for (cx, cy, rx, ry) in [(8, 36, 3, 2), (60, 12, 3, 2), (44, 28, 3, 2), (22, 36, 3, 2), (65, 37, 3, 2)]:
    ell(c, cx, cy, rx, ry, "c", only="gp")
for (cx, cy, rx, ry) in [(18, 33, 6, 3), (46, 11, 5, 3), (62, 33, 4, 3), (29, 8, 5, 3), (9, 9, 4, 3), (54, 21, 3, 2)]:
    pond(c, cx, cy, rx, ry, shore="p")
c.rect(0, 0, 72, 3, "T"); c.rect(0, 37, 72, 3, "T"); c.scatter(0, 0, 72, 40, "b", 70, 301, only="T")
# Stephenson's railway on its raft of heather
c.rect(32, 3, 3, 34, "h"); c.rect(36, 3, 3, 34, "h")
c.rect(35, 0, 1, 40, "!")
# peat cuttings: a long ditch, fenced
c.rect(43, 6, 1, 12, "w")
for y in (6, 9, 12, 15, 17): c.prop("slate_heap", 40, y, variant=3)  # peat stacks
for y in (7, 10, 13): c.prop("slate_heap", 45, y, variant=3)
# the route
ROUTE = [(71, 25), (58, 25), (58, 30), (46, 30), (46, 25), (24, 25), (24, 14), (12, 14), (12, 21), (0, 21)]
path(c, ROUTE, "g", 3); c.border("T", 3, gaps=[(69, 24, 3, 3), (0, 20, 3, 3)]); path(c, ROUTE, "#", 1)
c.rect(35, 25, 1, 1, "#")
c.rect(35, 24, 1, 1, "_")
# signal box and level crossing
c.building(37, 22, 3, 2, "white_render", "Signal Box")
c.prop("lamp_post", 34, 24); c.prop("lamp_post", 36, 26); c.prop("bollard", 34, 26); c.prop("bollard", 36, 24)
# the bramble side path to the hermit's hummock (gated: Hedge-lay)
c.rect(58, 4, 13, 9, "g"); c.rect(58, 13, 13, 1, "T"); c.rect(58, 3, 13, 1, "T"); c.rect(57, 4, 1, 10, "T"); c.rect(71, 4, 1, 10, "T")
ell(c, 64, 8, 4, 3, "h", only="g"); c.rect(64, 13, 1, 1, "%")
path(c, [(64, 14), (64, 24)], "#", 1)
c.rect(63, 13, 1, 1, "H"); c.rect(65, 13, 1, 1, "H")
c.building(62, 5, 4, 3, "slate_cottage", "Peat Hermit's Hut", door=1)
c.rect(63, 8, 1, 4, "#"); c.rect(63, 12, 2, 1, "#")
c.prop("standing_stone", 60, 6); c.prop("standing_stone", 69, 10, variant=1); c.prop("bench", 66, 9)
c.sign(65, 12, "PRIVATE MOSS. Do not feed the hermit. He has a pie.")
c.sign(66, 14, "BRAMBLES. Someone lives past them. Possibly a hermit. Possibly a very shy accountant.")
# signs
c.sign(70, 23, "CHAT MOSS. Seven miles of bog that swallowed three railway attempts. Stephenson won in the end.")
c.sign(36, 23, "STEPHENSON'S RAILWAY, 1830. Built floating on heather, brushwood and a few tonnes of ambition.")
c.sign(2, 23, "WEST: Liverpool, the Pier Head and a large number of birds. Keep hold of your chips.")
c.sign(41, 5, "PEAT WORKINGS. Moss wasn't built in a day. It was built over eight thousand years. Please don't dig it all up in an afternoon.")
c.sign(13, 22, "SPHAGNUM. Soaked up wounds in the First World War. Tougher than it looks. Wetter than it sounds.")
# trainers
for t in [("moss_dog", "Dog Walker Hazel", "Dog Walker", "villager_6", [("croakle", 15), ("pepperling", 16)], 440, 64, 21, "down",
           ["Ruffles has found a toad. Ruffles has found a lot of toads.", "I do apologise. We've been out here since breakfast."],
           "Well. That's me telling Ruffles off. Not you.", "Ruffles is under a bog bush. She says hello."),
          ("moss_angler", "Angler Barry", "Angler", "angler", [("holtling", 16), ("minkshade", 16), ("elverlet", 17)], 520, 49, 28, "right",
           ["I came here for the peace. And the possible eels.", "Quiet, you'll scare the fish. Or fight me, one of the two."],
           "That's frightened every fish for a mile.", "Eel season. Not a sausage. Not even a boot."),
          ("moss_student", "Student Kofi", "Student", "student", [("sphagnet", 16), ("croakle", 17)], 480, 28, 22, "down",
           ["I'm doing my dissertation on bogs. I need field data, and you're a field.", "Hold still, I'll take notes in battle."],
           "That's my methodology ruined. Excellent.", "The sphagnum is winning the dissertation. It's got more pages."),
          ("moss_birder", "Birdwatcher Gill", "Birdwatcher", "birdwatcher", [("starlet", 17), ("hootlet", 17), ("swiftlet", 18)], 560, 20, 19, "right",
           ["Hush! Lapwings! No, wait, that's a carrier bag.", "Do you mind? I've been after a curlew since Easter."],
           "Fine. The curlew can wait.", "A merlin flew over once. I've talked about nothing else since."),
          ("moss_runner", "Jogger Neil", "Jogger", "jogger", [("scuttlet", 16), ("brockling", 16), ("pipkin", 17)], 500, 6, 24, "up",
           ["Marathon training! Twenty-six miles of bog is brilliant for the calves!", "Keep up!"],
           "I'll stretch and think about what I've done.", "Next week it's the ultra. I haven't told my knees.")]:
    tid, nm, cls, spr, party, money, x, y, facing, intro, win, after = t
    trainer(tid, nm, cls, spr, party, money, intro, win, after)
    c.npc(id=tid, sprite=spr, x=x, y=y, facing=facing, move="still", trainer=tid)
# chatty NPCs
c.npc(id="moss_signalman", sprite="villager_4", x=38, y=25, facing="left", move="still", script="signalman", name="Signalman")
c.npc(id="moss_peat", sprite="villager_2", x=47, y=8, facing="down", move="still", script="peat_cutter", name="Peat Cutter")
c.npc(id="moss_botanist", sprite="villager_1", x=26, y=26, facing="up", move="wander", script="botanist", name="Botanist")
c.npc(id="moss_farmer", sprite="farmer", x=57, y=29, facing="down", move="wander", script="salad_farmer", name="Farmer")
c.npc(id="moss_hermit", sprite="villager_5", x=63, y=9, facing="down", move="still", script="hermit", name="Hermit")
say("chat_moss", "signalman", "Signalman", "George Stephenson built this line across the moss in 1830. Floated it on heather, brushwood and tonnes of spoil.", "It sinks about a foot every year and they top it up. Like my pension, but with trains.")
say("chat_moss", "peat_cutter", "Peat Cutter", "My granddad cut peat here for the gardens. Takes eight thousand years to make. We dug it in a week.", "A peat bog stores more carbon than all the forests in Britain. Don't take the mickey out of the damp.")
say("chat_moss", "botanist", "Botanist", "That's sphagnum moss. It can hold twenty times its own weight in water. In the First World War they used it as wound dressing.", "Chat Moss is one of the largest lowland raised bogs in England. Ten square miles of squelch.")
say("chat_moss", "salad_farmer", "Farmer", "They drained the edges of Chat Moss for farming. Best salad leaves in the north-west. Lettuces love a black soil.", "Mind the ditches. I lost a tractor in one in 1998. She's still down there, biding her time.")
DLG["chat_moss"]["hermit"] = [
    {"do": "say", "who": "Hermit", "text": "Ah. You found the brambles. Not many do."},
    {"do": "if", "flag": "moss_hermit_gift",
     "then": [{"do": "say", "who": "Hermit", "text": "I gave you what I had, mind. Come back for the soup when the moss is dry."}],
     "else": [{"do": "say", "who": "Hermit", "text": "I make my own snares out of bog oak and spite. Take some. They're sturdy."},
              {"do": "give_item", "item": "iron_snare", "n": 3},
              {"do": "set", "flag": "moss_hermit_gift"}]}]
c.d["encounters"] = {"grass": [
    {"species": "sphagnet", "min": 15, "max": 17, "weight": 24},
    {"species": "croakle", "min": 15, "max": 17, "weight": 22, "weather": ["drizzle", "downpour", "fog"]},
    {"species": "croakle", "min": 15, "max": 16, "weight": 8},
    {"species": "pepperling", "min": 15, "max": 17, "weight": 16, "time": ["dusk", "night", "dawn"]},
    {"species": "minkshade", "min": 16, "max": 18, "weight": 12, "time": ["dusk", "night"]},
    {"species": "elverlet", "min": 16, "max": 18, "weight": 10, "weather": ["drizzle", "downpour"]},
    {"species": "zigzlet", "min": 16, "max": 18, "weight": 10, "time": ["day", "dusk"]},
    {"species": "hootlet", "min": 16, "max": 18, "weight": 10, "time": ["dusk", "night"]},
    {"species": "wispet", "min": 16, "max": 18, "weight": 14, "weather": ["fog"]},
    {"species": "pipkin", "min": 15, "max": 16, "weight": 10, "time": ["dawn", "day"]},
    {"species": "scuttlet", "min": 15, "max": 16, "weight": 10, "time": ["day"]}],
    "water": [
    {"species": "croakle", "min": 15, "max": 17, "weight": 30},
    {"species": "elverlet", "min": 16, "max": 18, "weight": 28},
    {"species": "minkshade", "min": 16, "max": 18, "weight": 20},
    {"species": "holtling", "min": 15, "max": 17, "weight": 20}]}
c.d["edges"] = {"east": {"to": "manchester", "offset": 0}, "west": {"to": "liverpool", "offset": 0}}
c.d["spawn"] = [68, 25]
deco(c, 3, 3, 66, 34, ["birch", "bush", "rock"], 70, 311, on="gp")
deco(c, 3, 3, 66, 34, ["birch", "bush"], 24, 312, on="m")
for (cx, cy, rx, ry) in [(40, 20, 3, 2), (4, 28, 2, 2), (50, 33, 3, 2), (16, 25, 3, 2)]:
    pond(c, cx, cy, rx, ry, shore="p")
for (cx, cy) in [(8, 20), (20, 8), (28, 34), (44, 30), (52, 24), (14, 30), (56, 8), (66, 28), (40, 12), (6, 12), (48, 34), (22, 28), (60, 22)]:
    ell(c, cx, cy, 3, 2, "h", only="gpm")
c.scatter(3, 3, 66, 34, "f", 80, 314, only="m")
c.scatter(3, 3, 66, 34, "f", 40, 315, only="c")
reedify(c, 0.55, 316)
deco(c, 3, 3, 66, 34, ["rock", "bush", "birch", "birch"], 70, 317, on="gpc")
deco(c, 3, 3, 66, 34, ["bush"], 30, 318, on="mh")
c.save(OUT + "/chat_moss.json")
