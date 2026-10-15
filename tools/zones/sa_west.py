# somerset_levels, dartmoor, tintagel (routes/landmarks) and penzance (town) + geevor (tin mine), Penzance Sanctuary/Shop.
from wcommon import *
import math


def build(OUT):
    levels(OUT)
    dartmoor(OUT)
    tintagel(OUT)
    penzance(OUT)
    geevor(OUT)


def levels(OUT):
    W, H = 66, 44
    z = Z("somerset_levels", "Somerset Levels", W, H, kind="route", region="south_england", music="route_forest",
          weather={"fog": 24, "drizzle": 24, "clear": 18, "downpour": 12, "sunshine": 10, "frost": 6, "gale": 6})
    z.d["stage"] = "bog"
    z.legend["p"] = {"tile": "path", "colour": "#4a3a2c"}                       # peat
    z.legend["g"] = {"tile": "tall_grass", "colour": "#6f7f4a"}                 # reed bed
    z.border("T", 2, gaps=[(28, 0, 3, 2), (28, 42, 3, 2)])
    z.scatter(0, 0, W, H, "P", 20, 2, only="T")
    # the drove: a straight path from north to south
    z.rect(28, 0, 3, H, "#")
    # rhynes: straight drainage ditches in a grid, with plank bridges
    hrows = [9, 17, 25, 33]; vcols = [12, 22, 40, 52]
    for y in hrows:
        z.rect(2, y, W - 4, 1, "~")
    for x in vcols:
        z.rect(x, 2, 1, H - 4, "~")
    for y in hrows:
        for bx in (8, 17, 36, 46, 57):
            z.set(bx, y, "|")
        z.rect(28, y, 3, 1, "|")
    for x in vcols:
        for by in (5, 13, 21, 29, 37):
            z.set(x, by, "|")
    # reed beds
    for (x, y, w, h) in [(3, 3, 8, 5), (13, 10, 8, 6), (23, 18, 4, 6), (33, 26, 6, 6), (41, 3, 10, 5), (53, 18, 9, 6), (3, 34, 8, 6), (13, 34, 8, 6), (33, 3, 5, 5)]:
        z.rect(x, y, w, h, "g")
    # peat workings, south-east
    z.rect(41, 26, 22, 15, "p")
    for (x, y, w, h) in [(43, 28, 4, 3), (50, 29, 5, 2), (46, 34, 6, 3), (57, 28, 3, 4), (56, 35, 4, 3)]:
        z.rect(x, y, w, h, "~")
    z.rect(41, 33, 11, 1, "p"); z.rect(53, 26, 1, 14, "p")
    for x in vcols:
        for by in (29, 37):
            z.set(x, by, "|")
    # Burrow Mump: a small hill with a ruined church
    for y in range(10, 17):
        for x in range(41, 52):
            d = math.hypot(x - 46, y - 13)
            z.hg[y][x] = max(0, 3 - int(d / 1.8))
    z.building(45, 10, 3, 3, "chapel", "Ruined Church")
    path(z, [(46, 13), (46, 16)], "#", 1)
    z.rect(42, 14, 3, 2, "f"); z.rect(48, 14, 3, 2, "f")
    z.sign(47, 14, "BURROW MUMP. A little hill of the Levels, topped with a ruined church. In a flood it stands up as an island, and the sheep file up to it like commuters.")
    # willows along the ditches
    r = random.Random(5)
    for y in hrows:
        for x in range(3, W - 3):
            if r.random() < 0.18 and z.g[y - 1][x] == "." and abs(x - 29) > 3:
                z.set(x, y - 1, "T")
    for x in vcols:
        for y in range(3, H - 3):
            if r.random() < 0.14 and z.g[y][x + 1] == ".":
                z.set(x + 1, y, "T")
    # buildings
    z.building(14, 19, 7, 4, "white_render", "Willows and Wetlands Centre")
    z.rect(14, 23, 7, 1, ":"); z.rect(17, 23, 1, 1, ":")
    z.building(3, 26, 5, 4, "slate_cottage", "Bird Hide")
    z.building(24, 10, 7, 4, "red_brick", "Cider Farm")
    z.building(42, 27, 6, 4, "mill", "Pumping Station")
    z.prop("planter", 15, 18); z.prop("planter", 19, 18); z.prop("bench", 20, 24)
    for yy in (3, 6):
        for xx in range(24, 39, 3):
            z.prop("oak", xx, yy, variant=(xx + yy) % 3)
    z.prop("bench", 26, 15); z.prop("lamp_post", 27, 15)
    scatter_props(z, "bush", 3, 3, 60, 38, 24, 7, avoid=(".",))
    scatter_props(z, "rock", 42, 27, 20, 13, 8, 8, avoid=("p",))
    z.sign(27, 3, "THE SOMERSET LEVELS. Flat as a pancake, drained by ditches called rhynes (say 'reens'). In winter the water comes back and the road becomes a lake. Welcome.")
    z.sign(27, 28, "THE SWEET TRACK. A wooden causeway built across the marsh in 3807 BC, one of the oldest engineered roads in the world. They had good timber and good timing.")
    z.sign(39, 36, "PEAT. Cut for fuel here for centuries, now left wet to store carbon and to keep the rarities happy. Please stay on the boards.")
    z.sign(15, 24, "WILLOW AND WETLANDS. Somerset withies (willow) have been made into baskets, coffins and sturdy fences for ages. Buy a basket. Hold it like a queen.")
    # cranes and herons as scenery
    for (sp, x, y, mv) in [("cranelet", 5, 5, "wander"), ("levelcrane", 16, 13, "still"), ("stalklet", 34, 22, "wander"),
                           ("cranelet", 56, 21, "wander"), ("heronarch", 9, 36, "still"), ("stalklet", 24, 40, "wander"), ("levelcrane", 36, 7, "still")]:
        z.npc(id="crane_%s_%d" % (sp, x), sprite="creature:" + sp, x=x, y=y, facing="down", move=mv, script="crane")
    script("somerset_levels", "crane", say("Crane", "It lifts one leg, considers you, and decides you are not nearly interesting enough for the other."))
    chat(z, "reserve_warden", "birdwatcher", 26, 20, "Reserve Volunteer",
         ["Common cranes came back to Somerset in 2010. The Great Crane Project hand-reared chicks in costumes, so they didn't imprint on humans.",
          "A person in a crane costume. Think about that, next time you think your job's silly."], "right", "still")
    chat(z, "withy_weaver", "villager_4", 21, 24, "Withy Weaver",
         ["Willows grow like weeds here. Cut them down and they sprout again, so we make baskets from the prunings.",
          "Somerset withies are famous. Mind you, nobody asks me to weave a fair maid's cradle any more."], "down", "wander")
    chat(z, "cider_man", "farmer", 32, 14, "Cider Maker",
         ["Somerset cider apples have lovely names: Kingston Black, Dabinett, Sweet Coppin, Slack-ma-Girdle.",
          "I'll explain the 'scrumpy' to you. It's strong. And it's not a hobby, it's a lifestyle. A lifestyle with hangovers."], "down", "still")
    chat(z, "pump_engineer", "villager_2", 49, 32, "Pump Engineer",
         ["The Levels are below sea level in places. Pumps move the water uphill into the rivers and out to sea.",
          "In the winter floods of 2013 to 2014, the pumps went flat out for weeks. They're big. And they are very proud."], "down", "still")
    chat(z, "starling_fan", "student", 30, 40, "Starling Fan",
         ["At dusk in winter, over Ham Wall, tens of thousands of starlings swirl in the sky like one big smoky thing.",
          "It's called a murmuration. You stand there with your mouth open. Then you have to pretend you meant to."], "up", "wander")
    trainer(z, "levels_birder", "Birdwatcher Hermione", "Birdwatcher", "birdwatcher", [("levelcrane", 42), ("heronarch", 42), ("murmurant", 41)],
            26, 16, "right", ["Shh. There's a bittern in the reeds. It sounds like someone blowing across a bottle."],
            "I've lost count of the rare ones. And this battle.", "Boom. Boom. That's the bittern. Not my stomach.", 1180)
    trainer(z, "levels_angler", "Angler Cyril", "Angler", "angler", [("spatelord", 42), ("minkshade", 42), ("pincray", 41)],
            32, 29, "left", ["Eels, tench, rudd. Elvers in spring. I fish the rhynes with a bit of string and a sense of ironic detachment."],
            "Eel-ly good. Sorry.", "A rhyne is a ditch with a fan club.", 1160)
    trainer(z, "levels_warden", "Warden Cosmo", "Warden", "warden_grunt", [("peatmonarch", 42), ("bufomire", 42), ("heronarch", 43)],
            27, 36, "right", ["Welcome to the Levels Heritage Experience! Boardwalk fee: two pounds. Mud fee: included."],
            "I'll have you know it's a very good boardwalk.", "The Enclosure says: no wetland without a gift shop.", 1140)
    trainer(z, "levels_hiker", "Hiker Ffion", "Hiker", "hiker", [("hushwing", 43), ("levelcrane", 42), ("bufomire", 42)],
            34, 4, "left", ["I'm walking the Macmillan Way. It's mostly flat here. It's mostly wet, too."],
            "Fair play. I'll dry my socks and think about it.", "Socks, then second socks, then dry socks. A system.", 1200)
    trainer(z, "levels_student", "Student Barnaby", "Student", "student", [("spatelord", 41), ("sphagnet", 42), ("croakle", 41)],
            9, 29, "right", ["I'm doing a thesis on peat. I'm told it's 'dull'. It's actually 'deep'."],
            "Hm. A surprising result. I must write this down.", "Peat holds more carbon than all the world's forests combined. I could talk for hours.", 1100)
    z.d["edges"] = {"north": {"to": "glastonbury", "offset": 0}, "south": {"to": "dartmoor", "offset": 0}}
    z.d["spawn"] = [29, 3]
    wild(z, [("levelcrane", 41, 43, 16, {}), ("cranelet", 41, 42, 5, {"time": ["dawn", "day"]}), ("heronarch", 41, 43, 14, {}),
             ("stalklet", 41, 42, 5, {"weather": ["drizzle", "fog"]}), ("hushwing", 42, 43, 12, {"time": ["night"]}),
             ("barnling", 41, 42, 5, {"time": ["dusk"]}), ("pincray", 41, 43, 10, {"weather": ["drizzle", "downpour"]}),
             ("peatmonarch", 42, 43, 10, {}), ("sphagnet", 41, 42, 6, {"weather": ["fog"]}), ("bufomire", 42, 43, 8, {"weather": ["downpour"]}),
             ("croakle", 41, 42, 5, {}), ("murmurant", 41, 43, 12, {"time": ["dusk"]}), ("minkshade", 42, 43, 8, {"time": ["night"]})])
    wild(z, [("spatelord", 42, 43, 25, {}), ("pincray", 41, 43, 25, {}), ("levelcrane", 42, 43, 15, {}), ("minkshade", 42, 43, 15, {"time": ["night"]}),
             ("bufomire", 42, 43, 15, {})], "water")
    z.save(OUT + "/somerset_levels.json")


def dartmoor(OUT):
    W, H = 70, 46
    z = Z("dartmoor", "Dartmoor", W, H, kind="route", region="south_england", music="route_moor_south",
          weather={"fog": 44, "drizzle": 24, "downpour": 10, "clear": 12, "gale": 7, "sunshine": 3})
    z.d["stage"] = "moor"
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a5c6a", "prop": "heather"}
    z.legend["k"] = {"tile": "grass", "colour": "#8a8a4d"}
    z.legend["g"] = {"tile": "tall_grass", "colour": "#b5a53a", "prop": "none"}   # gorse
    z.legend["m"] = {"tile": "tall_grass", "colour": "#5f6a4a", "prop": "none"}   # mire
    z.rect(0, 0, W, H, "k")
    tors = [(50, 12, 6, 13), (17, 33, 5, 11), (57, 35, 4, 9), (36, 40, 3, 6)]
    for y in range(H):
        for x in range(W):
            z.hg[y][x] = max([0] + [max(0, hm - int(math.hypot(x - cx, y - cy) / (r / hm))) for (cx, cy, hm, r) in tors])
    z.border("R", 2, gaps=[(0, 20, 2, 3), (28, 0, 3, 2)])
    z.scatter(0, 0, W, H, "P", 40, 2, only="R")
    rr = random.Random(21)
    for (x, y, w, h) in [(3, 3, 10, 8), (3, 30, 8, 8), (32, 3, 10, 6), (33, 24, 10, 7), (60, 4, 8, 8), (55, 22, 10, 6), (22, 5, 5, 8), (40, 16, 7, 5), (23, 22, 7, 5)]:
        z.rect(x, y, w, h, "h")
    for (x, y, w, h) in [(4, 14, 6, 4), (36, 28, 6, 5), (32, 12, 5, 4), (46, 26, 8, 5), (62, 36, 6, 6), (24, 12, 3, 3)]:
        z.rect(x, y, w, h, "h")
    for (x, y, w, h) in [(5, 38, 10, 5), (44, 38, 8, 5), (62, 14, 6, 5), (37, 10, 4, 4)]:
        z.rect(x, y, w, h, "m")
    # East Dart stream (north-south) with fords and the clapper bridge on the path
    z.rect(14, 2, 3, H - 4, "~")
    z.rect(14, 9, 3, 1, "w"); z.rect(14, 35, 3, 1, "w")
    # main path: north gap down to the west gap
    z.rect(28, 0, 3, 21, "#"); z.rect(0, 20, 31, 3, "#")
    z.rect(14, 20, 3, 3, ":")                      # clapper bridge: granite slabs
    z.sign(17, 19, "POSTBRIDGE CLAPPER BRIDGE. Three huge granite slabs on stone piers, about 700 years old. 'Clapper' comes from an old word for a stepping place. It still holds.")
    path(z, [(31, 10), (46, 10)], "#", 2)             # trail to Hound Tor
    path(z, [(31, 21), (46, 21), (46, 33), (54, 33)], "#", 1)   # trail to the south-east tor
    path(z, [(46, 10), (48, 10), (48, 14)], "#", 1)
    path(z, [(29, 21), (29, 40), (36, 40)], "#", 1)   # trail down to the south
    # tors: heaps of granite on every summit
    for (cx, cy, hm, r) in tors:
        for _ in range(hm * 4):
            ax, ay = rr.randint(cx - 3, cx + 3), rr.randint(cy - 3, cy + 3)
            if 2 <= ax < W - 2 and 2 <= ay < H - 2 and z.g[ay][ax] in "khgm" and math.hypot(ax - cx, ay - cy) < 3.5:
                z.set(ax, ay, "R")
    # Hound Tor: bigger and hairier
    for (x, y) in [(47, 9), (48, 9), (49, 9), (50, 9), (51, 10), (52, 11), (53, 12), (53, 13), (52, 14), (51, 15), (50, 15), (49, 15), (47, 15), (46, 14), (46, 13), (46, 12), (46, 11), (47, 10), (50, 12), (51, 12), (49, 11)]:
        z.set(x, y, "R")
    z.rect(48, 10, 3, 1, "h"); z.rect(48, 14, 1, 1, "#")
    for (x, y) in [(48, 11), (49, 12), (50, 13), (48, 13), (49, 14), (50, 10), (51, 14)]:
        z.set(x, y, "k")
    z.prop("standing_stone", 49, 12, variant=0); z.prop("standing_stone", 50, 11, variant=2); z.prop("standing_stone", 48, 12, variant=1)
    z.sign(47, 14, "HOUND TOR. A heap of granite that in fog looks like a pack of hounds frozen mid-howl. Conan Doyle walked here before writing 'The Hound of the Baskervilles'. Beneath it lie the ruins of a medieval village. The hounds, probably, are not to blame.")
    # medieval village ruins below the tor
    for (x, y, w, h) in [(54, 18, 3, 2), (58, 17, 3, 2), (56, 22, 3, 2), (60, 21, 2, 3)]:
        z.rect(x, y, w, 1, "W"); z.rect(x, y + h - 1, w, 1, "W"); z.rect(x, y, 1, h, "W"); z.rect(x + w - 1, y, 1, h, "W")
    for (x, y) in [(55, 18), (59, 17), (57, 22), (60, 23)]:
        z.set(x, y, "k")
    # Wistman's Wood: stunted, mossy oaks
    for yy in range(37, 43):
        for xx in range(22, 30):
            if rr.random() < 0.55 and not (xx == 29):
                z.set(xx, yy, "T")
    for (x, y) in [(23, 37), (25, 38), (27, 39), (24, 41), (26, 42), (28, 40)]:
        z.set(x, y, "k")
    z.sign(30, 38, "WISTMAN'S WOOD. Tiny twisted oaks wrapped in moss, growing between boulders. Said to be the haunt of the Wild Hunt. Ghostly hounds, bad weather and a sense of humour.")
    scatter_props(z, "bush", 3, 3, 64, 40, 16, 5, avoid=("k", "h"))
    scatter_props(z, "rock", 3, 3, 64, 40, 34, 6, avoid=("k", "h"))
    # granite props on the tors
    for (cx, cy, hm, r) in tors:
        z.prop("rock", cx + 1, cy, variant=1)
    z.prop("bench", 31, 23); z.prop("bollard", 27, 19)
    z.sign(27, 8, "DARTMOOR NATIONAL PARK. 954 square km of open moor, the largest wild stretch in southern England. Sheep, ponies, tors and weather. The weather is the star.")
    z.sign(1, 19, "BODMIN MOOR AND TINTAGEL, WEST. Mind the fog. There's a rumour of a big cat. There's definitely a big sheep.")
    # ponies
    for (x, y) in [(10, 25), (22, 28), (34, 18), (42, 30), (60, 28), (33, 6), (25, 9), (32, 15)]:
        z.npc(id="pony_%d" % x, sprite="creature:foalmoor", x=x, y=y, facing="down", move="wander", script="pony")
    script("dartmoor", "pony", say("Dartmoor Pony", "It eyes your pockets, then your face. It has decided there are no apples. It looks very let down."))
    # NPCs and story
    chat(z, "pony_keeper", "farmer", 24, 21, "Pony Keeper",
         ["Dartmoor ponies roam free, but every one belongs to a farmer. Each autumn we round them up in a 'drift'.",
          "It's a very old tradition. The ponies think it's a prank. We think it's hard work."], "down", "still")
    chat(z, "tor_walker", "hiker", 40, 22, "Tor Walker",
         ["Tors are granite blocks, left standing when the softer rock around them wore away. Over millions of years, mind.",
          "The moor has 160-odd of them. I'm on tor number 71 this year. I've started naming the rocks."], "right", "wander")
    chat(z, "moor_birdwatcher", "birdwatcher", 16, 18, "Moor Watcher",
         ["Dartmoor has skylarks, wheatears, cuckoos and the odd ring ouzel.",
          "Keep your voice low. The ponies take offence at loud walkers. And the ouzels aren't impressed either."], "left", "still")
    chat(z, "stone_row_fan", "student", 6, 22, "Archaeology Student",
         ["Dartmoor has more Bronze Age remains than almost anywhere in Britain: stone rows, circles, hut circles, 3,500 years old.",
          "I dug a hut circle on my first day. Then it rained, and we had to put the trench back. In fairness it was a good hut."], "right", "still")
    z.npc(id="ashcombe_moor", sprite="ashcombe", x=47, y=16, facing="up", move="still", script="ashcombe_moor")
    script("dartmoor", "ashcombe_moor", say("Sir Rupert Ashcombe", "Placeholder: the story agent writes Ashcombe's Hound Tor scene here."))
    trainer(z, "moor_warden", "Warden Cecily", "Warden", "warden_grunt", [("tormane", 44), ("gwyllgi", 43), ("peatmonarch", 44)],
            29, 6, "down", ["Hello! Official Hound Tor Hunting Experience! The legendary hound! Photo opportunities! Fog extra."],
            "I'm not allowed to lose. It's in the brochure.", "Sir Rupert says the hound is 'under license'. I've no idea what that means.", 1280)
    trainer(z, "moor_hiker", "Hiker Humphrey", "Hiker", "hiker", [("tormane", 44), ("forkwing", 43), ("hazeldoze", 43)],
            38, 10, "right", ["I'm on the 'Ten Tors'. It's a challenge. I've done ten tors. In a day. It is not fun. I need to sit."],
            "I might have to climb eleven. Out of spite.", "Never wear new boots on the moor. Learned in boots. In the fog.", 1260)
    trainer(z, "moor_angler", "Angler Moira", "Angler", "angler", [("spatelord", 43), ("rillotter", 43), ("pincray", 43)],
            12, 26, "right", ["Brown trout, in a stream so clear you can see your own failures. Come on, then."],
            "Landed. Lovely rod.", "A tight line and a flask of tea. That's all anyone needs.", 1200)
    trainer(z, "moor_birder", "Birdwatcher Percy", "Birdwatcher", "birdwatcher", [("forkwing", 44), ("hushwing", 44), ("kitelet", 43)],
            22, 24, "up", ["I'm looking for the ring ouzel, which is like a blackbird in a smart collar. Got a minute?"],
            "That was brisk. The ouzel flew off in disgust.", "If you see a bird in a white bib, wave. Politely.", 1240)
    trainer(z, "moor_druid", "Druid Taliesin", "Druid", "villager_6", [("pixiedell", 44), ("bodminax", 45), ("gwyllgi", 44)],
            52, 33, "left", ["The moor remembers. It remembers me, in particular, as a nuisance. Shall we?"],
            "The moor has spoken. And it's yawning.", "I call this place 'Little Bodmin'. The cat knows.", 1300)
    z.d["edges"] = {"north": {"to": "somerset_levels", "offset": 0}, "west": {"to": "tintagel", "offset": 0}}
    z.d["spawn"] = [29, 3]
    wild(z, [("tormane", 43, 45, 14, {}), ("foalmoor", 43, 44, 5, {"time": ["dawn", "day"]}), ("bodminax", 44, 45, 4, {"time": ["night"], "weather": ["fog"]}),
             ("hazeldoze", 43, 44, 12, {}), ("dozelet", 43, 44, 4, {"time": ["dusk"]}), ("lanternis", 43, 45, 10, {"time": ["night", "dusk"]}),
             ("glowmite", 43, 44, 4, {"weather": ["fog"], "time": ["night"]}), ("horseshoe", 43, 45, 10, {"time": ["night"]}),
             ("horselet", 43, 44, 4, {"time": ["night"]}), ("pixiedell", 43, 45, 12, {"weather": ["fog", "drizzle"]}),
             ("pixling", 43, 44, 5, {"weather": ["fog"]}), ("gwyllgi", 44, 45, 10, {"time": ["night", "dusk"]}),
             ("peatmonarch", 43, 45, 10, {"weather": ["drizzle", "downpour"]}), ("forkwing", 43, 45, 8, {"weather": ["gale", "clear"]}),
             ("adderking", 43, 45, 8, {"time": ["dawn", "day"]})])
    wild(z, [("spatelord", 43, 45, 30, {}), ("rillotter", 43, 45, 30, {}), ("pincray", 43, 45, 20, {})], "water")
    z.save(OUT + "/dartmoor.json")


def tintagel(OUT):
    W, H = 60, 44
    z = Z("tintagel", "Tintagel", W, H, kind="route", region="cornwall", music="route_coast",
          weather={"clear": 20, "sunshine": 12, "drizzle": 22, "fog": 20, "gale": 18, "downpour": 8})
    z.d["stage"] = "coast"
    z.rect(0, 0, W, H, "$")
    z.rect(22, 0, 38, H, ".")
    z.border("T", 2, gaps=[(58, 20, 2, 3), (28, 42, 3, 2)])
    z.rect(0, 0, 22, H, "$")
    z.scatter(22, 0, 38, H, "P", 24, 3, only="T")
    # island headland with the castle
    for y in range(H):
        for x in range(W):
            if x < 20:
                d = math.hypot(x - 11, y - 13)
                if d < 9.5:
                    z.hg[y][x] = max(0, 4 - int(d / 2.5))
            else:
                z.hg[y][x] = max(0, 2 - (x - 24) // 2 - abs(y - 13) // 3) if x >= 24 else 0
    for y in range(4, 24):
        for x in range(1, 20):
            if math.hypot(x - 11, y - 13) < 9.5:
                z.set(x, y, ".")
    for y in range(4, 24):
        for x in range(1, 20):
            d = math.hypot(x - 11, y - 13)
            if 8.0 <= d < 9.5:
                z.set(x, y, "^")
    # mainland cliff edge
    z.rect(20, 3, 4, 38, "^")
    # footbridge across the chasm
    z.rect(19, 12, 5, 3, ":"); z.rect(19, 11, 5, 1, "W"); z.rect(19, 15, 5, 1, "W")
    z.height(19, 12, 5, 3, 2)
    z.rect(18, 12, 1, 3, ":")
    z.sign(25, 11, "THE NEW FOOTBRIDGE, 2019. Two cantilevers that almost touch, with a 4 cm gap in the middle. It replaced a steep stair, and the gap is a design feature, not a mistake.")
    # castle ruins
    z.building(8, 9, 7, 4, "castle", "Tintagel Castle")
    z.building(5, 13, 4, 3, "castle", show_label=False)
    z.building(13, 14, 4, 3, "castle", "Great Hall")
    z.building(9, 5, 4, 3, "castle", show_label=False)
    for (x, y, w, h) in [(5, 8, 4, 1), (14, 8, 3, 1), (4, 17, 4, 1), (12, 18, 4, 1)]:
        z.rect(x, y, w, h, "W")
    z.rect(11, 13, 2, 8, "#"); z.rect(11, 17, 5, 1, "#"); z.rect(16, 13, 3, 1, "#"); z.rect(12, 8, 1, 1, "#")
    path(z, [(18, 13), (14, 13), (12, 13)], "#", 1)
    z.rect(7, 18, 4, 2, "f"); z.rect(14, 5, 3, 2, "f"); z.rect(3, 12, 2, 3, ",")
    z.prop("statue", 7, 7); z.prop("bench", 10, 15); z.prop("rock", 5, 19); z.prop("rock", 16, 10)
    z.sign(8, 7, "GALLOS. A giant bronze-coloured king standing on the headland, 2016. 'Gallos' is Cornish for 'power'. The artist, Rubin Eynon, says it also means 'a very big man'.")
    z.sign(14, 12, "TINTAGEL CASTLE. Sixth-century fortress, 13th-century castle. Geoffrey of Monmouth says King Arthur was conceived here. The castle sniffs, and says Arthur was born whenever it suited the tourist board.")
    # beach and Merlin's Cave
    z.rect(4, 24, 18, 2, "^")
    z.rect(5, 26, 15, 8, "s"); z.rect(5, 26, 15, 1, "w")
    z.rect(2, 26, 3, 8, "w"); z.rect(2, 34, 18, 1, "w")
    z.set(10, 25, "x"); z.set(11, 25, "x"); z.set(10, 24, "x"); z.set(11, 24, "x")
    z.rect(20, 26, 6, 3, "s")
    z.height(5, 26, 15, 8, 0); z.height(2, 24, 22, 11, 0)
    z.rect(20, 24, 4, 2, "^"); z.rect(24, 26, 6, 3, "s")
    z.sign(12, 27, "MERLIN'S CAVE. A sea cave right through the headland, 100 m long, reached at low tide. Legend says it's where Merlin found baby Arthur. On a good tide, the sea does the rest of the story.")
    z.prop("rock", 7, 30); z.prop("rock", 15, 31); z.prop("boat", 4, 31, variant=1); z.prop("buoy", 3, 36)
    # mainland
    z.rect(30, 20, 30, 3, "="); z.rect(28, 12, 3, 31, "="); z.rect(24, 12, 7, 3, "#")
    z.rect(24, 12, 4, 3, "#")
    z.rect(27, 26, 1, 3, "#"); z.rect(24, 26, 4, 3, "s")
    z.rect(30, 19, 28, 1, ":"); z.rect(30, 23, 28, 1, ":")
    for x in (34, 42, 50):
        z.prop("lamp_post", x, 19)
    z.building(34, 5, 10, 6, "stone", "King Arthur's Great Halls")
    z.rect(34, 11, 10, 1, ":"); z.rect(38, 11, 2, 8, ":")
    z.building(46, 10, 6, 5, "slate_cottage", "Old Post Office")
    z.rect(46, 15, 6, 1, ":"); z.rect(47, 15, 1, 4, ":")
    z.building(46, 25, 7, 4, "white_render", "Pasty Shop"); z.building(36, 25, 6, 4, "terrace", "Camelot Shop")
    z.rect(36, 29, 17, 1, ":"); z.rect(30, 24, 6, 5, ".")
    z.building(36, 35, 4, 4, "chapel", "St Materiana's")
    z.rect(36, 39, 4, 1, ":")
    z.prop("bench", 37, 18); z.prop("planter", 35, 11); z.prop("planter", 42, 11); z.prop("statue", 42, 29)
    z.sign(32, 19, "TINTAGEL. A tiny village with a big myth. Tintagel is Cornish 'Din Tagell', the fort of the narrow neck. A very good name for a place with only one way in.")
    z.sign(37, 40, "ST MATERIANA'S CHURCH. A 1,000-year-old cliff church. Materiana was a Welsh saint. The church survived a thousand winters, and never complained about the wind.")
    z.rect(44, 31, 8, 8, ","); z.rect(32, 33, 4, 8, ","); z.rect(54, 5, 4, 12, ","); z.rect(56, 28, 3, 12, ",")
    scatter_props(z, "bush", 30, 3, 28, 38, 18, 4, avoid=(".",))
    scatter_props(z, "rock", 30, 3, 28, 38, 8, 5, avoid=(".",))
    z.rect(52, 31, 5, 1, "F"); z.rect(52, 31, 1, 4, "F")
    # NPCs
    chat(z, "arthurian", "tour_guide", 39, 20, "Arthurian Guide",
         ["Welcome to Tintagel! Were Arthur and Merlin here? It's a poet's tale, a medieval storyteller's tale, and the tourist board's mission statement.",
          "The real castle was built in the 1230s by Richard, Earl of Cornwall. He wanted a famous place. He got one."], "down", "still")
    chat(z, "postmaster", "villager_3", 49, 18, "Old Post Office Keeper",
         ["This house is from the 1380s. It was a farmhouse, and from 1844 to 1892 it was a post office. The roof sags like a hammock.",
          "It's now owned by the National Trust. The roof is also owned by the National Trust. The sag, I think, was a gift."], "down", "still")
    chat(z, "pasty_seller", "shopkeeper", 49, 24, "Pasty Seller",
         ["A proper Cornish pasty has a crimped edge, shaped like a D, with beef, potato, swede and onion. No carrots. Never carrots.",
          "Pasties have PGI status, like champagne. If it isn't made in Cornwall, it's only a pasty-shaped wrap."], "down", "still")
    chat(z, "kernow_fan", "villager_5", 33, 22, "Local",
         ["Dydh da! That's 'good day' in Cornish, Kernewek. We've been bringing it back, a bit at a time.",
          "Kernow is Cornwall. One and All, 'Onen hag Oll', is the motto. It's on every shirt. It's even on my pasty bag."], "right", "wander")
    z.npc(id="ashcombe", sprite="ashcombe", x=17, y=12, facing="down", move="still", script="ashcombe_tintagel")
    script("tintagel", "ashcombe_tintagel", say("Sir Rupert Ashcombe", "Placeholder: the story agent writes Ashcombe's first battle here."))
    trainer(z, "tin_surfer", "Surfer Tamsin", "Surfer", "surfer", [("baskarr", 45), ("petrelash", 45), ("greyhaul", 46)],
            18, 30, "right", ["The Atlantic swell comes straight in here. I'm told the waves are 'consistent'. I'm told that by me."],
            "Wipeout. Total, and beautiful.", "Low tide, you can walk to Merlin's Cave. High tide, you can swim to the pub.", 1380)
    trainer(z, "tin_birder", "Birdwatcher Alwyn", "Birdwatcher", "birdwatcher", [("clownbill", 45), ("cragchough", 46), ("polartern", 45)],
            26, 6, "down", ["Puffins, razorbills, choughs. Choughs are on the Cornish coat of arms, and they came back in 2001."],
            "A cheerful chough landed on my head while we fought. Distracting.", "Choughs: red legs, red beak, loud voice. The perfect Cornish bird.", 1360)
    trainer(z, "tin_druid", "Druid Myrddin", "Druid", "villager_6", [("pixiedell", 46), ("tylwyth", 45), ("wispet", 45)],
            12, 17, "up", ["I'm a re-enactor! Merlin, full time. Today's performance is 'Wizard Declines to be Interviewed.'"],
            "A cunning wizard knows when to retire. I'm going for a pasty.", "Remember: the beard is real. The prophecy is optional.", 1340)
    trainer(z, "tin_warden", "Warden Algernon", "Warden", "warden_grunt", [("cragchough", 46), ("petrelash", 45), ("greyhaul", 45)],
            25, 13, "left", ["Welcome to the Arthurian Heritage Experience! Sword in the stone, selfie permit, and a bucket of legend. Eleven pounds."],
            "Well. That's a refund, then.", "Sir Rupert has plans for this headland. Large plans. With turnstiles.", 1320)
    z.d["edges"] = {"east": {"to": "dartmoor", "offset": 0}, "south": {"to": "penzance", "offset": 0}}
    z.d["spawn"] = [56, 21]
    wild(z, [("baskling", 45, 46, 8, {"time": ["day", "dawn"]}), ("cragchough", 45, 46, 14, {}), ("clownbill", 45, 46, 14, {"time": ["day", "dawn"]}),
             ("polartern", 45, 46, 10, {"weather": ["gale", "frost", "fog"]}), ("petrelash", 45, 46, 12, {"weather": ["gale", "downpour", "drizzle"]}),
             ("greyhaul", 45, 46, 10, {}), ("pixiedell", 45, 46, 12, {"weather": ["fog", "drizzle"]}), ("pixling", 45, 46, 5, {"weather": ["fog"]}),
             ("bodminax", 45, 46, 4, {"time": ["night"]}), ("tylwyth", 45, 46, 8, {"time": ["dusk", "night"]}), ("wispet", 45, 46, 8, {"time": ["night"]})])
    wild(z, [("baskarr", 45, 46, 30, {}), ("baskling", 45, 46, 10, {}), ("clawcastle", 45, 46, 20, {}), ("petrelash", 45, 46, 20, {}), ("greyhaul", 45, 46, 20, {})], "water")
    z.save(OUT + "/tintagel.json")


def penzance(OUT):
    W, H = 64, 48
    z = Z("penzance", "Penzance", W, H, kind="town", region="cornwall", music="town_cornwall",
          weather={"drizzle": 28, "clear": 20, "sunshine": 16, "gale": 14, "fog": 14, "downpour": 8})
    z.d["stage"] = "docks"; z.d["town_id"] = "penzance"
    z.rect(0, 38, W, 10, "$")
    z.border("T", 2, gaps=[(28, 0, 3, 2)])
    z.rect(0, 38, W, 10, "$")
    z.scatter(0, 0, W, 38, "P", 25, 2, only="T")
    # roads: the north road, Market Jew Street, the promenade
    z.rect(28, 0, 3, 38, "="); z.rect(27, 2, 1, 35, ":"); z.rect(31, 2, 1, 35, ":")
    z.rect(2, 20, 60, 3, "="); z.rect(2, 19, 60, 1, ":"); z.rect(2, 23, 60, 1, ":")
    z.rect(2, 36, 46, 2, ":")
    for x in (6, 14, 22, 36, 44, 52, 58):
        z.prop("lamp_post", x, 19)
    for x in (10, 18, 40, 48, 56):
        z.prop("lamp_post", x, 23)
    z.prop("phone_box", 4, 19); z.prop("post_box", 60, 23); z.prop("bench", 24, 23); z.prop("bench", 34, 19)
    z.prop("statue", 33, 21)
    z.sign(34, 23, "SIR HUMPHRY DAVY. Born in Penzance, 1778. He invented the miner's safety lamp, which saved countless lives. His statue stands on the street where he lost a few marbles as a boy.")
    # Sanctuary and Corner Shop
    z.building(8, 15, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.building(15, 15, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(11, 18, "penzance_sanctuary", 5, 6, "up"); z.warp(17, 18, "penzance_shop", 4, 5, "up")
    z.building(3, 15, 4, 4, "slate_cottage", show_label=False)
    z.building(21, 15, 5, 4, "terrace", "Pasty Co.")
    z.building(34, 14, 9, 5, "tudor", "Admiral Benbow")
    z.building(45, 14, 6, 4, "cream_render", "Chapel Street Books")
    z.building(53, 14, 5, 4, "terrace", show_label=False)
    z.sign(40, 19, "THE ADMIRAL BENBOW. A pub on Chapel Street, with a ship's figurehead, a smuggler's past, and a landlord who has heard every Treasure Island joke.")
    # Geevor tin mine entrance and an engine house, north-west of the street
    z.building(3, 26, 8, 4, "slate_cottage", "Geevor Tin Mine", door=3)
    z.warp(6, 29, "geevor", 22, 29, "up")
    z.building(14, 26, 4, 4, "mill", "Engine House")
    z.rect(2, 24, 18, 1, ":"); z.rect(2, 30, 18, 1, ":")
    for (x, y, v) in [(11, 25, 0), (13, 25, 1), (19, 29, 2), (20, 27, 0)]:
        z.prop("slate_heap", x, y, variant=v)
    z.prop("bollard", 5, 30); z.prop("bollard", 8, 30)
    z.sign(9, 25, "GEEVOR TIN MINE. Working until 1990, now a museum. Miners dug tin and copper from tunnels running out under the sea. You can hear the waves overhead. Hard hats provided. Jokes not.")
    z.sign(20, 25, "CORNWALL'S MINING LANDSCAPE. A World Heritage Site since 2006. Cornish engine houses dot the coast, each one a chimney with a story.")
    # station
    z.building(36, 26, 10, 2, "station", "Penzance Station", door=4)
    z.rect(36, 28, 10, 1, "_"); z.rect(35, 29, 12, 1, "!")
    z.d["station"] = {"x": 40, "y": 28}
    z.rect(35, 24, 1, 5, ":"); z.rect(46, 24, 1, 5, ":"); z.rect(35, 28, 1, 1, "#"); z.rect(46, 28, 1, 1, "#")
    z.rect(36, 25, 10, 1, ":")
    z.prop("bench", 38, 28); z.prop("lamp_post", 44, 28)
    rail_guard(z, 42, 28, ["Penzance. The end of the line. Past here there's only the sea and a gentle sense of finality.",
                           "Hop aboard. The Wildlore rail runs to any town you have visited. Where to?"])
    # Jubilee Pool
    z.rect(3, 32, 14, 6, ":"); z.rect(4, 33, 12, 4, "~")
    z.rect(3, 32, 14, 1, "W"); z.rect(3, 37, 14, 1, "W")
    z.rect(9, 32, 2, 1, ":"); z.rect(9, 37, 2, 1, ":")
    z.rect(2, 31, 16, 1, ":")
    z.prop("bench", 5, 31); z.prop("bench", 14, 31); z.prop("lamp_post", 3, 31); z.prop("lamp_post", 16, 31); z.prop("planter", 8, 31)
    z.sign(10, 31, "THE JUBILEE POOL. Built in 1935, a triangular art deco seawater lido, and one of the biggest in Britain. It's cold. It's gorgeous. It's cold.")
    # harbour
    z.rect(20, 38, 26, 8, "~")
    z.rect(20, 37, 26, 1, ":"); z.rect(19, 37, 1, 9, ":"); z.rect(46, 37, 1, 9, ":")
    z.rect(32, 38, 1, 6, ":"); z.rect(26, 38, 1, 4, ":")
    z.rect(44, 38, 2, 8, ":")
    for (x, y, v) in [(23, 40, 1), (29, 41, 1), (35, 40, 1), (38, 43, 0), (41, 41, 1), (24, 44, 1), (30, 44, 1)]:
        z.prop("boat", x, y, variant=v)
    for (x, y) in [(22, 43), (28, 40), (36, 42), (40, 44)]:
        z.prop("buoy", x, y)
    for x in (22, 28, 34, 40, 45):
        z.prop("bollard", x, 37)
    z.prop("lighthouse", 45, 44)
    z.sign(25, 36, "PENZANCE HARBOUR. Pen Sans in Cornish: 'holy headland'. Penzance has been a harbour since the Middle Ages. Pirates once raided it. Now only the seagulls do.")
    # St Michael's Mount, across a causeway
    z.rect(47, 28, 17, 10, "$")
    for y in range(24, 45):
        for x in range(50, 64):
            d = math.hypot(x - 58, y - 34)
            if d < 6.5:
                z.set(x, y, ".")
                z.hg[y][x] = max(0, 4 - int(d / 1.7))
    z.rect(47, 33, 5, 3, "s"); z.rect(47, 32, 5, 1, "w"); z.rect(47, 36, 5, 1, "w")
    z.rect(47, 33, 4, 2, "s")
    z.building(57, 32, 3, 3, "castle", "St Michael's Mount")
    z.building(53, 37, 3, 2, "slate_cottage", show_label=False); z.building(58, 38, 3, 2, "slate_cottage", show_label=False)
    path(z, [(51, 34), (55, 34), (56, 36), (56, 31), (58, 31)], "#", 1)
    z.rect(52, 31, 2, 2, "f"); z.rect(60, 36, 2, 2, "f")
    z.prop("bench", 54, 35); z.prop("rock", 52, 38); z.prop("bush", 61, 33); z.prop("bush", 55, 32)
    z.sign(48, 34, "THE CAUSEWAY. At low tide you can walk to St Michael's Mount. At high tide you can join the fishes. Check the board. The board is truthful.")
    z.sign(53, 33, "ST MICHAEL'S MOUNT. A tidal island with a castle on top and a village at its feet. In Cornish it's Karrek Loos yn Koos, the 'grey rock in the wood'. The wood went under the sea ages ago. The rock stayed.")
    # tall grass for encounters
    z.rect(3, 4, 8, 6, ","); z.rect(34, 4, 6, 6, ","); z.rect(52, 5, 6, 7, ","); z.rect(22, 30, 5, 5, ","); z.rect(34, 31, 5, 4, ",")
    z.rect(3, 10, 8, 1, "f")
    scatter_props(z, "bush", 3, 3, 56, 33, 18, 5, avoid=(".",))
    scatter_props(z, "oak", 3, 3, 56, 12, 6, 6, avoid=(".",))
    # NPCs
    chat(z, "pasty_baker", "shopkeeper", 22, 21, "Pasty Baker",
         ["A Cornish pasty was a miner's lunch: the thick crimped edge was a handle, so dirty hands didn't touch the food. They threw the crust away.",
          "I never throw the crust away. It's the best bit. Some say you should leave it for the knockers. I say that's a different kind of lunch."], "down", "still")
    chat(z, "old_miner", "hiker", 12, 31, "Retired Miner",
         ["The knockers are small folk who tapped at the rock, so the story goes. Miners left a bit of pasty crust for them, for luck.",
          "I'm told they were harmless. But if you whistled underground, they'd come and complain."], "right", "still")
    chat(z, "mount_ferryman", "sailor", 45, 35, "Mount Boatman",
         ["The causeway is 'pass at your own risk' for about two hours either side of low tide.",
          "Between those, I'll ferry you across. Fifteen quid. Splash included."], "right", "still")
    chat(z, "lido_swimmer", "villager_1", 3, 30, "Cold Water Swimmer",
         ["The Jubilee Pool is a seawater lido. It's cold. I'll swim all year. It's good for you. I'm told. I can't feel my toes to check.",
          "They heat part of it with a geothermal well now. It's 'warmish', which is as warm as Cornwall gets."], "down", "wander")
    chat(z, "davy_fan", "student", 30, 18, "History Student",
         ["Sir Humphry Davy invented the safety lamp in 1815. The flame was shrouded in wire mesh, so it couldn't set off firedamp in the mine.",
          "He never patented it. He said he wanted to help miners, not make money. A very unfashionable idea."], "right", "wander")
    chat(z, "harbour_master", "angler", 28, 37, "Harbour Master",
         ["Penzance is the biggest town in west Cornwall. And the sea gets in everywhere. It's a lifestyle.",
          "The Scillonian ferry leaves from this quay for the Isles of Scilly. There's a lot of sea to cross, and a lot of sandwiches to eat."], "down", "wander")
    trainer(z, "penz_surfer", "Surfer Jago", "Surfer", "surfer", [("plungebeak", 47), ("clownbill", 46), ("petrelash", 47)],
            30, 33, "up", ["Heading for Sennen? The swell's up. Battle first, wetsuit second."],
            "Totally radical. And a bit damp.", "Fistral is for beginners, Sennen is for people who like drama.", 1500)
    trainer(z, "penz_busker", "Busker Pasca", "Busker", "harpist", [("gannetling", 46), ("tinnet", 46), ("baskling", 46)],
            24, 21, "right", ["I'm playing a tin whistle. It's a mining song! 'Lamorna'. Hum along. Or battle along."],
            "That's the end of the set. Thank you, I'll be here all week.", "I get a lot of coins. Mostly in the tin. The Cornish are good for it.", 1480)
    z.d["edges"] = {"north": {"to": "tintagel", "offset": 0}}
    z.d["spawn"] = [29, 21]
    wild(z, [("gannetling", 46, 47, 14, {"time": ["day", "dawn"]}), ("plungebeak", 47, 48, 10, {"weather": ["gale", "clear"]}),
             ("baskling", 46, 47, 6, {"weather": ["fog", "drizzle"]}), ("tinnet", 46, 48, 14, {}), ("cassiterix", 47, 48, 5, {"weather": ["downpour"]}),
             ("chipgull", 46, 47, 14, {"time": ["day"]}), ("pierlord", 47, 48, 8, {"time": ["day", "dusk"]}), ("clownbill", 46, 48, 10, {"time": ["dawn", "day"]}),
             ("polartern", 46, 47, 8, {"weather": ["frost", "gale"]}), ("petrelash", 46, 48, 10, {"time": ["night"]})])
    wild(z, [("baskling", 46, 47, 14, {}), ("baskarr", 47, 48, 10, {}), ("gannetling", 46, 47, 20, {}), ("clawcastle", 46, 48, 20, {}), ("pierlord", 46, 48, 20, {})], "water")
    z.save(OUT + "/penzance.json")
    sanctuary(OUT, "penzance", "Penzance", (11, 19), music="sanctuary")
    shop(OUT, "penzance", "Penzance", (17, 19))
    nurse("penzance", ["Welcome to the Penzance Sanctuary. Dydh da! That's Cornish for 'hello'. I'm told it's pronounced differently by everyone. Pop your team on the counter.",
                       "Let me take a look. Mind the wind, it blows the paperwork.",
                       "All done. Meur ras, that's 'thank you'. I've practised it. Honest.",
                       "The Ark terminal. It runs on tea, tin and a very reliable gull.",
                       "No bother. Come in out of the rain. It's always raining. It's a feature."])
    shopkeeper("penzance", "Dydh da! Snares, pasties and one sou'wester that has never been returned.",
               "Fair winds. And mind the seagulls, they've got a union.")


def geevor(OUT):
    W, H = 46, 34
    g = Z("geevor", "Geevor Tin Mine", W, H, fill="x", kind="interior", region="", music="route_mountain", weather={})
    g.d["stage"] = "cave"
    g.legend["k"] = {"tile": "path", "colour": "#50505a"}
    g.legend["g"] = {"tile": "tall_grass", "colour": "#5a5a52", "prop": "none"}     # loose spoil: encounters
    for (x, y, w, h) in [(18, 26, 10, 5), (21, 12, 3, 14), (23, 20, 18, 3), (6, 20, 16, 3), (4, 13, 9, 9), (34, 10, 9, 12), (16, 3, 14, 9), (30, 24, 12, 7), (36, 22, 2, 3), (21, 11, 3, 2)]:
        g.rect(x, y, w, h, "k")
    g.rect(21, 15, 3, 2, "|"); g.rect(14, 20, 2, 3, "|"); g.rect(28, 20, 2, 3, "|"); g.rect(21, 24, 3, 2, "|")
    for (x, y, w, h) in [(5, 14, 6, 4), (36, 12, 6, 5), (32, 25, 8, 4), (18, 5, 10, 4)]:
        g.rect(x, y, w, h, "g")
    g.rect(8, 19, 3, 1, "~"); g.rect(38, 19, 2, 1, "~")
    g.rect(19, 5, 1, 1, "k")
    g.set(22, 31, "D")
    g.d["warps"].append({"x": 22, "y": 31, "to": "penzance", "tx": 6, "ty": 30, "facing": "down"})
    for (x, y, v) in [(5, 21, 0), (11, 15, 1), (41, 14, 2), (31, 28, 0), (17, 28, 1), (27, 29, 2), (17, 6, 0), (27, 10, 1), (7, 13, 2)]:
        g.prop("slate_heap", x, y, variant=v)
    for (x, y) in [(22, 27), (20, 20), (22, 18), (31, 21), (14, 21), (22, 8), (36, 15), (8, 17)]:
        g.prop("lamp_post", x, y)
    g.prop("bench", 19, 28); g.prop("bench", 26, 28); g.prop("rock", 38, 20); g.prop("rock", 12, 14)
    g.sign(24, 29, "GEEVOR. In 1990 the last tin came out of the ground in West Penwith. The tunnels reach out under the Atlantic. The sea is above your head. Please do not worry.")
    g.sign(25, 21, "LEVEL ONE. The tin ore was hand-drilled by candlelight before safety lamps came along. The miners wore felt hats hardened with clay. And bravery.")
    g.sign(20, 7, "KNOCKERS. Tapping in the rock means the knockers are about. Miners left them a bit of crust. If you don't have crust, a firm 'excuse me' is polite.")
    for (nid, spr, x, y, f, lines, who) in [
        ("miner_guide", "hiker", 20, 27, "right", ["Hard hat on? Good. Lamp on? Better. Spare lamp? Best. Mind the drip. It's Atlantic, and it's cold."], "Mine Guide"),
        ("miner_old", "farmer", 7, 22, "up", ["I worked here from 1969. They'd turn the lights out for the knockers' sake. I swear I heard them.", "The seams ran out under the sea. You could hear the boulders rolling in a storm. A lot of men were braver than me."], "Old Hand"),
        ("miner_kid", "student", 41, 21, "left", ["The tin goes into bronze, and solder, and tin cans. Cornish tin was traded to the Phoenicians, they say, in ancient days.", "I'm doing work experience. My job is to hold the torch. I hold it well."], "Work Experience")]:
        chat(g, nid, spr, x, y, who, lines, f, "still")
    g.npc(id="ashcombe_mine", sprite="ashcombe", x=23, y=5, facing="down", move="still", script="ashcombe_mine")
    script("geevor", "ashcombe_mine", say("Sir Rupert Ashcombe", "Placeholder: the story agent writes Ashcombe's mine confrontation here."))
    trainer(g, "mine_one", "Tin Miner Jory", "Tin Miner", "hiker", [("tinnet", 46), ("gritling", 46), ("coblynn", 47)],
            22, 16, "down", ["Hold up! Nobody passes the main shaft without a hard hat. And a battle."],
            "Fair enough. Go on. Mind your head on the low bit.", "The shaft's a mile deep. Perhaps. Might be an exaggeration. The echo's lying.", 1560)
    trainer(g, "mine_two", "Tin Miner Tamsin", "Tin Miner", "farmer", [("quarrion", 47), ("tinnet", 46), ("tapknock", 47)],
            12, 21, "right", ["I only come down to chip away at the last of the tin. And the odd trespasser."],
            "Hm. Broke my pick. Go on through.", "I'd say 'break a leg', but down here that's not a figure of speech.", 1580)
    trainer(g, "mine_three", "Tin Miner Cadan", "Tin Miner", "hiker", [("cassiterix", 48), ("slatelet", 46), ("horseshoe", 47)],
            31, 21, "left", ["Anything down here is mine. By which I mean, I work here. Technically."],
            "Dug that one right out from under me.", "Cornish tin's been mined for over 4,000 years. I'd say the ore's running out, but I'm biased.", 1600)
    trainer(g, "mine_four", "Warden Perran", "Warden", "warden_grunt", [("cassiterix", 48), ("quarrion", 47), ("tinnet", 47)],
            38, 15, "down", ["Welcome to the Underground Heritage Experience! Hard hat hire: eight pounds. Hard luck: free."],
            "I'll file a report on the unreasonable level of competence.", "Sir Rupert's in the north chamber. He's measuring for turnstiles.", 1540)
    g.d["spawn"] = [22, 29]
    wild(g, [("tinnet", 46, 48, 20, {}), ("cassiterix", 47, 48, 8, {}), ("coblynn", 46, 48, 12, {}), ("tapknock", 46, 47, 8, {}),
             ("quarrion", 47, 48, 10, {}), ("slatelet", 46, 47, 8, {}), ("gritling", 46, 47, 10, {}), ("horseshoe", 47, 48, 10, {"time": ["night", "dusk"]})])
    g.save(OUT + "/geevor.json")
