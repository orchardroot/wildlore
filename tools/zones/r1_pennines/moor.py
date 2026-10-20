from lib import *

MOOR_LEGEND = {
    ".": {"tile": "grass", "colour": "#7f7b49"},
    "m": {"tile": "grass", "colour": "#77804a"},
    "n": {"tile": "grass", "colour": "#8a7046"},
    "e": {"tile": "grass", "colour": "#7a7448", "prop": "heather"},
    "h": {"tile": "tall_grass", "colour": "#655060", "prop": "heather"},
    "k": {"tile": "tall_grass", "colour": "#7c7a47", "prop": "short"},
    "R": {"tile": "rock", "colour": "#7d7a4a"},
    "G": {"tile": "rock", "colour": "#6f6852", "prop": "gritstone"},
    "W": {"tile": "drystone_wall", "colour": "#76734a"},
    "r": {"tile": "shallow", "prop": "reeds"},
    "v": {"tile": "grass", "colour": "#6d7a52"},  # village green
}


def build():
    z = Zone("saddleworth_moor", "Saddleworth Moor", 64, 44, fill="m", kind="route")
    z.extra = MOOR_LEGEND
    W, H = z.w, z.h
    # rough moor texture first
    import random
    rnd = random.Random(1811)
    for y in range(H):
        for x in range(W):
            r = rnd.random()
            z.g[y][x] = "m" if r < 0.55 else ("." if r < 0.8 else ("n" if r < 0.93 else "e"))
    # gritstone edge along the top, rough rock along the foot, walls of rock at the sides
    z.rect(0, 0, W, 1, "R")
    z.rect(0, 1, W, 1, "G")
    z.rect(0, H - 2, W, 2, "R")
    z.rect(0, 0, 2, H, "R")
    z.rect(W - 2, 0, 2, H, "R")
    for x in range(2, W - 2, 1):
        if rnd.random() < 0.35:
            z.put(x, 2, "G")
    # --- heather and tall grass, the bulk of the moor
    for (x, y, w, h) in [(24, 4, 9, 7), (37, 5, 10, 6), (24, 13, 9, 9), (37, 12, 3, 10), (47, 16, 3, 6),
                         (55, 27, 6, 8), (22, 37, 10, 3), (37, 26, 14, 2)]:
        z.rect(x, y, w, h, "h")
    for (x, y, w, h) in [(27, 17, 4, 3), (42, 7, 3, 2)]:
        z.rect(x, y, w, h, "k")
    # a bog with reeds round it (optional: Bog Cross)
    z.rect(40, 13, 6, 6, "r")
    z.rect(41, 14, 4, 4, "*")
    # Millstone Edge outcrops
    for (x, y) in [(36, 3), (37, 3), (45, 3), (46, 3), (47, 4), (29, 3), (56, 22), (57, 22), (25, 23), (48, 35)]:
        z.put(x, y, "G")

    # --- the A62: Manchester road in from the west, over Standedge and down to Leeds
    z.rect(0, 24, W, 3, "m")
    z.rect(0, 25, W, 1, "=")
    z.rect(0, 24, 18, 1, ":")
    z.rect(0, 26, 18, 1, ":")
    z.rect(W - 4, 24, 4, 1, ":")
    z.rect(W - 4, 26, 4, 1, ":")
    for x in range(22, W - 6):
        if x % 7 not in (0, 1) and x not in range(33, 37) and x not in range(50, 55):
            z.put(x, 23, "W")
            z.put(x, 27, "W")

    # --- the village: Uppermill and Diggle, on Oldham's edge
    z.rect(2, 3, 16, 21, "v")
    z.rect(2, 27, 16, 14, "v")
    z.rect(2, 23, 16, 1, ":")
    z.building(3, 19, 7, 4, "gritstone", "Saddleworth Museum", "museum", door=6, to="saddleworth_museum", tx=5, ty=6)
    z.building(11, 19, 6, 4, "gritstone", "Band Room", "hall", door=13, to="saddleworth_bandroom", tx=6, ty=7)
    z.building(3, 11, 9, 5, "mill", "Cotton Mill", "mill")
    z.building(13, 12, 5, 4, "weavers_cottage", show_label=False)
    z.building(3, 5, 6, 3, "weavers_cottage", show_label=False)
    z.building(10, 5, 6, 3, "weavers_cottage", show_label=False)
    z.building(3, 28, 7, 3, "weavers_cottage", show_label=False)
    z.building(11, 28, 6, 3, "weavers_cottage", show_label=False)
    z.building(3, 33, 10, 5, "mill", "Woollen Mill", "mill")
    z.rect(2, 17, 16, 1, ":")
    z.rect(2, 9, 16, 1, "#")
    z.rect(12, 9, 1, 8, "#")
    z.rect(2, 32, 16, 1, "#")
    z.rect(14, 32, 1, 8, "#")
    z.rect(2, 40, 16, 1, "v")
    for (x, y) in [(2, 18), (17, 18), (2, 10), (17, 10)]:
        z.prop("lamp_post", x, y)
    z.prop("washing_line", 13, 31, variant=1, walk=True)
    z.prop("washing_line", 6, 31, variant=2, walk=True)
    z.prop("bunting", 6, 24, walk=True)
    z.prop("bunting", 13, 24, walk=True)
    z.prop("bench", 15, 18)
    z.prop("post_box", 10, 18)
    z.prop("phone_box", 2, 22)
    z.prop("noticeboard", 10, 23) if False else None
    z.prop("oak", 16, 37)
    z.prop("oak", 4, 39)
    z.prop("sheep", 8, 39)
    z.prop("sheep", 11, 38, variant=1)
    z.prop("flagpole", 17, 22, variant=0)

    # --- the Huddersfield Narrow Canal, up through Uppermill to the Diggle portal
    z.rect(20, 8, 2, 33, "~")
    z.rect(19, 8, 1, 16, ":")
    z.rect(19, 27, 1, 13, ":")
    z.rect(18, 24, 5, 3, ":")
    z.rect(18, 25, 5, 1, "=")
    z.building(18, 3, 6, 5, "canal_tunnel", "Standedge Tunnel (Diggle)", "tunnel", door=19, to="standedge_tunnel", tx=1, ty=5)
    z.rect(22, 8, 1, 15, "m")
    z.rect(22, 28, 1, 13, "m")
    for y in (12, 20, 30, 36):
        z.prop("canal_boat", 20, y, variant=y % 2, rot=90)
    z.prop("bollard", 19, 11)
    z.prop("bollard", 19, 29)
    # the Marsden end: Tunnel End, the canal running on east to Huddersfield
    z.building(50, 3, 6, 5, "canal_tunnel", "Standedge Tunnel (Marsden)", "tunnel", door=51, to="standedge_tunnel", tx=34, ty=5)
    z.rect(52, 8, 2, 13, "~")
    z.rect(52, 19, W - 2 - 52, 2, "~")
    z.rect(51, 8, 1, 16, ":")
    z.rect(52, 14, 2, 1, ":")  # lock-gate footbridge
    z.rect(54, 8, 8, 11, "v")
    z.building(55, 9, 6, 4, "gritstone", "Standedge Visitor Centre", "museum", door=57, to="standedge_visitor", tx=5, ty=6)
    z.rect(54, 13, 8, 1, ":")
    z.rect(54, 14, 1, 1, ":")
    z.prop("canal_boat", 52, 10, variant=0, rot=90)
    z.prop("canal_boat", 57, 19, variant=1)
    z.prop("bench", 59, 14)
    z.prop("oak", 60, 16)
    z.prop("lamp_post", 55, 14)
    for y in (12, 17):
        z.put(50, y, "e")

    # --- the Pennine Way: flagstones north to south over Standedge
    z.rect(34, 3, 1, 37, ":")
    z.rect(33, 23, 3, 5, "m")
    z.rect(33, 24, 3, 3, ":")
    z.rect(33, 25, 3, 1, "=")
    z.rect(34, 3, 1, 37, ":")
    # Pots and Pans hill with its obelisk, above Dovestone
    z.rect(24, 29, 8, 7, "m")
    z.height(24, 29, 8, 7, 1)
    z.height(26, 31, 4, 3, 2)
    z.rect(23, 29, 1, 7, "e")
    z.prop("standing_stone", 27, 32, variant=1)
    z.rect(24, 36, 10, 1, "#")
    z.rect(28, 34, 1, 2, "#")
    z.rect(28, 33, 1, 1, "#")

    # --- Dovestone Reservoir
    rx, ry, rw, rh = 37, 29, 17, 10
    z.rect(rx, ry, rw, rh, "w")
    z.rect(rx + 1, ry + 1, rw - 2, rh - 2, "~")
    z.rect(rx + 4, ry + 3, rw - 8, rh - 6, "o")
    for (x, y) in [(rx, ry), (rx + rw - 1, ry), (rx, ry + rh - 1), (rx + rw - 1, ry + rh - 1)]:
        z.put(x, y, "m")
    for (x, y) in [(rx + 2, ry), (rx + 3, ry), (rx + 9, ry + rh - 1), (rx + rw - 1, ry + 4)]:
        z.put(x, y, "r")
    z.rect(rx - 1, ry - 1, rw + 2, 1, "#")  # the shore path along the dam top
    z.rect(rx - 1, ry - 1, 1, rh + 2, "#")
    z.rect(35, 28, 2, 1, "#")
    z.prop("boat", 45, 33, variant=0)
    z.prop("bench", 40, 27) if False else None
    z.prop("bench", 47, 27) if False else None

    # trees and rocks dotted about the cloughs
    for (x, y) in [(23, 12), (31, 21), (48, 21), (60, 31), (58, 36), (33, 41 - 2), (26, 27 - 1)]:
        if z.get(x, y) not in "~o:=#BDW":
            z.prop("birch", x, y) if (x + y) % 2 else z.prop("rock", x, y)
    for (x, y) in [(46, 23 + 4), (25, 21)]:
        pass

    # --- people
    z.npc("whit_cornet", "villager_4", 40, 28, "down", script="whit_cornet", name="Cornet Player", hide_if="q_pennines_whit_cornet")
    z.npc("whit_tuba", "hillwalker", 35, 8, "left", script="whit_tuba", name="Tuba Player", hide_if="q_pennines_whit_tuba")
    z.npc("moor_ranger", "villager_2", 36, 28, "down", script="moor_ranger", name="RSPB Warden")
    z.npc("moor_weaver", "villager_1", 8, 18, "down", script="moor_weaver", name="Retired Weaver")
    z.npc("moor_yorkie", "farmer", 15, 27, "up", script="moor_yorkie", name="Saddleworth Farmer")
    z.npc("moor_poet", "poet", 31, 4, "down", script="moor_poet", name="Walker", times=["dawn", "day", "dusk"])
    z.npc("moor_leggers", "canal_boater", 18, 15, "right", script="moor_leggers", name="Narrowboater")
    z.npc("moor_hare", "creature:snowhare", 42, 9, "down", script="moor_hare_spot", name="Mountain Hare", times=["dawn", "dusk"])
    # trainers
    z.npc("moor_fellrunner", "fell_runner", 35, 15, "left", trainer="pennines_fellrunner")
    z.npc("moor_rambler", "hiker", 33, 31, "right", trainer="pennines_rambler")
    z.npc("moor_angler", "angler", 50, 28, "down", trainer="pennines_angler")
    z.npc("moor_birder", "birdwatcher", 47, 11, "left", trainer="pennines_birder")
    z.npc("moor_boater", "canal_boater", 50, 18, "right", trainer="pennines_boater")

    # --- signs and plaques
    z.sign(1 + 1, 23, "WEST: Oldham and Manchester. Mind the mill chimneys, they were here first.") if False else None
    z.sign(17, 23, "SADDLEWORTH. Uppermill, Diggle, Dobcross, Delph and Greenfield. Still Yorkshire, whatever the map says.")
    z.sign(23, 22, "EAST: over Standedge on the A62 to Marsden, and on to Leeds. WEST: Oldham and Manchester.")
    z.sign(35, 22, "PENNINE WAY. North to Kirk Yetholm, 200-odd miles. South to Edale. Either way, bring a flask.")
    z.sign(16, 18, "WHIT FRIDAY. Brass band contests in every village from teatime. Road closed to traffic, open to tubas.")
    z.sign(62 - 2, 22, "LEEDS. Straight on and downhill, the way the rain goes.")
    z.sign(18, 7 + 1, "STANDEDGE TUNNEL. Over three miles of it, straight through the hill. Boat trips from the portal.",
           plaque="pennines_standedge", title="Standedge Tunnel") if False else None
    z.sign(18, 9, "The Huddersfield Narrow Canal was dug to carry wool and cotton across the Pennines. Standedge Tunnel, "
                  "opened in 1811, runs over three miles through the hill to Marsden: the longest, highest and deepest "
                  "canal tunnel in Britain. There is no towpath inside, so boatmen lay on their backs and walked the boat "
                  "through with their feet, while the horses were led over the moor.",
           plaque="pennines_standedge", title="Standedge Tunnel")
    z.sign(35, 3, "Britain's first National Trail, opened in 1965 after a long campaign led by the walker Tom Stephenson. "
                  "It runs about 268 miles along the Pennine spine from Edale in Derbyshire to Kirk Yetholm, just over "
                  "the Scottish border. Over the worst of the peat it is paved with old stone flags.",
           plaque="pennines_pennine_way", title="The Pennine Way")
    z.sign(33, 16, "Many of these flagstones were floors in Lancashire and Yorkshire mills. When the mills came down, "
                   "the flags were lifted, flown up here by helicopter and laid across the bog, so walkers stop wearing "
                   "the peat away. You are standing on somebody's old weaving shed.",
           plaque="pennines_mill_flags", title="Flagstones from the Mills")
    z.sign(36, 29, "Dovestone Reservoir was finished in 1967 to supply the towns below. The RSPB and the water company look "
                   "after the moor round it together, re-wetting the peat and planting sphagnum moss, which can hold "
                   "many times its own weight in water and slowly builds new peat.",
           plaque="pennines_dovestone", title="Dovestone and the Peat")
    z.sign(28, 31, "The obelisk on Pots and Pans hill is Saddleworth's war memorial, set high above Greenfield where every "
                   "village can see it. The hill takes its name from hollows weathered into the gritstone rocks up here.",
           plaque="pennines_pots_and_pans", title="Pots and Pans")
    z.sign(41, 10, "Mountain hares were brought to the Peak District from Scotland in the 1800s, and this is still the only "
                   "wild population in England. They turn white for winter, which is splendid in snow and a bit "
                   "embarrassing in a mild, brown January.",
           plaque="pennines_mountain_hare", title="Mountain Hares")
    z.sign(12, 23, "Every Whit Friday, brass bands tour the villages of Saddleworth and Tameside, marching into each one in "
                   "turn and playing a contest march to an adjudicator who listens without seeing who is playing. Bands "
                   "dash between villages by coach, and some manage a dozen contests in a night.",
           plaque="pennines_whit_friday", title="Whit Friday")
    z.sign(12, 17, "Saddleworth was part of Yorkshire's West Riding for centuries and only became part of Greater "
                   "Manchester in 1974. Plenty of locals never accepted the change, and the white rose still flies here.",
           plaque="pennines_saddleworth_yorkshire", title="Yorkshire, Really")
    z.sign(2, 26, "Oldham grew on cotton. By the late 1800s it had more spinning mills than almost anywhere on Earth, and "
                  "folk said it spun more cotton than France and Germany put together. You can still count the chimneys "
                  "from up on the moor.",
           plaque="pennines_oldham_cotton", title="Cotton Town")

    d = z.to_dict(
        music="route_moor",
        weather={"drizzle": 35, "fog": 22, "clear": 18, "gale": 10, "sunshine": 8, "downpour": 7},
        edges={"west": {"to": "manchester", "offset": 0}, "east": {"to": "leeds", "offset": 0}},
        encounters={
            "grass": [
                {"species": "snowhare", "min": 14, "max": 16, "weight": 14},
                {"species": "sphagnet", "min": 14, "max": 16, "weight": 16, "weather": ["drizzle", "downpour", "fog"]},
                {"species": "scuttlet", "min": 14, "max": 16, "weight": 16, "time": ["dawn", "day", "dusk"]},
                {"species": "pipkin", "min": 14, "max": 16, "weight": 12, "time": ["dawn", "day"]},
                {"species": "gritling", "min": 14, "max": 16, "weight": 12},
                {"species": "hootlet", "min": 14, "max": 16, "weight": 10, "time": ["dusk", "night"]},
                {"species": "zigzlet", "min": 14, "max": 16, "weight": 8, "time": ["day"], "season": ["spring", "summer", "autumn"]},
                {"species": "wispet", "min": 14, "max": 16, "weight": 8, "weather": ["fog"]},
                {"species": "croakle", "min": 14, "max": 16, "weight": 8, "weather": ["drizzle", "downpour"]},
                {"species": "stoatlet", "min": 14, "max": 16, "weight": 8, "season": ["winter"]},
                {"species": "tootlet", "min": 14, "max": 16, "weight": 6, "time": ["day", "dusk"]},
                {"species": "bogglet", "min": 14, "max": 16, "weight": 6, "time": ["dusk", "night"]},
            ],
            "water": [
                {"species": "dipling", "min": 14, "max": 16, "weight": 30},
                {"species": "volet", "min": 14, "max": 16, "weight": 25},
                {"species": "stalklet", "min": 14, "max": 16, "weight": 15},
                {"species": "elverlet", "min": 14, "max": 16, "weight": 15, "time": ["dusk", "night"]},
                {"species": "croakle", "min": 14, "max": 16, "weight": 15},
            ],
        },
        spawn=[3, 25],
        stage="moor",
        scaled_floor=FLOOR,
    )
    d["edges"] = d.pop("edges")
    write_json("data/zones/saddleworth_moor.json", d)
    return z


if __name__ == "__main__":
    build()
