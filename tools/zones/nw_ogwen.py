from zlib import Z
from nwlib import *


def ogwen(OUT):
    z = Z("ogwen", "Nant Ffrancon and Ogwen", 72, 36, kind="route", region="north_wales", music="route_mountain",
          weather={"fog": 28, "drizzle": 22, "gale": 14, "clear": 14, "sunshine": 6, "downpour": 10, "frost": 6})
    z.d["stage"] = "mountain"
    z.border("R", 2, gaps=[(0, 18, 2, 3), (70, 18, 2, 3)])
    # heights: valley floor 0, a two-step drop at x 38-39, the Ogwen plateau at 2
    z.height(38, 0, 2, 36, 1); z.height(40, 0, 32, 36, 2)
    cones(z, [(54, 31, 6, 1.3, 2.5),      # Tryfan
              (56, 2, 4, 1.3, 4),         # Pen yr Ole Wen shoulder
              (14, 3, 6, 1.5, 4), (30, 3, 5, 1.6, 3),   # Carneddau flank
              (18, 32, 5, 1.6, 3), (6, 30, 4, 1.6, 2)]) # Glyder flank
    z.rect(47, 9, 17, 14, "w")           # the lake and its rim
    z.height(47, 9, 17, 14, 2)
    z.rect(48, 10, 15, 12, "~"); z.rect(51, 13, 9, 6, "o")
    z.rect(48, 22, 15, 1, "s")
    for (cx, cy) in [(48, 10), (62, 10), (48, 21), (62, 21)]:
        z.set(cx, cy, "w")
    z.legend["r"] = {"tile": "shallow", "prop": "reeds"}
    z.rect(49, 9, 5, 1, "r"); z.rect(58, 9, 4, 1, "r")
    # the drop: cliffs with a path ramp (north) and a scree ramp (south)
    z.rect(38, 3, 2, 30, "^")
    z.rect(36, 7, 6, 2, "#"); z.rect(38, 23, 2, 2, "/")
    z.rect(36, 23, 2, 2, "#"); z.rect(40, 23, 2, 2, "#")
    # paths: east entry, around the lake's east shore, over the ridge, or along the south shore and up the scree
    pth(z, [(64, 19), (71, 19)], "#"); z.rect(70, 18, 2, 3, "#")
    pth(z, [(64, 5), (64, 23)], "#"); pth(z, [(41, 5), (64, 5)], "#"); pth(z, [(41, 5), (41, 8)], "#")
    pth(z, [(40, 23), (64, 23)], "#")
    # valley paths: connector x=30, west run y=19
    pth(z, [(30, 7), (36, 7)], "#"); z.rect(30, 8, 6, 1, "#")
    pth(z, [(30, 7), (30, 24)], "#"); z.rect(30, 23, 8, 2, "#")
    pth(z, [(0, 19), (30, 19)], "#"); z.rect(0, 18, 3, 3, "#")
    # Afon Ogwen: a stream with a stone bridge
    z.rect(18, 3, 2, 30, "~"); z.height(18, 3, 2, 30, 0)
    z.rect(18, 19, 2, 1, "="); z.rect(18, 18, 2, 1, "W"); z.rect(18, 20, 2, 1, "W")
    z.prop("lamp_post", 17, 18); z.prop("lamp_post", 20, 18)
    # Tryfan: a scrambling path, Adam and Eve at the top
    pth(z, [(56, 23), (56, 26), (46, 26), (46, 29), (51, 29)], "#")
    z.rect(52, 29, 5, 5, ".")
    z.prop("standing_stone", 53, 30, variant=0); z.prop("standing_stone", 55, 30, variant=1)
    z.sign(54, 32, "TRYFAN, 917 m. ADAM AND EVE, the two stones on top. Jumping between them is traditional. Landing is optional.")
    # grass: tall patches by the paths
    for (x, y, w, h) in [(65, 6, 5, 11), (42, 10, 4, 12), (50, 24, 5, 2), (60, 24, 4, 2), (21, 12, 7, 6), (4, 12, 10, 5),
                         (4, 22, 12, 4), (22, 21, 7, 4), (31, 10, 6, 8), (31, 25, 6, 4), (43, 6, 20, 2)]:
        z.rect(x, y, w, h, ",")
    # valley dressing: slate tips and Idwal Cottage, drystone walls, rocks and the odd tree
    z.building(6, 22, 4, 3, "slate_cottage", "Idwal Cottage")
    z.rect(7, 25, 1, 3, "#")
    z.rect(3, 11, 15, 1, "W"); z.rect(21, 11, 8, 1, "W"); z.rect(31, 27, 6, 1, "W")
    z.rect(21, 27, 8, 1, "W"); z.rect(3, 28, 14, 1, "W")
    z.rect(22, 11, 1, 1, "."); z.rect(24, 11, 1, 1, ".")
    sprinkle(z, ["slate_heap"], 4, 13, 12, 5, 10, 61, on=".,")
    sprinkle(z, ["rock", "rock", "bush", "oak", "birch"], 3, 10, 34, 18, 40, 62, on=".")
    sprinkle(z, ["rock", "rock", "bush", "pine"], 40, 3, 30, 30, 36, 63, on=".")
    sprinkle(z, ["pine", "rock"], 42, 24, 20, 8, 12, 64, on=".")
    # rock faces on the high slopes: unwalkable rock where it is steep and off the paths
    import random
    r = random.Random(65)
    for y in range(2, 34):
        for x in range(2, 70):
            hh = z.hg[y][x]
            pr = 0.5 if hh >= 4 else 0.38 if hh >= 3 else (0.16 if (hh >= 2 and x < 36) else 0)
            if z.g[y][x] in ".," and r.random() < pr and not (46 <= x <= 56 and 26 <= y <= 29) and not (50 <= x <= 57 and 29 <= y <= 33):
                z.g[y][x] = "R"
    moorland(z, 2)
    z.d["encounters"] = {
        "grass": [
            {"species": "kidgruff", "min": 25, "max": 27, "weight": 22, "time": ["dawn", "day", "dusk"]},
            {"species": "slatelet", "min": 25, "max": 27, "weight": 20},
            {"species": "prismite", "min": 26, "max": 28, "weight": 14, "time": ["day", "dusk"]},
            {"species": "martling", "min": 26, "max": 28, "weight": 14, "time": ["dusk", "night"]},
            {"species": "tylwyth", "min": 26, "max": 27, "weight": 10, "time": ["dawn", "dusk"]},
            {"species": "snowhare", "min": 26, "max": 28, "weight": 14, "weather": ["fog", "gale", "frost"]},
            {"species": "wispet", "min": 27, "max": 28, "weight": 10, "weather": ["fog"]},
            {"species": "hootlet", "min": 26, "max": 28, "weight": 10, "time": ["night"]}],
        "water": [
            {"species": "afanc", "min": 26, "max": 28, "weight": 30},
            {"species": "dipling", "min": 25, "max": 27, "weight": 30},
            {"species": "holtling", "min": 25, "max": 27, "weight": 25, "time": ["dawn", "day"]},
            {"species": "elverlet", "min": 26, "max": 28, "weight": 15, "weather": ["drizzle", "downpour", "fog"]}]}
    z.d["edges"] = {"east": {"to": "llangollen", "offset": 0}, "west": {"to": "llanberis", "offset": 0}}
    z.d["spawn"] = [68, 19]
    # signs
    z.sign(66, 18, "LLYN OGWEN. Cold, deep and in no mood to be swum. Deep water ahead needs a brook-wader.")
    z.sign(35, 8, "NANT FFRANCON. A glacier carved this valley, then left. Mind the steps (all the steps).")
    z.sign(37, 22, "SCREE SHORTCUT. Loose rock, short cut, long fall. Fell-scramble only. (Rhybudd: llithrig.)")
    z.sign(42, 4, "PEN YR OLE WEN. 'Head of the Hill of the Fall.' Welsh place names are honest.")
    z.sign(3, 17, "WEST: Llanberis and Yr Wyddfa. Gorllewin. Pack a coat; Cymru has several seasons per hour.")
    z.sign(69, 17, "EAST: Llangollen and the Dee. Dwyrain. Yes, there's a lot of up in between.")
    z.sign(21, 21, "BETHESDA SLATE TIPS. The Penrhyn quarry roofed half the world. Please do not take a roof home.")
    z.sign(57, 25, "TRYFAN NORTH FACE. No path, no handrail, and no apologies. Hands required (use them).")
    # trainers
    trainer(z, "ogwen_fellrunner", "Fell Runner Rhodri", "Fell Runner", "jogger", 68, 16, "down",
            [("roachroo", 25), ("snowhare", 26), ("kidgruff", 26)],
            ["I ran up Tryfan, down Tryfan and round the lake, all before my toast.", "Race you. Winner takes the cold tea."],
            "You're faster than the weather. Worrying.", "Fell running is just walking with regrets.")
    trainer(z, "ogwen_student", "Student Elin", "Student", "student", 50, 7, "up",
            [("slatelet", 26), ("prismite", 27)],
            ["I'm doing a dissertation on glaciers. Look, a U-shaped valley! Marvellous!", "Please validate my fieldwork with a battle."],
            "I'll cite you. In a footnote. A big one.", "Cwm Idwal was where Darwin worked out the ice had been here. He wasn't wrong.")
    trainer(z, "ogwen_warden_1", "Warden Cartwright", "Warden", "warden_grunt", 50, 24, "down",
            [("tapknock", 27), ("kidgruff", 27)],
            ["Ahem! The Enclosure is 'curating' Tryfan. Do you have a permit to be so scenic?", "No? Then it's a fine."],
            "I'll note that in my curation report. Under 'rude'.", "We'll be back. With a clipboard.")
    trainer(z, "ogwen_warden_2", "Warden Pimm", "Warden", "warden_grunt", 49, 31, "up",
            [("slatelet", 27), ("prismite", 28), ("gritling", 27)],
            ["This path is a Heritage Experience. It costs eight pounds and a smile.", "I'll accept the smile after a battle."],
            "A smile was in the price, I'm afraid. That one was more of a grimace.", "The goat has refused to be curated. We're negotiating.")
    trainer(z, "ogwen_hiker", "Hiker Gethin", "Hiker", "hiker", 24, 16, "down",
            [("gritling", 27), ("kidgruff", 27), ("martling", 28)],
            ["Tryfan, the Glyders, Pen yr Ole Wen. A grand day, if you ignore the rain.", "Show me what your team's made of!"],
            "Well fought. Fancy a flapjack? It's mostly oat.", "The Welsh word for the weather is 'tywydd'. It translates as 'surprise'.")
    # chatty folk
    chat(z, "ogwen_ranger", "villager_3", 66, 21, "Warden of the Park",
         ["Snowdonia is Eryri, the 'Place of Eagles'. The park's been protected since 1951.",
          "Tryfan is 917 metres. You need your hands to climb it, which is rare for a mountain with a pub-sounding name."], "up", "wander")
    chat(z, "ogwen_climber", "hiker", 44, 24, "Climber",
         ["The two stones on top of Tryfan are Adam and Eve. People jump between them for luck.",
          "I have never jumped. I have, however, thought about it extensively."], "right")
    chat(z, "ogwen_geo", "student", 34, 10, "Geology Student",
         ["Nant Ffrancon is a classic glacial valley: U-shaped, flat floor, steep sides. Textbook.",
          "Cwm Idwal over there is where Darwin came to look at rocks. He loved rocks, then wrote about finches."], "down")
    chat(z, "ogwen_farmer", "farmer", 26, 14, "Hill Farmer",
         ["Telford's A5 comes through here. 1820s. London to Holyhead, with sheep on it.",
          "The sheep don't use the road. They're just near it. Constantly."], "down", "wander")
    chat(z, "ogwen_cafe", "villager_4", 15, 20, "Hostel Keeper",
         ["Idwal Cottage is the youth hostel. Bunk beds, bacon, and a view that makes the bunk beds worthwhile.",
          "Llyn Ogwen's the lake over there. It's cold enough to cure a hangover or cause a bigger one."], "down")
    z.save(OUT + "/ogwen.json")


def llanberis(OUT):
    z = Z("llanberis", "Llanberis", 64, 42, kind="town", region="north_wales", music="town_wales",
          weather={"drizzle": 38, "fog": 18, "clear": 18, "gale": 8, "sunshine": 10, "downpour": 8})
    z.d["stage"] = "town"; z.d["town_id"] = "llanberis"
    z.border("P", 3, gaps=[(61, 18, 3, 3), (24, 39, 3, 3), (56, 0, 3, 3)])
    z.scatter(0, 0, 64, 42, "T", 55, 401, only="P")
    # mountains behind: foothills up the north-east
    cones(z, [(48, 2, 3, 1.4, 4), (36, 2, 2, 1.5, 3), (8, 22, 3, 1.2, 2)])
    # Llyn Padarn, south-west, with a sandy shore
    z.rect(3, 26, 20, 1, "s"); z.rect(22, 27, 1, 12, "s"); z.rect(3, 27, 19, 12, "~")
    z.height(3, 26, 20, 13, 0)
    z.prop("boat", 8, 31, variant=1); z.prop("boat", 15, 34, variant=1); z.prop("buoy", 12, 29); z.prop("buoy", 18, 31, variant=1)
    z.rect(10, 38, 4, 1, "w")
    # main street
    z.rect(15, 18, 49, 1, ":"); z.rect(15, 19, 49, 1, "="); z.rect(15, 20, 49, 1, ":")
    z.rect(61, 18, 3, 3, "=")
    pth(z, [(24, 20), (24, 41)], "#", 3)
    # north side: a terrace of slate cottages, Sanctuary, Corner Shop, chapel
    z.building(23, 14, 3, 3, "slate_cottage", show_label=False)
    z.building(27, 13, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.building(34, 13, 5, 4, "shop", "Corner Shop", door=2)
    z.building(39, 14, 4, 3, "slate_cottage", "Bryn Eglwys")
    z.rect(46, 13, 10, 5, "."); z.rect(47, 14, 8, 2, "f")
    z.prop("planter", 46, 16); z.prop("planter", 55, 16); z.prop("bench", 50, 16); z.prop("bench", 52, 16)
    z.building(51, 3, 4, 3, "chapel", "Capel Coch")
    z.rect(23, 17, 32, 1, ":")
    z.warp(30, 16, "llanberis_sanctuary", 5, 6, "up"); z.warp(36, 16, "llanberis_shop", 4, 5, "up")
    # the Snowdon Mountain Railway station
    z.building(46, 9, 6, 2, "station", "Snowdon Mountain Railway", door=2)
    z.rect(45, 11, 8, 1, "_"); z.rect(46, 12, 10, 1, "!")
    pth(z, [(44, 11), (44, 18)], "#")
    z.d["station"] = {"x": 48, "y": 11}
    z.npc(id="rail_guard", sprite="rail_guard", x=50, y=11, facing="left", move="still", script="rail_guard", name="Rail Guard")
    DLG.setdefault("llanberis", {})["rail_guard"] = say("Rail Guard", "Snowdon Mountain Railway, the only rack railway in Britain. Mind the teeth.") + [{"do": "rail"}]
    z.prop("lamp_post", 46, 11); z.prop("lamp_post", 52, 11); z.prop("bench", 53, 11)
    # path north-east, up to Yr Wyddfa
    pth(z, [(56, 3), (56, 18)], "#", 3)
    z.rect(56, 19, 3, 1, "=")
    # Electric Mountain and cottages on the south side
    z.building(39, 24, 12, 5, "stone", "Electric Mountain")
    z.building(28, 22, 3, 3, "slate_cottage", show_label=False)
    z.building(32, 22, 4, 3, "slate_cottage", "Caffi Padarn")
    z.building(54, 23, 5, 4, "terrace", show_label=False)
    z.rect(40, 29, 10, 1, "#"); z.rect(40, 22, 1, 2, "#"); z.rect(45, 22, 1, 2, "#"); z.rect(56, 22, 1, 1, "#")
    z.rect(29, 25, 1, 1, "#"); z.rect(34, 25, 1, 1, "#")
    pth(z, [(29, 21), (29, 26)], "#"); pth(z, [(34, 21), (34, 26)], "#")
    # Dolbadarn castle on its hill
    z.building(7, 23, 5, 3, "castle", "Dolbadarn Castle")
    pth(z, [(15, 19), (15, 27)], "#"); pth(z, [(9, 27), (15, 27)], "#"); pth(z, [(9, 26), (9, 27)], "#")
    # the Dinorwic quarry gates, north-west, with slate terraces behind
    z.height(3, 3, 26, 3, 3); z.height(3, 6, 26, 2, 2); z.height(3, 8, 26, 2, 1)
    z.rect(3, 5, 26, 1, "^"); z.rect(3, 7, 26, 1, "^"); z.rect(3, 9, 26, 1, "^")
    z.building(12, 10, 8, 4, "stone", "Dinorwic Quarry Gates", door=3)
    z.warp(15, 13, "llanberis_quarry", 17, 29, "up")
    pth(z, [(15, 14), (15, 19)], "#", 1)
    z.rect(3, 14, 12, 1, "W"); z.rect(17, 14, 12, 1, "W")
    z.rect(14, 14, 3, 1, "#")
    z.prop("slate_heap", 5, 11); z.prop("slate_heap", 8, 12, variant=1); z.prop("slate_heap", 23, 11); z.prop("slate_heap", 26, 12, variant=2)
    z.prop("slate_heap", 21, 6); z.prop("slate_heap", 7, 4, variant=1); z.prop("slate_heap", 12, 3); z.prop("slate_heap", 24, 4, variant=2)
    for x in (3, 5, 7, 10, 22, 26, 28):
        pass
    z.rect(3, 15, 11, 2, ","); z.rect(17, 15, 4, 2, ",")
    z.rect(3, 17, 11, 4, ".")
    z.building(4, 18, 4, 3, "slate_cottage", show_label=False)
    z.building(9, 18, 4, 3, "slate_cottage", show_label=False)
    # tall grass by the lake and on the slopes
    for (x, y, w, h) in [(3, 22, 4, 4), (13, 21, 7, 3), (17, 28, 4, 8), (42, 31, 16, 4), (58, 29, 3, 8), (50, 3, 5, 5), (36, 3, 8, 4)]:
        z.rect(x, y, w, h, ",")
    z.rect(43, 22, 1, 1, ".")
    z.rect(26, 27, 12, 10, ".")
    z.rect(26, 30, 12, 1, "H")
    z.rect(32, 31, 6, 6, "f")
    z.prop("statue", 29, 33); z.prop("bench", 27, 33); z.prop("bench", 31, 28); z.prop("lamp_post", 28, 28); z.prop("lamp_post", 36, 28)
    for (x, y) in [(27, 29), (37, 29), (27, 36), (37, 36), (30, 36)]:
        z.prop("oak", x, y, variant=(x + y) % 3)
    sprinkle(z, ["oak", "birch", "bush", "planter", "bench", "rock"], 3, 14, 58, 26, 48, 411)
    sprinkle(z, ["pine", "rock", "bush"], 33, 3, 24, 8, 18, 412)
    for x in (16, 22, 28, 34, 40, 46, 52, 58):
        z.prop("lamp_post", x, 21)
    z.prop("phone_box", 25, 21)
    z.sign(23, 19, "LLANBERIS. Croeso i Lanberis. Welcome! Population: some people and a great many sheep.")
    z.sign(60, 17, "EAST: Nant Ffrancon, Llyn Ogwen, Tryfan. Dwyrain. Bring chocolate.")
    z.sign(57, 4, "YR WYDDFA (SNOWDON). 1,085 m. Walk, or ride the little train. The mountain does not mind. It has seen it all.")
    z.sign(25, 38, "SOUTH: Cambrian Coast. Y De. Please do not feed the seagulls. They have a union too.")
    z.sign(16, 17, "DINORWIC QUARRY. 1787 to 1969. Hard hats provided. Hard heads optional.")
    z.sign(43, 22, "ELECTRIC MOUNTAIN. A power station inside a mountain. Wales: 'we put the lights on, under a hill'.")
    z.sign(9, 25, "DOLBADARN CASTLE. 13th century. One round tower, a lot of Welsh princes, no roof. Still standing.")
    z.d["encounters"] = {"grass": [
        {"species": "kidgruff", "min": 27, "max": 28, "weight": 22, "time": ["dawn", "day", "dusk"]},
        {"species": "slatelet", "min": 27, "max": 29, "weight": 22},
        {"species": "prismite", "min": 28, "max": 29, "weight": 14, "time": ["day", "dusk"]},
        {"species": "tapknock", "min": 28, "max": 29, "weight": 14, "time": ["dusk", "night"]},
        {"species": "snowhare", "min": 27, "max": 29, "weight": 12, "weather": ["fog", "gale"]},
        {"species": "wispet", "min": 28, "max": 29, "weight": 8, "weather": ["fog"]}],
        "water": [{"species": "holtling", "min": 27, "max": 28, "weight": 40}, {"species": "dipling", "min": 27, "max": 29, "weight": 40},
                  {"species": "elverlet", "min": 28, "max": 29, "weight": 20}]}
    z.d["edges"] = {"east": {"to": "ogwen", "offset": 0}, "south": {"to": "cambrian_coast", "offset": 0},
                    "north": {"to": "yr_wyddfa", "offset": 0}}
    z.d["spawn"] = [58, 19]
    # story placeholder
    z.npc(id="pryce", sprite="pryce", x=17, y=15, facing="up", move="still", script="pryce_quarry", name="Director Pryce")
    talk("llanberis", "pryce_quarry", "Director Pryce", "...placeholder Pryce at the quarry gates. Story agent, replace me.")
    chat(z, "porter", "villager_2", 43, 13, "Railway Porter",
         ["The Snowdon Mountain Railway opened in 1896. It's a rack and pinion line, so the train grips the track with teeth.",
          "Four and a half miles to the summit. Takes an hour. Walkers say we cheat. We say we sit down."], "right")
    chat(z, "lake_angler", "angler", 21, 25, "Angler",
         ["Llyn Padarn has a fish that lives nowhere else in Britain much: the torgoch, or Welsh char. Red belly.",
          "I've not caught one. I've caught a lot of reeds."], "right")
    chat(z, "castle_guide", "tour_guide", 12, 27, "Castle Guide",
         ["Dolbadarn Castle: Prince Llywelyn the Great's round tower, built around 1230. One tower, lots of staircase.",
          "The roof is missing. The staircase is, frankly, optional."], "up", "wander")
    chat(z, "slate_veteran", "villager_5", 11, 16, "Retired Quarryman",
         ["Dinorwic closed in 1969. Thousands worked there, in all weathers, on galleries cut into the hill.",
          "Slate roofs from here are on houses in Hamburg and Australia. Wales: exporting rain protection since forever."], "left")
    chat(z, "cafe_owner", "villager_4", 36, 18, "Caffi Owner",
         ["Te? Coffi? Cacen? Say it with me. It means tea, coffee, cake. In that order of priority.",
          "We also do a full Welsh breakfast, a rare treat. It comes with laverbread. Try it, or don't."], "up")
    chat(z, "scout_kid", "villager_1", 47, 22, "Boy Scout",
         ["I'm earning my 'walked up Snowdon' badge. I did half. The train did the other half.",
          "Yr Wyddfa means 'the burial mound'. A giant's grave, they say. Rather big for a gravestone."], "left", "wander")
    z.save(OUT + "/llanberis.json")
    town_interiors(OUT, "llanberis", "Llanberis", (30, 17), (36, 17),
                   ["Croeso! Welcome to the Sanctuary. Kettle's on. It's always on. We're in Wales.",
                    "Hand over your team. We'll have them fit for the mountain in a tick.",
                    "All better! Mind the stairs, a goat got in last week and left opinions.",
                    "The Ark terminal's by the radiator. Keep your fingers clear of the hard drive.",
                    "No bother. Shout if anyone needs a cuppa or a blister plaster."],
                   ["Croeso! Snares, tea, bara brith and waterproofs you'll be needing. All the waterproofs.",
                    "Hwyl! Mind how you go. Wear the hat. It's not a suggestion."])


def quarry(OUT):
    z = Z("llanberis_quarry", "Dinorwic Quarry", 36, 34, kind="route", region="north_wales", music="battle_keeper",
          weather={"fog": 20, "drizzle": 30, "clear": 35, "gale": 10, "sunshine": 5})
    z.d["stage"] = "quarry"
    z.border("R", 2)
    z.rect(2, 2, 32, 28, ".")
    # terraces (levels 0, 1, 2, 3), cliff faces with a gap to climb through
    z.height(2, 24, 32, 6, 0); z.height(2, 23, 32, 1, 1); z.height(2, 17, 32, 6, 1)
    z.height(2, 16, 32, 1, 2); z.height(2, 10, 32, 6, 2); z.height(2, 9, 32, 1, 3); z.height(2, 2, 32, 7, 3)
    for (fy, gx) in [(23, 6), (16, 28), (9, 6)]:
        z.rect(2, fy, 32, 1, "^"); z.rect(gx, fy, 2, 1, "#")
    # the wall and gate
    z.rect(2, 30, 32, 1, "W"); z.set(17, 30, "D")
    z.warp(17, 30, "llanberis", 15, 14, "down")
    # paths: gate, up x=6, along terrace 1 to x=28, up, along terrace 2 back to x=6, up to the arena
    pth(z, [(17, 29), (17, 25), (6, 25)], "#"); pth(z, [(6, 25), (6, 23)], "#", 2)
    z.rect(6, 20, 24, 2, "#"); z.rect(6, 22, 2, 1, "#")
    z.rect(28, 16, 2, 5, "#")
    z.rect(6, 13, 24, 2, "#"); z.rect(28, 15, 2, 1, "#")
    z.rect(6, 9, 2, 5, "#"); z.rect(6, 8, 2, 1, "#")
    z.rect(6, 7, 6, 1, "#")
    # the arena floor on top
    z.rect(10, 3, 18, 5, ":"); z.rect(12, 7, 14, 1, ":")
    z.rect(7, 7, 5, 1, "#")
    # slate everywhere
    z.building(8, 26, 4, 2, "slate_cottage", "Powder Store")
    z.building(24, 11, 4, 2, "slate_cottage", "Barracks (the quarry kind)")
    z.building(10, 17, 4, 2, "slate_cottage", show_label=False)
    sprinkle(z, ["slate_heap"], 3, 3, 30, 26, 85, 71, on=".")
    sprinkle(z, ["rock", "rock", "pine", "bush"], 3, 3, 30, 26, 36, 72, on=".")
    z.building(22, 17, 4, 2, "slate_cottage", "Weighbridge")
    z.rect(30, 3, 3, 5, "R"); z.rect(3, 3, 3, 5, "R")
    z.rect(18, 11, 1, 1, "."); z.prop("bench", 22, 5); z.prop("bench", 26, 5)
    z.prop("lamp_post", 9, 4); z.prop("lamp_post", 27, 4); z.prop("lamp_post", 16, 29); z.prop("lamp_post", 18, 29)
    z.prop("standing_stone", 13, 3, variant=0); z.prop("standing_stone", 25, 3, variant=1)
    z.sign(15, 28, "ELUNED'S GALLERY. Rock Keeper on the top terrace. Hard hats beyond this wall. Hard heads too.")
    z.sign(9, 24, "NO LOITERING (the slate is loose). NID YW'N DDIOGEL: not safe. Climb on.")
    z.sign(27, 15, "TERRACE 2. Up. The only way is up. Up is also the only way down, if you count falling.")
    z.d["spawn"] = [17, 28]
    z.d["encounters"] = {}
    trainer(z, "quarry_junior_1", "Quarryman Idris", "Hiker", "hiker", 16, 18, "down",
            [("slatelet", 26), ("kidgruff", 26)],
            ["Hard hats on. This is Eluned's gallery. She's a bit particular about the slate.", "You'll have to get past me first."],
            "Fair play. You've a head harder than slate.", "Mind the gap at the top. Eluned says it builds character.")
    trainer(z, "quarry_junior_2", "Apprentice Cerys", "Student", "student", 16, 11, "down",
            [("gritling", 27), ("slatelet", 27)],
            ["I'm Keeper Eluned's apprentice. I carry the spirit level and the grudges.", "Show me you can handle stone!"],
            "She'll say I should have used a lever. She says that about everything.", "On you go. Eluned's at the top. She hasn't blinked since 1998.")
    z.npc(id="keeper_eluned", sprite="keeper_eluned", x=18, y=4, facing="down", move="still", script="keeper_eluned", name="Keeper Eluned")
    talk("llanberis_quarry", "keeper_eluned", "Keeper Eluned", "...placeholder Keeper Eluned. Story agent, replace me.")
    z.save(OUT + "/llanberis_quarry.json")


def build(OUT):
    ogwen(OUT)
    llanberis(OUT)
    quarry(OUT)
