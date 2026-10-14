import math, random
from zlib import Z
from nwlib import *


def yr_wyddfa(OUT):
    z = Z("yr_wyddfa", "Yr Wyddfa (Snowdon)", 70, 44, kind="route", region="north_wales", music="route_mountain",
          weather={"fog": 45, "gale": 25, "drizzle": 15, "downpour": 5, "clear": 10})
    z.d["stage"] = "mountain"
    z.border("R", 3, gaps=[(56, 41, 3, 3)])
    SX, SY = 36, 12
    cones(z, [(SX, SY, 6, 1.5, 4), (16, 20, 5, 1.6, 2), (60, 16, 5, 1.6, 2), (10, 6, 4, 1.8, 2), (62, 4, 3, 1.8, 2)])
    # Llyn Llydaw below the Miners' Track
    z.rect(28, 30, 11, 4, "~"); z.rect(27, 30, 1, 4, "s"); z.rect(39, 30, 1, 4, "s"); z.rect(27, 29, 13, 1, "s"); z.rect(27, 34, 13, 1, "s")
    z.height(27, 29, 13, 6, 0)
    z.legend["r"] = {"tile": "shallow", "prop": "reeds"}
    # upland palette: grey-green turf, olive grass, stony paths (not lowland meadow green)
    z.legend["."] = {"tile": "grass", "colour": "#5f6b4c"}
    z.legend[","] = {"tile": "tall_grass", "colour": "#596340"}
    z.legend["#"] = {"tile": "path", "colour": "#8a8274"}
    z.legend["R"] = {"tile": "rock", "colour": "#6f6c64"}
    z.rect(30, 34, 5, 1, "r")
    # the zigzag up
    pth(z, [(57, 36), (57, 43)], "#", 1); z.rect(56, 41, 3, 3, "#"); z.rect(56, 36, 3, 6, "#")
    pth(z, [(57, 36), (22, 36)], "#")
    pth(z, [(22, 36), (22, 28)], "#")
    pth(z, [(22, 28), (44, 28)], "#")
    pth(z, [(44, 28), (44, 22)], "#")
    pth(z, [(44, 22), (36, 22)], "#")
    pth(z, [(36, 22), (36, 19)], "#", 1)
    z.rect(35, 19, 3, 1, "#")
    # tall grass on the lower slopes
    for (x, y, w, h) in [(4, 36, 14, 6), (46, 37, 8, 3), (24, 24, 8, 3), (46, 29, 8, 5), (38, 24, 5, 3), (4, 22, 10, 6), (58, 24, 8, 8), (48, 4, 12, 5), (14, 4, 10, 4)]:
        z.rect(x, y, w, h, ",")
    # rock, scrub and cairns on the flanks
    r = random.Random(81)
    for y in range(3, 41):
        for x in range(3, 67):
            if z.g[y][x] in ".," and r.random() < (0.45 if z.hg[y][x] >= 3 else 0.2 if z.hg[y][x] == 2 else 0):
                z.g[y][x] = "R"
    sprinkle(z, ["rock", "rock", "bush", "standing_stone"], 3, 3, 64, 38, 40, 82, on=".,")
    z.d["props"] = [p for p in z.d["props"] if p["type"] == "building" or math.hypot(p["x"] - SX, p["y"] - SY) > 7]
    # the summit ring: cliff and rock, a scree gap on the south, a cairn inside
    for y in range(z.h):
        for x in range(z.w):
            d = math.hypot(x - SX, y - SY)
            if 4.5 <= d < 6.5 and z.g[y][x] not in "~":
                z.g[y][x] = "^" if (x * 7 + y * 3) % 4 else "R"
    z.rect(35, 17, 3, 2, "/")
    z.rect(32, 8, 9, 9, "."); z.rect(34, 8, 5, 9, ".")
    for y in range(z.h):          # keep the summit disc clear again after the square above
        for x in range(z.w):
            d = math.hypot(x - SX, y - SY)
            if d < 4.5:
                z.g[y][x] = "."
            elif 4.5 <= d < 6.5 and not (35 <= x <= 37 and 17 <= y <= 18):
                z.g[y][x] = "^" if (x * 7 + y * 3) % 4 else "R"
    z.rect(35, 17, 3, 2, "/")
    # cave door under the summit lip, behind the scree
    z.building(35, 8, 3, 2, "stone", "Ogof Dinas Emrys", door=1)
    z.warp(36, 9, "dinas_emrys", 10, 15, "up")
    z.d["warps"][-1]["gate"] = "fell_scramble"
    # the cairn and standing stones
    for i, (x, y) in enumerate([(33, 11), (39, 11), (33, 14), (39, 14), (36, 15)]):
        z.prop("standing_stone", x, y, variant=i % 3)
    z.prop("rock", 36, 13); z.prop("rock", 35, 13, variant=1); z.prop("rock", 37, 13, variant=2); z.prop("rock", 36, 14)
    z.sign(36, 12, "YR WYDDFA. 1,085 m, highest peak in Wales. Please add one stone to the cairn. Do not take one. We counted.")
    # summit centre and railway
    z.building(50, 20, 7, 3, "stone", "Hafod Eryri")
    z.rect(53, 23, 1, 1, "#"); pth(z, [(53, 23), (53, 28)], "#")
    z.rect(46, 24, 1, 1, "."); z.rect(60, 23, 9, 1, "W")
    # signs
    z.sign(55, 40, "PYG TRACK / MINERS' TRACK / LLANBERIS PATH. Three ways up, one way to regret it: wearing the wrong socks.")
    z.sign(45, 29, "CAUTION: summit ahead, fog likely, views unlikely. NIWL / MIST. You'll get used to it.")
    z.sign(23, 27, "CLOGWYN: where the railway stops and the knees begin.")
    z.sign(28, 35, "LLYN LLYDAW. Water the colour of a very expensive jade ornament. Arthur's sword went in nearby, allegedly.")
    z.sign(34, 20, "SUMMIT: LOOSE SCREE ONLY. If you cannot fell-scramble, do not. If you can, do so with dignity.")
    moorland(z, 2, grass="#6a7150")
    z.d["encounters"] = {"grass": [
        {"species": "kidgruff", "min": 28, "max": 30, "weight": 22, "time": ["dawn", "day", "dusk"]},
        {"species": "prismite", "min": 29, "max": 31, "weight": 14, "time": ["day", "dusk"]},
        {"species": "tapknock", "min": 29, "max": 31, "weight": 18},
        {"species": "snowhare", "min": 28, "max": 30, "weight": 18, "weather": ["fog", "gale", "frost", "drizzle"]},
        {"species": "wispet", "min": 30, "max": 31, "weight": 14, "weather": ["fog"]},
        {"species": "hootlet", "min": 29, "max": 31, "weight": 10, "time": ["night"]},
        {"species": "slatelet", "min": 28, "max": 30, "weight": 14}],
        "water": [{"species": "dipling", "min": 28, "max": 30, "weight": 40}, {"species": "holtling", "min": 28, "max": 30, "weight": 40},
                  {"species": "afanc", "min": 29, "max": 31, "weight": 20}]}
    z.d["edges"] = {"south": {"to": "llanberis", "offset": 0}}
    z.d["spawn"] = [57, 40]
    # trainers
    trainer(z, "wyddfa_hiker", "Hiker Eurwen", "Hiker", "hiker", 30, 26, "down",
            [("kidgruff", 28), ("gritling", 29), ("prismite", 29)],
            ["Three thousand five hundred and sixty feet! I know because I've been told every time.", "Prove you're worthy of the summit!"],
            "Well fought! You've got the lungs for it.", "The summit's behind the scree. Practise your scrambling.")
    trainer(z, "wyddfa_runner", "Fell Runner Osian", "Fell Runner", "jogger", 46, 32, "down",
            [("snowhare", 29), ("roachroo", 29), ("tapknock", 30)],
            ["I run the Snowdon Race every year. Downhill's the hard bit. Knees. Ask the knees.", "Let's see if you can keep pace."],
            "You win. I'll go and cry quietly in a sheep field.", "Seven miles and six hundred metres of climb. Casual.")
    trainer(z, "wyddfa_warden_1", "Warden Fitch", "Warden", "warden_grunt", 35, 16, "down",
            [("slatelet", 29), ("prismite", 30), ("kidgruff", 30)],
            ["The summit is closed for a premium experience. Please queue at the cairn.", "Queue forms to the left. After a battle."],
            "Noted. For the record, the cairn queue is now cancelled.", "I'm only the first Warden. The second is meaner. He has a lanyard.")
    trainer(z, "wyddfa_warden_2", "Warden Lanyard", "Warden", "warden_grunt", 37, 16, "down",
            [("tapknock", 30), ("gritling", 30), ("snowhare", 31)],
            ["Silence! This summit is being curated for Director Pryce.", "I have a lanyard. It is very official."],
            "My lanyard! It's ... crooked. I'll ... yes. Move along.", "Director Pryce says the mountain's 'underperforming'. It's a mountain.")
    # story placeholder
    z.npc(id="pryce_summit", sprite="pryce", x=33, y=13, facing="right", move="still", script="summit", name="Director Pryce")
    talk("yr_wyddfa", "summit", "Director Pryce", "...placeholder Pryce at the summit. Story agent, replace me.")
    # chatty folk
    chat(z, "wyddfa_rangers", "villager_3", 53, 25, "Summit Ranger",
         ["Yr Wyddfa means 'the grave' or 'the burial mound'. Legend says a giant is buried under the cairn.",
          "It's the highest mountain in England and Wales. Yes, we checked. We got a ruler."], "down", "wander")
    chat(z, "wyddfa_rail", "villager_2", 58, 38, "Train Passenger",
         ["The little train goes up there, whistling, from Llanberis. Rack and pinion.",
          "I'm walking down. Tickets are single only. The mountain is also single only."], "left")
    chat(z, "wyddfa_sheep", "farmer", 25, 30, "Shepherd",
         ["There are sheep on every ledge. I'm not sure how they're getting up. Or why.",
          "Welsh Mountain sheep: hardy, shy, and unimpressed by lanyards."], "right", "wander")
    chat(z, "wyddfa_photographer", "birdwatcher", 47, 38, "Photographer",
         ["I'm waiting for the cloud to lift. I've been here since Tuesday.",
          "The Brocken spectre: sometimes your own shadow turns up in the mist, ringed with a rainbow. I'm hoping."], "up")
    z.save(OUT + "/yr_wyddfa.json")


def dinas_emrys(OUT):
    z = Z("dinas_emrys", "Dinas Emrys Cave", 22, 18, fill="c", kind="interior", region="north_wales", music="legend", weather={})
    z.d["stage"] = "cave"
    z.legend["c"] = {"tile": "floor_tile", "colour": "#6a6572"}
    z.border("x", 1)
    # irregular cave walls
    z.rect(1, 1, 20, 2, "R"); z.rect(1, 3, 3, 12, "R"); z.rect(18, 3, 3, 12, "R"); z.rect(4, 3, 2, 4, "R"); z.rect(16, 3, 2, 4, "R")
    z.rect(4, 12, 2, 3, "R"); z.rect(16, 12, 2, 3, "R"); z.rect(1, 15, 20, 1, "R"); z.rect(8, 15, 5, 1, "c")
    z.rect(9, 2, 3, 1, "c")
    # the pool where the dragons sleep
    z.rect(7, 5, 8, 6, "w"); z.rect(8, 6, 6, 4, "~")
    z.rect(10, 4, 2, 1, "c")
    for i, (x, y) in enumerate([(6, 4), (15, 4), (6, 11), (15, 11), (10, 13), (12, 13)]):
        z.prop("standing_stone", x, y, variant=i % 3)
    z.prop("rock", 5, 8); z.prop("rock", 16, 8, variant=1)
    z.set(10, 16, "D")
    z.warp(10, 16, "yr_wyddfa", 36, 10, "down")
    z.d["spawn"] = [10, 14]
    z.d["warps"][0]["tx"] = 36
    z.npc(id="ddraig_spot", sprite="villager_1", x=10, y=4, facing="down", move="still", script="ddraig", name="???")
    talk("dinas_emrys", "ddraig", "???", "...placeholder at the dragon pool. Story agent, replace me.")
    z.sign(11, 14, "DINAS EMRYS. Vortigern's tower kept falling down, because two dragons slept under it. Red and white. The red won. It's on the flag.")
    z.save(OUT + "/dinas_emrys.json")


def stubs(OUT):
    c = Z("chester", "Chester (stub)", 30, 30, kind="town", region="cheshire", music="town_cheshire")
    c.border("T", 3, gaps=[(0, 18, 3, 3)])
    c.d["edges"] = {"west": {"to": "dee_valley", "offset": 0}}
    c.d["spawn"] = [15, 19]
    c.save(OUT + "/chester.json")
    cc = Z("cambrian_coast", "Cambrian Coast (stub)", 40, 30, kind="route", region="mid_wales", music="route_coast")
    cc.border("T", 3, gaps=[(24, 0, 3, 3)])
    cc.d["edges"] = {"north": {"to": "llanberis", "offset": 0}}
    cc.d["spawn"] = [25, 10]
    cc.save(OUT + "/cambrian_coast.json")


def build(OUT):
    yr_wyddfa(OUT)
    dinas_emrys(OUT)
    stubs(OUT)
